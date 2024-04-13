-- this is the lua source
function _init()
  playfield_size = 80
  playfield = {
    x = 127 - playfield_size,
    y = 127 - playfield_size,
  }

  bar_max_fill = playfield.x - 4
  bar_decay_frames = 3
  bar_state = {
    filled = 0,
    frames_till_decay = 0
  }

  beasties = {
  }

  color = 10
end

function _update60()
  update_bar_state()

  -- change color
  if btn(4) then -- button_o (z)
    if btnp(2) then -- up
      color += 1
      if color > 15 then
        color = 1 -- can't see black
      end
    end
    if btnp(3) then -- down
      color -= 1
      if color < 1 then -- can't see black
        color = 15
      end
    end
  end
end

function _draw()
  cls()

  -- TODO Remove this - bottom left quadrant
  --rectfill(0,64,63,127,3)
  -- TODO Remove this - bottom right quadrant
  rect(playfield.x, playfield.x, 127, 127, 6)

  -- title
  --print(color)
  print("popcorn beasties", (128-(17*4))/2, 0, color)

  draw_bar(1, 122, bar_max_fill + 2, 6)

  draw_beastie(1, 20, 30)
  draw_beastie(2, 65, 70)
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

  --bar_state.filled = bar_max_fill
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

function draw_beastie(beastie_num, x, y)
  -- sprite size: 16x16
  rectfill(x, y, x+16, y+16, 12)
  print(beasties[beastie_num].name, 0, (beastie_num - 1) * 6, 12)
end
