class Piece
  constructor: (max) ->
    @dragging = false
    @empty    = false

    if Math.random() > 0.5
      @value = 0
      @empty = true
    else
      @value = Math.ceil(Math.random() * max)

  drag: (event) ->
    @dragging = true
    
  matches: (value) ->
    return value == @value
