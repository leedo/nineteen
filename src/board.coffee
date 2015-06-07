class Board
  constructor: ->
    @max  = 2
    @size = {cols: 7, rows: 10}
    @cols = @empty_board()

  empty_board: ->
    cols = []
    for i in [0 .. @size.cols - 1]
      cols.push []
    return cols

  add_pieces: ->
    for col in @cols
      if Math.random() > 0.5
        col.unshift(new Piece(@max))
