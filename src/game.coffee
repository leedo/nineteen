class Game
  constructor: (canvas) ->
    @board = new Board()
    @board.add_pieces()
    @canvas = canvas
    @ctx = @canvas.getContext("2d")
    console.log @board.cols
    @interval = setInterval((=> @render()), 100)
    @incr = setInterval((=> @board.add_pieces()), 1000)
    @resize()
    $(window).on "resize", (=> @resize())
    $(@canvas).on "click", ((e)=> @click(e))
    @colors = ["red", "green", "blue", "yellow", "orange", "pink", "purple"]

  click: (e) ->
    console.log(e)

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

    @ctx.font = (@scale * 0.66) + "px sans-serif"
    @ctx.strokeStyle = "#eee"
    @ctx.textAlign = "center"
    @ctx.textBaseline = "middle"

    for i in [0 .. @board.cols.length - 1]
      col = @board.cols[i]
      x = i * @scale
      if col.length
        for j in [0 .. col.length - 1]
          piece = col[j]
          y = @height - (j * @scale) - @scale
          if piece
            @ctx.fillStyle = @colors[piece.value]
            @ctx.fillRect x, y, @scale, @scale
            @ctx.strokeRect x, y, @scale, @scale
            @ctx.fillStyle = "#fff"
            @ctx.fillText piece.value, x + (@scale / 2), y + (@scale / 2)
