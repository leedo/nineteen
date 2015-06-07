class Piece
  constructor: (max) ->
    @dragging = false
    @value = Math.ceil(Math.random() * max)

  drag: (event) ->
    @dragging = true

  matches: (piece) ->
    return piece isnt this && piece.value == @value
