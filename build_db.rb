#Kevin Lynagh
#October 2010

require 'sequel'
DB = Sequel.connect('sqlite:///data/pdbs.db')
if not DB.table_exists?(:pdbs)
  DB.create_table :pdbs do
    primary_key :id
    String :cath_id
    String :seq
    Int :n
    Int :c
    Int :a
    Int :t
    Int :h
    index :cath_id
  end

  DB.create_table :ca_coordinates do
    primary_key :id
    String :cath_id
    Integer :i
    Float   :x
    Float   :y
    Float   :z

    index :i
    index :cath_id
  end

end

$pdbs = DB[:pdbs]
$ca_coordinates = DB[:ca_coordinates]

AA_code = {
  'ALA' => 'A',
  'ARG' => 'R',
  'ASN' => 'N',
  'ASP' => 'D',
  'CYS' => 'C',
  'GLU' => 'E',
  'GLN' => 'Q',
  'GLY' => 'G',
  'HIS' => 'H',
  'ILE' => 'I',
  'LEU' => 'L',
  'LYS' => 'K',
  'MET' => 'M',
  'PHE' => 'F',
  'PRO' => 'P',
  'SER' => 'S',
  'THR' => 'T',
  'TRP' => 'W',
  'TYR' => 'Y',
  'VAL' => 'V'
}


#directory of chopped ATOM lines files from CATH API; http://data.cathdb.info/v3_3_0/dompdb/1cukA01
PDB_root = '/data/pdbs'

#CathDomainList file; http://release.cathdb.info/v3.3.0/CathDomainList
CathDomainList = '/data/CathDomainList'


open(CathDomainList).each_line{|l|
  #lines look like
  #1oaiA00     1    10     8    10     1     1     1     1     1    59 1.000
  next if l[0] == '#' #skip comments
  d = l.split
  cath_id = d[0]

  #skip comments / malformed lines
  next unless d.count == 12

  if d[11] == '1000.000'
    puts "skipping #{cath_id}; obsolete"
    next
  end

  pdb_filename = PDB_root + '/' + cath_id

  #skip if we already have it in the DB
  next if $pdbs.filter(:cath_id => cath_id).count != 0

  if !File.exist?(pdb_filename)
    puts "skipping #{cath_id}; no file at #{pdb_filename}"
    next
  end

  alpha_carbons = open(pdb_filename).read.split("\n")
    .select{|l| l[13...15] == 'CA'}
    .map{|l|
    #lines look like
    #ATOM    582  CA  ASN A  27      -1.946  24.449  21.278  1.00  3.32           C
    {
      :r => [l[30..37].to_f, l[38..45].to_f, l[46..53].to_f], #radial vector
      :seqno => l[22..26].strip.to_i,
      :residue_type => AA_code[l[17..19]]
    }
  }

  #if there are multiple choices for a residue position, take the first
  prev_seqno = nil
  alpha_carbons = alpha_carbons.map{|x|
    if x[:seqno] == prev_seqno
      next
    else
      prev_seqno = x[:seqno]
    end
    x
  }.compact


  #no way I'm dealing with proteins with n > 400 residues
  if alpha_carbons.length > 400
    puts "skipping #{cath_id}; too big #{alpha_carbons.length}"
    next
  end

  #make sure there are no gaps by making sure the first and last line's seqnos add up
  if alpha_carbons[-1][:seqno] - (alpha_carbons[0][:seqno] - 1) != alpha_carbons.length
    puts "skipping #{cath_id}; alpha carbon seqnos for don't add up"
    next
  end

  #the positions of the alpha carbons
  alpha_carbon_rs = alpha_carbons.map{|x| x[:r]}

  n = alpha_carbon_rs.length
  DB.transaction do
    $pdbs.insert(
                 :cath_id => cath_id,
                 :seq => alpha_carbons.map{|x| x[:residue_type]}*'',
                 :c => d[1], :a => d[2], :t => d[3], :h => d[4],
                 :n => n
                 )

    0.upto(n-1).each{|i|
      $ca_coordinates.insert(
                             :cath_id => cath_id,
                             :i => i,
                             :x => alpha_carbon_rs[i][0],
                             :y => alpha_carbon_rs[i][1],
                             :z => alpha_carbon_rs[i][2]
                             )
    }
  end
}
