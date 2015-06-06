class Row
  constructor: (cols, max) ->
    @pieces = (new Piece(max) for [1 .. cols])
