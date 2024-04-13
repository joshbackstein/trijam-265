cartdata("popcorn_beasties")

-- this is the lua source
function _init()
  music(0)
  poke(0x5f5c, 255) -- set btn initial delay before repeating. 255 means never repeat.
  poke(0x5f5d, 1) -- set btn repeating delay. (this doesn't need to be set because of 255 above)


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

  beasties_slots = {
    [0]=false, false, false, false,
    false,     false, false, false,
  }

  current_beastie = nil
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
    beasties_slots[b.slot] = false
    del(beasties, b)

    if b == current_beastie then
      next_beastie()
    end
  end

  update_bar_state()

  for i, beastie in ipairs(beasties) do
    if beastie != current_beastie then
      if t() % .25 == 0 then
        local rnd_dir = rnd()
        local rnd_speed = flr(rnd()*5)
        beastie.ax = cos(rnd_dir)*.01*rnd_speed
        beastie.ay = sin(rnd_dir)*.01*rnd_speed
      end
    end
  end

  for i, beastie in ipairs(beasties) do
    if beastie != current_beastie then
      beastie.dx += beastie.ax
      beastie.dy += beastie.ay
      beastie.dx = sgn(beastie.dx)*min(abs(beastie.dx), .25)
      beastie.dy = sgn(beastie.dy)*min(abs(beastie.dy), .25)
    end
  end

  for i, beastie in ipairs(beasties) do
    if beastie != current_beastie then
      beastie.x += beastie.dx
      beastie.y += beastie.dy
    end
  end

  -- player movement
  if current_beastie then
    if btn(0) then -- left
      current_beastie.ax = 0
      current_beastie.dx = -1
      current_beastie.x  -= 0.4
    end
    if btn(1) then -- right
      current_beastie.ax = 0
      current_beastie.dx = 1
      current_beastie.x  += 0.4
    end
    if btn(2) then -- up
      current_beastie.ay = 0
      current_beastie.dy = -1
      current_beastie.y  -= 0.4
    end
    if btn(3) then -- down
      current_beastie.ay = 0
      current_beastie.dy = 1
      current_beastie.y  += 0.4
    end
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
  if btnp(4) and #beasties > 0 then -- button_o (z)
    next_beastie()
  end

  if g_total > dget(0) then
    dset(0, g_total)
  end
  if #beasties == 0 then
    g_total = 0
    g_add_amount = 15
  end
end

function next_beastie()
  if #beasties > 0 then
    local cbi = -1
    for i, b in ipairs(beasties) do
      if b == current_beastie then
        cbi = i
      end
    end

    if cbi < 0 then
      current_beastie = beasties[1]
    else
      current_beastie = beasties[cbi % #beasties+1]
    end
  else
    current_beastie = nil
  end
end

function _draw()
  cls()

  -- display playfield
  rect(playfield.x, playfield.x, 127, 127, 6)

  -- title
  print("pOPCORN bEASTIES",        (128-(17*4))/2, 0, color)
  print("A tRIJAM 265 sUBMISSION", (128-(23*4))/2, 7, 9)

  draw_bar(1, 122, bar_max_fill + 2, 6)

  for i, beastie in ipairs(beasties) do
    if beastie != current_beastie then
      draw_beastie(beastie)
    end
  end

  if #beasties > 0 and current_beastie then
    draw_beastie(current_beastie)
  end

  -- popcorn machine
  spr(128, 20, 0-8+3, 4,8)

  local yoff = 59
  print("bEASTIES:", 1, yoff, 12)
  for i, b in ipairs(beasties) do
    local col = 0
    if b == current_beastie then
      col = 10
    else
      col = 6
    end
    pset(1, yoff+i*7+2, col)
    pset(2, yoff+i*7+2, col)
    pset(1, yoff+i*7+2-1, col)
    print(b.name, 4, yoff+i*7, col)
  end

  local hs_str = "hS: "..dget(0)
  print(hs_str, 32+16-1-#hs_str*4+80+2, 20-6+20+8-2+1, 6)
  print("sCORE: "..g_total, 32+16-1, 20-6+20+8-2+1, 6)
  if #beasties == 0 then
    print("pop with ❎",    65,  80, 6)
    print("switch with 🅾️",     65-1*4,  80+7, 6)
    print("move with ⬆️⬇️⬅️➡️",    65-3*4, 80+14, 6)
  end
end

g_bar_cooldown = 0
g_add_amount = 15
function update_bar_state()
  if g_bar_cooldown > 0 then
    g_bar_cooldown = max(0, g_bar_cooldown-1)
    if g_bar_cooldown == 0 then
      bar_state.filled = 0
    else
      return
    end
  end

  if btnp(5) then
    bar_state.filled = mid(0, bar_max_fill, bar_state.filled + g_add_amount)
    bar_state.frames_till_decay = bar_decay_frames
  else
    bar_state.frames_till_decay -= 1
    if bar_state.frames_till_decay <= 0 then
      bar_state.filled = mid(0, bar_max_fill, bar_state.filled - 1)
      bar_state.frames_till_decay = bar_decay_frames
    end
  end

  if bar_state.filled >= bar_max_fill then
    g_add_amount = 3+flr(rnd(42-min(40, g_total*2)))
    g_bar_cooldown = 30
    new_beastie()
  end
end

g_total=0
function new_beastie()
  for s, v in pairs(beasties_slots) do
    if not v then
      g_total = min(255, g_total+1)

      add(beasties, gen_beastie(s, flr(rnd()*1024), playfield.x+playfield_size/2-8, playfield.y+playfield_size/2-8))
      beasties_slots[s] = true
      break
    end
  end

  if not current_beastie then
    next_beastie()
  end
end

function draw_bar(x, y, w, h)
  -- bar border
  rect(x, y, x + w - 1, y + h - 1, 6)

  -- bar fill
  bar_fill = (w - 2) * (bar_state.filled / bar_max_fill)
  if bar_fill > 1 then
    rectfill(x + 1, y + 1, x + bar_fill, y + h - 2 , g_bar_cooldown > 0 and 2 or 3)
  end
end
