class Game
  constructor: (@canvas) ->
    @board = new Board()
    @board.add_pieces()
    @ctx = @canvas.getContext("2d")
    @resize()

    @interval = setInterval @render, 100
    @incr = setInterval @tick, 1000

    $(window).on "resize", @resize
    $(@canvas).on "click", @click

    @colors = ["red", "green", "blue", "yellow", "orange", "pink", "purple"]

  tick: =>
    @board.add_pieces()
    if @lost()
      clearInterval @incr
      @render()
      alert "You lose"

  lost: ->
    for col in @board.cols
      if col.length > @board.size.rows - 1
        return true
    return false

  click: (e) =>
    console.log(e)

  resize: =>
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

  render: =>
    @clear()
    @draw_grid()

    @ctx.font = (@scale * 0.66) + "px sans-serif"
    @ctx.strokeStyle = "#eee"
    @ctx.textAlign = "center"
    @ctx.textBaseline = "middle"

    for i in [0 .. @board.cols.length - 1]
      if @board.cols[i].length
        for j in [0 .. @board.cols[i].length - 1]
          piece = @board.cols[i][j]
          x = i * @scale
          y = @height - (j * @scale) - @scale

          @ctx.fillStyle = @colors[piece.value]
          @ctx.fillRect x, y, @scale, @scale
          @ctx.strokeRect x, y, @scale, @scale
          @ctx.fillStyle = "#fff"
          @ctx.fillText piece.value, x + (@scale / 2), y + (@scale / 2)
