#Main file for the prote.cs overview that wires together the components on the page


class Dm_3d_presenter
  constructor: (@dispatcher, @protein, @dm_view, @protein_view) ->
    @uid = _.uniqueId 'Dm_3d_presenter_'
    @_handlers =
      dm_mousemove: (e, d) -> @protein_view.highlight_pair d.i, d.j
      dm_mouseout: (e, d) -> @protein_view.unhighlight()

    @dispatcher.register this, @_handlers

  init: ->
    @dm_view.draw_dm @protein.distance_matrix()
    @protein_view.draw_backbone @protein.alpha_carbon_coordinates()


$(document).ready ->
  dispatcher = new Dispatcher

  ##################################
  #distance matrix and Three.js view
  #

  a_protein = new Protein
    cath_id: '1beaA00'
    atoms: DATA.ca_1beaA00

  $dm = $('#dm_example')
  dm_view = new Distance_matrix_view dispatcher, $dm

  $dm_3d = $('#dm_3d')
  protein_view = new Protein_view dispatcher, $dm_3d

  presenter = new Dm_3d_presenter dispatcher, a_protein, dm_view, protein_view
  presenter.init()


  #############################
  #colored dictionary example

  $dict = $('#dictionary')
  dict_view = new Dictionary_view dispatcher, $dict
  dict_view.draw_dictionary DATA.resized_dms
