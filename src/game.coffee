colors = []
step = Math.floor 16777215 / 20
for color in [1 .. 20]
  colors.push "#" + (step * color).toString(16)

class Game
  constructor: (@canvas) ->
    @match = null
    @miss = null
    @dragging = null
    @dragging_offset = {x:0,y:0}
    @dirty_drag = false
    @dirty_drag_reset = null

    @board = new Board()
    @ctx = @canvas.getContext("2d")
    @render = @default_render
    @touch = Modernizr.touch
    @resize()

    @interval_time = 6000
    @tick()

    window.addEventListener "resize", @resize
    @canvas.addEventListener (if @touch then "touchstart" else "mousedown"), @mousedown
    @canvas.addEventListener (if @touch then "touchend" else "mouseup")  , @mouseup

    # stop fucky scrolls on touch
    if @touch
      window.addEventListener "touchstart", (e) -> e.preventDefault()


  tick: =>
    @board.add_pieces()
    @render()
    if @lost()
      alert "You lose"
    else
      @interval_time *= 0.99
      setTimeout @tick, @interval_time

  lost: ->
    for col in @board.cols
      if col.length > @board.size.rows - 1
        return true
    return false

  coord_index: (pos) ->
    left = pos.x - @dragging_offset.x
    top = @height - (pos.y - @dragging_offset.y)
    left = Math.min(Math.max(left), @width)
    top = Math.min(Math.max(top), @height)
    col = Math.floor left / @scale
    row = Math.floor top / @scale
    return [col, row]

  mouseup: (e) =>
    e.preventDefault()
    [col, row] = @coord_index(@translated_touch(e))

    @clear_states()

    if @dirty_drag
      @dirty_drag = false
      @dirty_drag_reset = null
    else if @board.cols[col][row]
      piece = @board.cols[col][row]
      if piece.matches @dragging
        piece.value++
        if piece.value > @board.max
          @board.max = piece.value

        for x in [0 .. @board.cols.length - 1]
          for y in [0 .. @board.cols[x].length - 1]
            if @board.cols[x][y] is @dragging
              @board.cols[x].splice(y, 1)

    @canvas.removeEventListener (if @touch then "touchmove" else "mousemove"), @render

    if @dragging
      @dragging.dragging = false
      @dragging.is_miss = false
      @dragging.is_match = false
      @dragging = null

    @render = @default_render
    @render()

  translated_touch: (e) ->
    if e.targetTouches and e.targetTouches[0]
      return {x: e.targetTouches[0].pageX, y: e.targetTouches[0].pageY}
    else if e.pageX
      return {x: e.pageX, y: e.pageY}

  mousedown: (e) =>
    e.preventDefault()
    [col, row] = @coord_index(@translated_touch(e))
    if @board.cols[col][row]
      piece = @board.cols[col][row]
      piece.dragging = true
      @dragging = piece

      @dragging.pos = @translated_touch(e)
      left = (@dragging.pos.x - @dragging_offset.x) % @scale
      top = (@dragging.pos.y - @dragging_offset.y) % @scale
      @render = @dragging_render left, top

      @canvas.addEventListener (if @touch then "touchmove" else "mousemove"), @render

  resize: =>
    scaley = parseInt(window.innerHeight / @board.size.rows)
    scalex = parseInt(window.innerWidth / @board.size.cols)

    if window.innerWidth > window.innerHeight
      if scaley * @board.size.cols <= window.innerWidth
        @scale = scaley
      else
        @scale = scalex
    else
      if scalex * @board.size.rows <= window.innerHeight
        @scale = scalex
      else
        @scale = scaley

    [@width, @height] = [@board.size.cols * @scale, @board.size.rows * @scale]
    [@canvas.width, @canvas.height] = [@width, @height]
    @dragging_offset = {x: @canvas.offsetLeft, y: @canvas.offsetTop}
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

  clear_states: ->
    if @match
      @dragging.is_match = false
      @match.is_match = false
      @match = null

    if @miss
      @dragging.is_miss = false
      @miss.is_miss = false
      @miss = null

  dragging_render: (offset_left, offset_top) ->
    (e) =>
      @default_render()
      # capture mouse position if render is called
      # outside of the drag event (e.g. tick)
      if @dragging
        if e
          pos = @translated_touch(e)
          if @is_safe_pos(pos)
            @dirty_drag = false
            @dragging.pos = pos
          else
            @dirty_drag_reset = @coord_index(@dragging.pos)
            @dirty_drag = true

        left = @dragging.pos.x - @dragging_offset.x
        top = @dragging.pos.y - @dragging_offset.y
        @draw_tile @dragging, left - offset_left, top - offset_top

  is_safe_pos: (pos) ->
    [col, row] = @coord_index(pos)

    if @dirty_drag
      if @dirty_drag_reset[0] == col and @dirty_drag_reset[1] == row
        return true
      else
        return false

    @clear_states()

    if !@board.cols[col][row] or @board.cols[col][row] is @dragging
      return true

    if @dragging.matches(@board.cols[col][row])
      @match = @board.cols[col][row]
      @match.is_match = true
      @dragging.is_match = true
      return true
    else
      @miss = @board.cols[col][row]
      @miss.is_miss = true
      @dragging.is_miss = true

    return false

  draw_tile: (piece, x, y) ->
    if piece.is_match && !piece.dragging
      @ctx.lineWidth = 3
      @ctx.strokeStyle = "#7fff00"
    else if piece.is_miss && !piece.dragging
      @ctx.lineWidth = 3
      @ctx.strokeStyle = "red"
    else
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "#eee"

    if piece.dragging and (piece.is_miss or piece.is_match)
      @ctx.globalAlpha = 0.5
    else
      @ctx.globalAlpha = 1

    @ctx.fillStyle = colors[piece.value]
    @ctx.fillRect x, y, @scale, @scale
    @ctx.strokeRect x, y, @scale, @scale
    @ctx.fillStyle = "#fff"
    @ctx.fillText piece.value, x + (@scale / 2), y + (@scale / 2)

    @ctx.globalAlpha = 1

  default_render: ->
    @clear()
    @draw_grid()

    @ctx.font = (@scale * 0.66) + "px sans-serif"
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
