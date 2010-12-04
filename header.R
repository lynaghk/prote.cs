#Kevin Lynagh
#October 2010

library(plyr)
library(RSQLite)
library(RSQLite.extfuns)
library(RJSONIO)
db_con = dbConnect(
  dbDriver("SQLite")
  , dbname = '/data/pdbs.db'
  , loadable.extensions = TRUE)

#provides SQLite with mean, std. deviation functions, &c.
init_extensions(db_con)

#infix string concatenation hack
"&" = function(...) UseMethod("&")
"&.default" = .Primitive("&")
"&.character" = function(...) paste(..., sep="")
"&.numeric" = function(...) paste(..., sep="")
p = function(x){
  cat(x & "\n")
  flush.console()
}

get_ca_coordinates = function(cath_id) dbGetQuery(db_con, "SELECT x,y,z FROM ca_coordinates WHERE cath_id = '" & cath_id & "' ORDER BY i")
get_sequence = function(cath_id) dbGetQuery(db_con, "SELECT seq FROM pdbs WHERE cath_id = '" & cath_id & "'")


#l2 normalize the rows/cols of a matrix
l2_norm = function(x) sqrt(t(x) %*% x)
row_l2_unity = function(m) t(apply(m, 1, function(row) row / l2_norm(row)))
col_l2_unity = function(m) apply(m, 2, function(col) col / l2_norm(col))

#entropy of a vector
entropy = function(v){
  p = v/sum(v)
  sum(-p * log(p))
}
#percentage of a vector that is one or TRUE
percent_one = function(x) sum(x) / length(x)
