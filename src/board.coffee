class Board
  constructor: ->
    @max  = 2
    @size = {cols: 8, rows: 8}
    @rows = []
    this.add_row()

  add_row: ->
    row = new Row(@size.cols, @max)
    @rows.unshift row
