class Game
  constructor: (canvas) ->
    @board = new Board()
    @board.add_row()
    @canvas = canvas
    @ctx = @canvas.getContext("2d")
    @interval = setInterval((=> @render()), 100)
    @incr = setInterval((=> @board.add_row()), 10000)
    @resize()
    $(window).on "resize", (=> @resize())
    @colors = ["red", "green", "blue", "yellow", "orange", "pink", "purple"]

  resize: ->
    @scale = parseInt(Math.min(@canvas.width, @canvas.height) / Math.max(@board.size.rows, @board.size.cols))
    [@width, @height] = [@board.size.cols * @scale, @board.size.rows * @scale]

  clear: ->
    @ctx.fillStyle = "#fff"
    @ctx.fillRect 0, 0, @width, @height

  draw_grid: ->
    @ctx.strokeStyle = "#eee"
    @ctx.lineWidth = 1

    for grid in [0 .. @board.size.rows]
      y = grid * @scale
      @ctx.beginPath()
      @ctx.moveTo 0, y
      @ctx.lineTo @width, y
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "#eee"
      @ctx.stroke()

    for grid in [0 .. @board.size.cols]
      x = grid * @scale
      @ctx.beginPath()
      @ctx.moveTo x, 0
      @ctx.lineTo x, @height
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "#eee"
      @ctx.stroke()

  render: ->
    @clear()
    @draw_grid()

    row_count = 0
    @ctx.font = (@scale * 0.66) + "px sans-serif"
    @ctx.strokeStyle = "#eee"
    @ctx.textAlign = "center"
    @ctx.textBaseline = "middle"

    for row in @board.rows
      col = 0
      y = @height - (row_count * @scale) - @scale
      for piece in row
        x = col * @scale
        if !piece.empty
          @ctx.fillStyle = @colors[piece.value]
          @ctx.fillRect x, y, @scale, @scale
          @ctx.strokeRect x, y, @scale, @scale
          @ctx.fillStyle = "#fff"
          @ctx.fillText piece.value, x + (@scale / 2), y + (@scale / 2)
        col++
      row_count++
