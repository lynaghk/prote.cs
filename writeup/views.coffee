class Distance_matrix_view extends View
  constructor: (@dispatcher, @$container) ->
    @$canvas = $('<div>').appendTo @$container
    super


  draw_dm: (dm, scale) ->
    @scale = scale || @$canvas.width() / dm.length
    h = w = dm.length
    @vis = new pv.Panel()
    .width(w*@scale)
    .height(h*@scale)
    .margin(0)
    .strokeStyle("#aaa")
    .lineWidth(1)
    .antialias(false)

    dm_image = @vis.add(pv.Image)
    .imageWidth(w).imageHeight(h)
    .cursor('crosshair')
    .antialias(false)
    .image pv.Scale.linear()
      .domain(0, 40)
      .range('black', 'white')
      .by (i, j) -> dm[i][j]

    self = @
    dm_image.event 'mousemove', ->
      #get the browser click event from protovis so we can calculate the cell clicked on via the canvas offsets
      e = pv.event
      [i, j] = [e.offsetY, e.offsetX].map (offset) -> Math.floor offset / self.scale
      self.trigger 'dm_mousemove', {i: i, j: j}

    dm_image.event 'mouseout', -> self.trigger 'dm_mouseout'
    @vis.canvas(@$canvas[0]).render()

window.Distance_matrix_view = Distance_matrix_view



#Displays a protein backbone on a Three.js canvas
class Protein_view extends View
  constructor: (@dispatcher, @$container) ->

    @scene = new THREE.Scene
    @renderer = new THREE.CanvasRenderer
    @renderer.setSize @$container.width(), @$container.height()
    @$container.append @renderer.domElement

    @camera = new THREE.Camera 70, @$container.width() / @$container.height(), 1, 10000
    @theta = 0
    @camera_r = 35


    @backbone = null #the protein backbone model
    @atoms = null #the original atoms passed
    @residue_pair_line = null #a line connecting two residues through space
    @centre_translation = [0,0,0] #an offset to translate each new model by; we centre the first backbone added for visual nicety.
    self = this
    setInterval (-> self.render() ), 20
    super

  draw_backbone: (atoms) ->
    @atoms = atoms
    geometry = new THREE.Geometry()
    centre = @compute_centre @atoms
    @centre_translation = new THREE.Vector3 centre[0], centre[1], centre[2]
    self = @
    @atoms.forEach (a) ->
      vec = new THREE.Vector3(a[0], a[1], a[2]).subSelf self.centre_translation
      geometry.vertices.push new THREE.Vertex(vec)
    backbone = new THREE.Line geometry, new THREE.LineBasicMaterial
      color: 0x000000
      linewidth: 5


    @backbone = backbone
    @scene.addObject @backbone

  #draws a line between two residues
  highlight_pair: (i,j) ->
    @unhighlight() if @residue_pair_line?
    geometry = new THREE.Geometry()
    self = @
    vecs = [@atoms[i], @atoms[j]].map (a) ->
      new THREE.Vector3(a[0], a[1], a[2]).subSelf self.centre_translation

    #instead of going directly between the two points, alter the vectors a bit so we have some margin
    difference = vecs[0].clone().subSelf(vecs[1]).setLength 1
    vecs[0].subSelf difference
    vecs[1].addSelf difference

    vecs.forEach (v) -> geometry.vertices.push new THREE.Vertex v
    highlight_vec = new THREE.Line geometry, new THREE.LineBasicMaterial
      color: 0x22FFFF
      linewidth: 3
    @residue_pair_line = highlight_vec
    @scene.addObject @residue_pair_line

  unhighlight: ->
    @scene.removeObject @residue_pair_line


  #calculate the centroid of an array of points
  compute_centre: (points) ->
    sum = [0,0,0]
    points.forEach (point) ->
      sum[0] += point[0]
      sum[1] += point[1]
      sum[2] += point[2]

    n = points.length
    sum.map (e) -> e/n


  remove_model: (model_id) ->
    model = @models[model_id]
    if model?
      @scene.removeObject model

  render: ->
    self = this
    @theta += 0.002
    @camera.position.z = @camera_r * Math.sin(@theta)
    @camera.position.x = @camera_r * Math.cos(@theta)
    @renderer.render @scene, @camera


window.Protein_view = Protein_view

















class Dictionary_view extends View
  constructor: (@dispatcher, @$container) ->
    @$canvas = $('<div>').appendTo @$container
    super

  #helper function for drawing little distance matrices in the mouseover
  draw_lil_dm: (lower_triangle, $canvas) ->
    w = 60
    h = 60
    #dm width (thanks quadratic formula!)
    n = 0.5*(-1 + Math.sqrt(1+8*lower_triangle.length))
    max = _(lower_triangle).chain().flatten().max().value()
    block_size = 6
    grayscale = pv.Scale.linear()
      .domain(0, max)
      .range('black', 'white')

    vis = new pv.Panel()
      .width(w)
      .height(h)
      .strokeStyle("#aaa")
      .lineWidth(1)
      .antialias(false)

    dm_image = vis.add(pv.Image)
    .cursor('crosshair')
    .imageWidth(n*block_size).imageHeight(n*block_size)
    .image (i,j) ->
      i = Math.floor i/block_size
      j = Math.floor j/block_size
      [i,j] = [j,i] if j>=i
      grayscale if i == j then max else lower_triangle[n*i - (i+1)*i/2 + j-i]

    vis.canvas($canvas[0]).render()


  draw_dictionary: (dict) ->

    #make a fat matrix organized by classes: [ [ columns of class 1 ] , [ columns of class 2 ], ...]
    mat = dict.map (family) ->
      family.dms.map (dm_obj) -> dm_obj.dm

    block_size = 9
    w = _(mat).chain().map( (cols) -> cols.length ).reduce((a,b) -> a+b).value()
    h = mat[0][0].length
    max = _(mat).chain().flatten().max().value()
    grayscale = pv.Scale.linear()
    .domain(0, max)
    .range('black', 'white')

    @vis = new pv.Panel()
    .width(w*block_size)
    .height(h*block_size)
    .margin(0)
    .strokeStyle('black')
    .lineWidth(5)

    family_blocks = @vis.add(pv.Panel)
    .data(mat)
    .left( -> #offset each family by the number of columns that have come before it
      offset = 0
      pv.range(0, this.index).forEach (j) -> offset += mat[j].length
      offset*block_size
    )
    .width( (d) -> d.length*block_size)
    .height( (d) -> d[0].length*block_size)
    .add(pv.Image)
    .cursor('crosshair')
    .antialias(false)
    .image (j,i, mat) ->
      i = Math.floor i/block_size
      j = Math.floor j/block_size
      grayscale mat[j][i]

    self = @
    mouseoverlay = family_blocks.add(pv.Panel)
    .def('alpha', 0.3)
    .fillStyle( ->
      pv.Colors.category10().range()[this.parent.index]
      .alpha(this.alpha())
    )
    .event 'mousemove', ->
      #we need a different tooltip for each cath family; only mess with the DOM if we've switched families
      family_i = this.parent.index
      if self.$tt.data('family_i') != family_i
        self.$tt.data 'family_i', family_i

        #create the mouseover box
        $contents = $('<div>')
        $contents.append $("<span>CATH topology: #{dict[family_i].cat}</span>").css('font-size': '24px')

        dict[family_i].dms.forEach (dm_obj) ->
          $lil_dm_box = $('<div>', class: 'lil_dm_box')
          $lil_dm = $('<div>').appendTo $lil_dm_box
          $lil_dm_box.append $('<span>').text dm_obj.cath_id
          self.draw_lil_dm dm_obj.dm, $lil_dm
          $contents.append $lil_dm_box


      self.show_tooltip
        x: pv.event.pageX
        y: pv.event.pageY
        $: $contents
      this.alpha(0.7)

    .event 'mouseout', ->
      self.hide_tooltip()
      this.alpha(undefined)

    .event 'click', ->
      family_i = this.parent.index
      window.open "http://www.cathdb.info/cathnode/#{dict[family_i].cat}"

    @vis.canvas(@$canvas[0]).render()

window.Dictionary_view = Dictionary_view
