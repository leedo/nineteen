class Piece
  constructor: (max) ->
    @dragging = false
    # pixel positions (not board index)
    @pos = {x: 0, y: 0}
    @is_match = false
    @value = Math.ceil(Math.random() * max)

  drag: (event) ->
    @dragging = true

  matches: (piece) ->
    return piece isnt this && piece.value == @value
