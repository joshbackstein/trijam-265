-- this is the lua source
function _init()
  playfield_size = 80
  playfield = {
    x = 127 - playfield_size,
    y = 127 - playfield_size,
  }

  bar_max_fill = playfield.x - 4
  bar_decay_frames = 4
  bar_state = {
    filled = 0,
    frames_till_decay = 0
  }

  current_beastie = 1
  beasties = {}

  -- temp vars
  color = 10
  beasties_created = 0
end

function _update60()
  local beasties_to_delete = {}
  for b in all(beasties) do
    b.lifetime -= 1
    if b.lifetime <= 0 then
      add(beasties_to_delete, b)
    end
  end

  for b in all(beasties_to_delete) do
    del(beasties, b)
  end

  update_bar_state()

  for i, beastie in ipairs(beasties) do
    if i != current_beastie then
      if t() % .25 == 0 then
        local rnd_dir = rnd()
        local rnd_speed = flr(rnd()*5)
        beastie.ax = cos(rnd_dir)*.01*rnd_speed
        beastie.ay = sin(rnd_dir)*.01*rnd_speed
      end
    end
  end

  for i, beastie in ipairs(beasties) do
    if i != current_beastie then
      beastie.dx += beastie.ax
      beastie.dy += beastie.ay
      beastie.dx = sgn(beastie.dx)*min(abs(beastie.dx), .25)
      beastie.dy = sgn(beastie.dy)*min(abs(beastie.dy), .25)
    end
  end

  for i, beastie in ipairs(beasties) do
    if i != current_beastie then
      beastie.x += beastie.dx
      beastie.y += beastie.dy
    end
  end


  -- player movement
  if btn(0) then -- left
    beasties[current_beastie].ax = 0
    beasties[current_beastie].dx = -1
    beasties[current_beastie].x -= 1
  end
  if btn(1) then -- right
    beasties[current_beastie].ax = 0
    beasties[current_beastie].dx = 1
    beasties[current_beastie].x += 1
  end
  if btn(2) then -- up
    beasties[current_beastie].ay = 0
    beasties[current_beastie].dy = -1
    beasties[current_beastie].y -= 1
  end
  if btn(3) then -- down
    beasties[current_beastie].ay = 0
    beasties[current_beastie].dy = 1
    beasties[current_beastie].y += 1
  end

  -- keep beasties in their cage
  for beastie in all(beasties) do
    if beastie.x < playfield.x + 1 then
      beastie.x = playfield.x + 1
    end
    if beastie.x > 127 - 16 then
      beastie.x = 127 - 16
    end
    if beastie.y < playfield.y + 1 then
      beastie.y = playfield.y + 1
    end
    if beastie.y > 127 - 16 then
      beastie.y = 127 - 16
    end
  end

  -- change beastie
  if btnp(4) then -- button_o (z)
    current_beastie += 1
    if current_beastie > 8 then
      current_beastie = 1
    end
  end
end

function _draw()
  cls()

  -- TODO Remove this - bottom left quadrant
  --rectfill(0,64,63,127,3)
  -- TODO Remove this - bottom right quadrant
  rect(playfield.x, playfield.y, 127, 127, 6)

  -- title
  --print(color)
  print("pOPCORN bEASTIES",        (128-(17*4))/2, 0, color)
  print("A tRIJAM 265 sUBMISSION", (128-(23*4))/2, 7, 9)

  draw_bar(1, 122, bar_max_fill + 2, 6)

  for i, beastie in ipairs(beasties) do
    if i != current_beastie then
      draw_beastie(beastie)
    end
  end
  if #beasties > 0 then
    draw_beastie(beasties[current_beastie])
  end

  -- popcorn machine
  spr(128, 20, 0-8+3, 4,8)

  local yoff = 59
  print("bEASTIES:", 1, yoff, 12)
  for i, b in ipairs(beasties) do
    local col = 6
    pset(1, yoff+i*7+2, col)
    pset(2, yoff+i*7+2, col)
    pset(1, yoff+i*7+2-1, col)
    print(b.name, 4, yoff+i*7, col)
  end

  -- TODO remove
  print("created=" .. beasties_created, 0, 6 * 11, 6)
  print("current=" .. current_beastie, 0, 6 * 12, 6)
end

function update_bar_state()
  if btnp(5) then
    bar_state.filled = min(bar_state.filled + 5, bar_max_fill)
    bar_state.frames_till_decay = bar_decay_frames
  end

  bar_state.frames_till_decay -= 1
  if bar_state.frames_till_decay <= 0 then
    bar_state.filled -= 1
    bar_state.frames_till_decay = bar_decay_frames
  end

  if bar_state.filled <= 0 then
    bar_state.filled = 0
  end

  if bar_state.filled >= bar_max_fill then
    bar_state.filled = 0
    new_beastie()
  end
end

function new_beastie()
  if #beasties < 8 then
    add(beasties, gen_beastie(#beasties, flr(rnd()*1024), playfield.x+playfield_size/2-8, playfield.y+playfield_size/2-8))
  end
end

function draw_bar(x, y, w, h)
  -- bar border
  rect(x, y, x + w - 1, y + h - 1, 6)

  -- bar fill
  bar_fill = (w - 2) * (bar_state.filled / bar_max_fill)
  if bar_fill > 0 then
    rectfill(x + 1, y + 1, x + bar_fill, y + h - 2 , 8)
  end
end
