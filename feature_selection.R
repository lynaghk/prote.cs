#Kevin Lynagh
#November 2010
#functions for converting a protein's distance matrix into a reduced dimensional space via simple image resizing
library(EBImage)



get_dm = function(cath_id){
  ca_coordinates = get_ca_coordinates(cath_id)
  #the dist function returns the lower triangle: i < j <= n; distance_matrix[i,j] = dists[n*(i-1) - i*(i-1)/2 + j-i]
  dists = dist(ca_coordinates, method="euclidean")
  n = nrow(ca_coordinates)

  m = matrix(0, nrow=n, ncol=n)
  m[lower.tri(m)] = dists
  return(m + t(m))
}



#returns the lower triangle of a resized distance matrix
get_resized_dm = function(
  cath_id
  , width = 10
  , transform = Vectorize(function(x) min(x, 40)) #default transform is to cutoff the distances at 40 Angstroms
  ){

  m = get_dm(cath_id)
  resized = resize(m, w=width)
  lower = unclass(resized[lower.tri(resized, diag=TRUE)])
  attributes(lower) = NULL
  return(lower)
}
