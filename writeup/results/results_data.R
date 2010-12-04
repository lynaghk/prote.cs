#Kevin Lynagh
#November 2010
#analysis of fold search results

source('header.R')

#which combinations of n_i and s to look at?
trial_sizes = list(
  c(3, 3)
  , c(3, 5)
  , c(3, 10)
  , c(3, 20)
  )

results = llply(trial_sizes, function(d){
  n_i = d[1]
  s = d[2]

  l = llply(seq(4,16,2), function(dm_width){
    res = read.table('tmp/resized_ni' & n_i & '_s' & s & '_dm_width' & dm_width)
    c(top = sum(res$top_correct) / nrow(res)
      , top5 = sum(res$top5_correct) / nrow(res)
      , dimensionality = dm_width*(dm_width+1) / 2
      )
  })

  list(n_i = n_i
       , s = s
       , data = l)
})

#in results_data.js, set DATA.n_i3 = <output from below>
cat(toJSON(results))
