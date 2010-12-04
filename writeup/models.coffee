#This class models an individual protein structure and has methods for calculating the distance matrix

class Protein
  constructor: (data_obj) ->
    #just copy all fields
    $.extend this, data_obj
    @n = @atoms.length

    #build and cache the distance matrix
    @dm = null
    @distance_matrix()

  alpha_carbon_coordinates: -> @atoms

  distance_matrix: ->
    if @dm?
      @dm
    else
      points = @atoms
      @dm = [0..@n-1].map -> []
      for i in [0..@n-1]
        for j in [i..@n-1]
          @dm[i][j] = @dm[j][i] = distance points[i], points[j]
    @dm
window.Protein = Protein


distance = (p1, p2) ->
  #Three dimensions only please, kthx.
  Math.sqrt Math.pow(p1[0] - p2[0], 2) + Math.pow(p1[1] - p2[1], 2) + Math.pow(p1[2] - p2[2], 2)
