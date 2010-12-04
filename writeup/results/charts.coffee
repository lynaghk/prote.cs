class Results_scatterplot extends View
  constructor: (@dispatcher, @$container) ->
    @$canvas = $('<div>', class: 'pv_canvas').appendTo @$container
    super

  #data in the form of
  #[{expt_descr: text, data: {top: float, top5: float, dimensionality: int}]

  #data in the form of
  # [{top: float, dimensionality: int, ni: int, s: int}]

  draw: (data, o) ->
    o = _(@pv_defaults).extend o

    # data = pv.nest(data)
    # .key((d) -> [d.ni, d.s])
    # .entries()

    max_x = 140
    max_y = 1

    x = pv.Scale.linear(0,max_x).range(0, o.width).nice()
    y = pv.Scale.linear(0,max_y).range(0, o.height).nice()

    @vis = new pv.Panel()
    .width(o.width).height(o.height)
    .margin(o.label_margin + o.label_size*4)

    @vis.add(pv.Rule)
    .data(y.ticks())
    .bottom(y)
    .strokeStyle('lightGray')
    .anchor("left").textMargin(o.label_margin)
    .add(pv.Label)
    .text((d) -> parseInt(d*100) + '%')
    .font("#{o.label_size}pt sans-serif")

    @vis.add(pv.Rule)
    .bottom(0)
    .data([0].concat _(data[0].data).pluck('dimensionality'))
    .left(x)
    .strokeStyle('lightGray')
    .anchor('bottom').textMargin(o.label_margin)
    .add(pv.Label)
    .text(x.tickFormat)
    .font("#{o.label_size}pt sans-serif")

    colors = pv.Colors.category20().range()

    lines = @vis.add(pv.Panel)
    .data(data)
    .add(pv.Line)
    .data((d) -> d.data)
    .left( (d) -> x d.dimensionality )
    .bottom( (d) -> y d.top )
    .strokeStyle( (d) -> colors[this.parent.index])
    .lineWidth(2)

    dots = lines
    .add(pv.Dot)
    .radius(3)
    .fillStyle( -> this.strokeStyle())

    legend = @vis.add(pv.Dot)
    .data(data)
    .left(220)
    .top( -> 360 - this.index * 24 )
    .strokeStyle(null)
    .radius(8)
    .fillStyle((d) -> colors[this.index])
    .anchor("right")
    .add(pv.Label)
    .font("18px sans-serif")
    .textMargin(10)
    .text( (d) ->
      (if d.s == 3 then '' else 'max ') +
      "#{d.s} samples/fold"
    )
    @vis.canvas(@$canvas[0]).render()
window.Results_scatterplot = Results_scatterplot
