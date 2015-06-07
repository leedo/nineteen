class Piece
  constructor: (max) ->
    @dragging = false
    # pixel positions (not board index)
    @pos = {x: 0, y: 0}
    @is_match = false
    @is_miss = false
    @value = Math.ceil(Math.random() * max)

  drag: (event) ->
    @dragging = true

  matches: (piece) ->
    return piece and piece isnt this and piece.value == @value
