colors = []
step = Math.floor 16777215 / 20
for color in [1 .. 20]
  colors.push "#" + (step * color).toString(16)

class Game
  constructor: (@canvas) ->
    @dragging = null
    @lastmouse = [0,0]
    @board = new Board()
    @ctx = @canvas.getContext("2d")
    @render = @default_render
    @resize()

    @interval_time = 5000
    @tick()

    $(window).on "resize", @resize

    @canvas.addEventListener (if Modernizr.touch then "touchstart" else "mousedown"), @mousedown
    @canvas.addEventListener (if Modernizr.touch then "touchend" else "mouseup")  , @mouseup


  tick: =>
    @board.add_pieces()
    @render()
    if @lost()
      alert "You lose"
    else
      @interval_time *= 0.95
      setTimeout @tick, @interval_time

  lost: ->
    for col in @board.cols
      if col.length > @board.size.rows - 1
        return true
    return false

  event_coord: (e) ->
    offset = $(@canvas).offset()
    [x, y] = @translated_touch(e)
    left = x - offset.left
    top = @height - (y - offset.top)
    col = Math.floor left / @scale
    row = Math.floor top / @scale
    return [col, row]

  mouseup: (e) =>
    e.preventDefault()
    [col, row] = @event_coord e

    if @board.cols[col][row]
      piece = @board.cols[col][row]
      if piece.matches @dragging
        piece.value++
        if piece.value > @max
          @max = piece.value

        for x in [0 .. @board.cols.length - 1]
          for y in [0 .. @board.cols[x].length - 1]
            if @board.cols[x][y] is @dragging
              @board.cols[x].splice(y, 1)

    $(@canvas).off "mousemove"

    if @dragging
      @dragging.dragging = false
      @dragging = null

    @render = @default_render
    @render()

  translated_touch: (e) ->
    if e.pageX
      return [e.pageX, e.pageY]
    else if e.targetTouches
      return [e.targetTouches[0].pageX, e.targetTouches[0].pageY]

  mousedown: (e) =>
    e.preventDefault()
    [col, row] = @event_coord e
    if @board.cols[col][row]
      piece = @board.cols[col][row]
      piece.dragging = true
      @dragging = piece

      [x, y] = @translated_touch(e)
      offset = $(@canvas).offset()
      left = (x - offset.left) % @scale
      top = (y - offset.top) % @scale
      @render = @dragging_render left, top

      $(@canvas).on "mousemove", @render

  resize: =>
    @scale = parseInt(Math.min(window.innerWidth, window.innerHeight) / Math.max(@board.size.rows, @board.size.cols))
    [@width, @height] = [@board.size.cols * @scale, @board.size.rows * @scale]
    @canvas.width = @width
    @canvas.height = @height
    @render()

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

  dragging_render: (offset_left, offset_top) ->
    (e) =>
      @default_render()
      # capture mouse position if render is called
      # outside of the drag event (e.g. tick)
      if e
        @lastmouse = @translated_touch(e)
      if @dragging
        offset = $(@canvas).offset()
        left = @lastmouse[0] - offset.left
        top = @lastmouse[1] - offset.top
        @draw_tile @dragging, left - offset_left, top - offset_top

  draw_tile: (piece, x, y) ->
    @ctx.fillStyle = colors[piece.value]
    @ctx.fillRect x, y, @scale, @scale
    @ctx.strokeRect x, y, @scale, @scale
    @ctx.fillStyle = "#fff"
    @ctx.fillText piece.value, x + (@scale / 2), y + (@scale / 2)

  default_render: ->
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
          if !piece.dragging
            x = i * @scale
            y = @height - (j * @scale) - @scale
            @draw_tile piece, x, y
