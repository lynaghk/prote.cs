#Kevin Lynagh
#November 2010
#main function for compressed sensing protein fold determination
source('header.R')
source('domain_selection.R')
source('feature_selection.R')


#We're using YALL1 for basis pursuit, which is written for Matlab/Octave.
#Since we'll be solving a lot of problems, give them all at once to minimize low-brow, disk writing calls
YALL1_solve = function(A, bs){
  write.table(A, "tmp/A.mat", row.names=FALSE, col.names=FALSE)
  write.table(bs, "tmp/bs.mat", row.names=FALSE, col.names=FALSE)
  system("octave --silent --eval 'run l1l2; exit'")
  xs = as.matrix(read.table("tmp/xs.mat"))
  return(xs)
}

#given a dataframe with a 'cath_id' column, return a matrix whose columns are stacked, resized distance matricies
get_dictionary = function(domains
  , dm_width = 10 #width of resized distance matrix
  , normalize_dictionary_columns = TRUE
  #default transformation for the distance matrix is
  , transform = Vectorize(function(x) min(x, 40))
  ){
  n = nrow(domains)

  #preallocate the dictionary matrix
  D = matrix(0
    , ncol = n
    , nrow = dm_width*(dm_width + 1) / 2)

  for(j in 1:n){
    if(j%%50 == 0) p(j)
    D[,j] = get_resized_dm(domains[j, 'cath_id']
       , width=dm_width
       , transform=transform)
  }

  if(normalize_dictionary_columns) D = col_l2_unity(D)

  return(D)
}



#given a dataframe with a 'cath_id' column and a corresponding dictionary matrix, test the fold search procedure
fold_search = function(
  domains #data frame returned by 'find_domains'
  , D #dictionary consisting whose columns are represent the domains (in the same order)
  , iterations = 5 #how many random samplings and tests should we run?
  ){
  n = nrow(domains)

  classes = factor(domains[,'cat'])
  k = length(levels(classes))

  results = ldply(1:iterations, function(i){

    #randomly select one domain from each class to hold out
    js = ddply(cbind(domains, i=1:nrow(domains)), .(cat), function(d) c(j=sample(d$i, 1)))$j

    #seperate the test vectors (bs) from the test dictionary matrix
    bs = D[,js]
    A = D[,-js]

    #call octave to attempt to reconstruct each test vector using A
    xs = YALL1_solve(A, bs)

    #preallocate a matrix to store the residuals for each class for each sample
    residualses = matrix(0, nrow=k, ncol=length(js))

    #calculate the residual for each class for each vector
    for(j in 1:length(js)){
      if(j%%50 == 0) p(j)
      residualses[,j] = sapply(levels(classes), function(class_id){
        in_class = which(classes[-js] == class_id)
        #since we're zeroing all the elements of x outside of the class, we can explicitly sparse multiply A*delta_class(x) for efficiency
        l2_norm( bs[,j] - (A[,in_class] %*% xs[in_class,j]) )
      })
    }

    result = ldply(1:length(js), function(j){
      correct_class = classes[js[j]]
      ranks = rank(residualses[,j])
      top5_classes  = levels(classes)[ ranks <= 5 ]

      data.frame(
                 cath_id = domains[js[j],'cath_id']
                 , cat = domains[js[j],'cat']
                 , top_correct = correct_class == levels(classes)[ranks == 1]
                 , top5_correct = correct_class %in% top5_classes
                 , entropy = entropy(residualses[,j])
                 )
    })
    #print the result of this iteration
    p(sum(result$top_correct) / nrow(result))
    #return the result of this run
    return(result)
  })

  #return the results of all runs
  return(results)
}




#which combinations of ni and s should we run?
trial_sizes = list(
  c(10, 20)
  , c(10, 10)
  , c(3, 3)
  , c(3, 5)
  , c(3, 10)
  , c(3, 20)
  )

lapply(trial_sizes, function(d){
  n_i = d[1] #how many domains must a fold family have?
  s = d[2] #what is the maximum number of samples to work with?

  domains = find_domains(n_i = n_i)
  length(unique(domains$cat)) #how many unique CAT families did we get?
  sampled_domains = ddply(domains, .(cat), function(d){
    data.frame(cath_id = sample(d$cath_id, min(s, length(d$cath_id))))
  })

  for(dm_width in seq(4, 16, 2)){
    p('constructing dictionary with n_i = ' & n_i & ' s = ' & s & ' (' & nrow(sampled_domains) & ' proteins)')
    p('dm_width ' & dm_width)

    #play it safe and skip a run if a results file already exists
    result_filename = 'tmp/resized_ni' & n_i & '_s' & s & '_dm_width' & dm_width
    if(!file.exists(result_filename)){
      print(system.time({
        res = fold_search(sampled_domains
          , get_dictionary(sampled_domains, dm_width = dm_width)
          , iterations = 5)
      }))

      write.table(res, result_filename)
      p("=====================================")
      p(dm_width)
      p(sum(res$top_correct) / nrow(res))
      p("=====================================")
    }
  }
})
