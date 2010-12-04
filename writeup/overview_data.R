#Kevin Lynagh
#November 2010
#Create/export data for the prote.cs overview page

#set the working directory to the project root, load the header
setwd('../../')
source('header.R')
source('feature_selection.R')

#find some random families by playing around with queries like
dbGetQuery(db_con, "
SELECT cath_id, a,t FROM pdbs
WHERE c = '2'
AND a = '30'
AND n > 100
LIMIT 500
")

#cool, I found some...
cath_ids = c(
  # cat 1.10.8
  '1c1kA01','1ksfX05','1g41A03','1ofhA02'
  # cat 2.30.29
  ,'1uprA00','2d9yA00','1eazA00','1ntyA02','2p8vA00'
  # cat 3.10.20
  ,'1d4bA00','1xo3A00','1krhA01','2bt6B00'
  # cat 1.20.58
  , '2spcA00', '1u5pA01', '1cunA02'
  # cat 2.30.29
  , '1qqgB01','1btkB00','2bcjA05','1bakA00','1rrpB00'
  # cat 2.30.42
  , '1n7tA00','2i1nA00','1v5lA00','1wf8A00','3cbxA00','3cc0A00'
  # cat 2.30.60
  , '1v62A00','1um1A00','2dluA00','1vaeA00','1uewA00','1ueqA00','1x5nA00','1uf1A00','1v6bA00','1i16A00'
  # cat 3.20.20
  , '2dikA04','1ggoA04','1jdeA04','2r82A06','1vbgA06','1vbhA06','1h6zA04','2olsA04','1n55A00','1qdsA00','1if2A00'
  )


domains = dbGetQuery(db_con, "SELECT
cath_id
, (c ||'.'|| a ||'.'|| t) AS cat
FROM pdbs
WHERE cath_id IN (" & paste("'", cath_ids, "'", sep='', collapse=',') & ")")

dms = dlply(domains, .(cat), function(d){
  list(cat = d$cat[1]
       ,dms =
       lapply(d$cath_id, function(cath_id){
         dm = get_resized_dm(cath_id, width=7)
         dm = dm / l2_norm(dm)
         list(cath_id = cath_id, dm = dm)
       })
       )
})

#print out a JSON dictionary (I manually copied this to data.js)
cat(toJSON(dms, digits=4))
