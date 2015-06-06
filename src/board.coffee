class Board
  constructor: ->
    @max  = 2
    @size = {cols: 8, rows: 8}
    @rows = @empty_board()

  empty_board: ->
    rows = []
    for i in [0 .. @size.rows - 1]
      row = []
      for j in [0 .. @size.cols - 1]
        row.push new Piece(@max, true)
      rows.push row
    return rows

  add_row: ->
    for col in [0 .. @size.cols - 1]
      piece = new Piece(@max)
      if !piece.empty && @rows.length > 0
        for i in [1 .. @rows.length - 1]
          row = @rows.length - i
          @rows[row][col] = @rows[row - 1][col]
        @rows[0][col] = piece
