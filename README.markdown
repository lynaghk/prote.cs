      _____              _                     
     |  __ \            | |                    
     | |__) |_ __  ___  | |_  ___     ___  ___ 
     |  ___/| '__|/ _ \ | __|/ _ \   / __|/ __|
     | |    | |  | (_) || |_|  __/ _| (__ \__ \
     |_|    |_|   \___/  \__|\___|(_)\___||___/
                                                   

Prote.cs is a compressed sensing protein fold search algorithm.
It represents protein structures in a vector space using a resized distance matrix, and classifies test proteins by linear regression within a basis derived from proteins with known fold.
For more details, see [http://www.dirigibleFlightcraft.com/prote.cs/](http://www.dirigibleFlightcraft.com/prote.cs/)




Overview
========

The [CATH database](http://www.cathdb.info/wiki/doku.php?id=data:index) provides protein domain structures PDB ATOM format, `CathDomainPdb.v3_3_0.tgz`, and each domain's position in the CATH hiearchy, `CathDomainList`.
The Ruby script in `build_db.rb` was used to import the alpha carbon positions, residue sequence, and CATH hiearchy assignment of suitable proteins into a SQLite database.
Most of the algorithmic work is done is in several `R` files:

`prote.cs.R` main file that performs search experiments and writes results to disk

`header.R` shared infrastructure code (database connection, load packages, &c.)

`domain_selection.R` functions to select protein families and cath_ids

`feature_selection.R` calculate, resize, and stack a protein's distance matrix


The Octave/Matlab reconstruction script, `l1l2.m`, uses YALL1 to perform the actual vector reconstruction.




Install
=======

YALL1 is included as a git submodule; you can get it with

    git submodule init --update

You'll need a copy of Octave as well.

The Ruby import script uses the `sequel` gem to access SQLite and can be installed by

    gem install sequel

Required R packages can also be installed in the usual way
  
    install.packages('plyr', 'RSQLite', ...)

with the exception of EBimage, which doesn't live on CRAN; use

    source("http://bioconductor.org/biocLite.R")
    biocLite("EBImage")
