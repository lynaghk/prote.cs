


#function that'll create a dot with the chart color for in the text
window.dot = (i) ->
  new pv.Panel()
  .width(10)
  .height(10)
  .anchor("center").add(pv.Dot)
  .strokeStyle(null)
  .fillStyle(pv.Colors.category20().range()[i])
  .radius(4)
  .root.render()


$(document).ready ->
  dispatcher = new Dispatcher

  ############################
  #build graphs to display results
  $div = $('<div>').appendTo $('#results_scatterplot')

  scatterplot = new Results_scatterplot dispatcher, $div
  scatterplot.draw _.flatten(DATA.n_i3), {
    width: 420
    height: 400
  }



