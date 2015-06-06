class Game
  constructor: (canvas) ->
    @board = new Board()
    @canvas = canvas
    @ctx = @canvas.getContext("2d")
    @interval = setInterval((=> @render()), 100)
    @incr = setInterval((=> @board.add_row()), 1000)
    @colors = [
      "red", "green", "blue", "yellow", "orange", "pink", "purple",
    ]

  render: ->
    scale = parseInt(Math.min(@canvas.width, @canvas.height) / Math.max(@board.size.rows, @board.size.cols))
    [w, h] = [@board.size.cols * scale, @board.size.rows * scale]

    @ctx.fillStyle = "#fff"
    @ctx.fillRect 0, 0, w, h

    for grid in [0 .. @board.size.rows]
      y = grid * scale
      @ctx.beginPath()
      @ctx.moveTo 0, y
      @ctx.lineTo w, y
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "#eee"
      @ctx.stroke()

    for grid in [0 .. @board.size.cols]
      x = grid * scale
      @ctx.beginPath()
      @ctx.moveTo x, 0
      @ctx.lineTo x, h
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "#eee"
      @ctx.stroke()

    @ctx.strokeStyle = "#999"
    @ctx.lineWidth = 1
    @ctx.strokeRect 0, 0, w, h

    row_count = 0
    for row in @board.rows
      col = 0
      y = h - (row_count * scale) - scale
      for piece in row.pieces
        x = col * scale
        if !piece.empty
          @ctx.fillStyle = @colors[piece.value]
          @ctx.fillRect x, y, scale, scale
          @ctx.strokeRect x, y, scale, scale
          @ctx.font = "48px sans-serif"
          @ctx.fillStyle = "#fff"
          @ctx.textAlign = "center"
          @ctx.textBaseline = "middle"
          @ctx.fillText piece.value, x + (scale / 2), y + (scale / 2)
        col++
      row_count++
