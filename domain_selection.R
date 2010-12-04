# Kevin Lynagh
# October 2010
# select CATH domain families

source('header.R')

#find suitable families
families = dbGetQuery(db_con, "
SELECT
(c ||'.'|| a ||'.'|| t) as cat
, count(*) as count
, median(n) as median
, avg(n) as mean
, stdev(n) as sd
FROM pdbs
GROUP BY cat
")

find_domains = function(
  n_i = 5 #how many domains we want each family to have
  , seq_length = c(100, 400) #length bounds on median
  ){

  sample = subset(families,
    count >= n_i
    & median >= seq_length[1]
    & median <= seq_length[2]
    )

  domains = dbGetQuery(db_con, "
SELECT (c ||'.'|| a ||'.'|| t) AS cat
, cath_id
FROM pdbs
WHERE (c ||'.'|| a ||'.'|| t) IN (" & paste("'", sample$cat, "'", sep='', collapse=',') & ")
")
domains$cat = factor(domains$cat)
return(domains)
}
