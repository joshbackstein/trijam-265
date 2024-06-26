g_image_dim = 16
g_gap_px_len = 4
g_image_len = g_image_dim^2
g_max_num_images = 32

g_row_len =ceil(sqrt(g_max_num_images))

function scx(xoff) return mid(0, xoff, g_image_dim-1) + g_gap_px_len\2 end
function scy(yoff) return mid(0, yoff, g_image_dim-1) + g_gap_px_len\2 end
function snx(xoff) return xoff + g_gap_px_len\2 end
function sny(yoff) return yoff + g_gap_px_len\2 end

function getpix_raw(slot, x, y)
  if x < 0 or x >= g_image_dim then return 0 end
  if y < 0 or y >= g_image_dim then return 0 end
  return sget(slot*16 + snx(x)-1, sny(y)-1)
end

function getpix(slot, x, y)
  if x < 0 or x >= g_image_dim then return false end
  if y < 0 or y >= g_image_dim then return false end
  return sget(slot*16 + scx(x)-1, scy(y)-1) == 6
end

function setpix_raw(slot, x, y, col)
  if x >= 2 and y >= 2 and x < g_image_dim and y < g_image_dim then
    sset(slot*16 + x-1, y-1, col)
  end
end

name_part1 = {"pIX", "pUF", "fIZ", "zIM", "kEX", "qUO", "zEP", "jIX", "rEX", "dAX", "lIX", "vOX", "pAZ", "jAZ", "mOX", "nEX", "bUZ", "cAZ", "kLO", "vEX", "wIX", "zYX", "fUX", "qIX", "rOZ", "sUZ", "tIX", "uXO", "vIZ", "wOZ", "xIX", "yOK", "zUZ", "aXO", "bEZ", "cOZ", "dEZ", "eZO", "fEZ", "gIZ", "hUZ", "iZO", "kEZ", "lOZ", "mOZ", "nIX", "oXO", "pOZ", "rIZ", "sYZ"}
name_part2 = {"", "IBU", "OBI", "ULA", "EFA", "IJI", "OFO", "OU", "UE", "UO", "A", "E", "I", "O", "U", "AE", "AI", "AO", "AGO", "ENE", "IE", "ODO", "UZU", "AJE", "EMI", "IRI", "OLU", "UFI", "AKA", "ENA"}
name_part3 = {"", "AX", "bO", "CY", "dI", "eX", "fO", "gY", "HO", "iO", "jO", "kY", "lI", "mO", "nY", "oY", "pO", "qU", "rI", "sI", "tO", "uX", "vI", "wO", "xY", "yO", "zA", "bI", "cU", "dU", "EV", "FI", "GU", "HI", "JI", "KO", "LU", "MI", "NI", "OU", "PI", "QI", "RO", "SU", "TI", "UY", "VU", "WI", "XI", "YU", "zE"}

function gen_beastie(slot, beastie_num, start_x, start_y)
  for i=0,15 do -- clear the sprite before starting to draw
    memset(64*i+slot*8, 0, 8)
  end

  srand(beastie_num) -- use a custom starting position for the beasties

  local cur_pix = 0
  function setpix(shouldset, size, col)
    local is_done = false

    if shouldset then
      for xoff=-size,size do
        for yoff=-size,size do
          if xoff == 0 or yoff == 0 then
            local x = mid(0, xoff, g_image_dim-1) + g_gap_px_len\2
            local y = mid(0, yoff, g_image_dim-1) + g_gap_px_len\2
            setpix_raw(slot, cur_pix%g_image_dim+xoff, cur_pix\g_image_dim+yoff, col)
          end
        end
      end
    end

    cur_pix += 1
    if cur_pix == g_image_len then
      while true do
        local change_count = 0
        for yoff=0,g_image_dim-1 do
          for xoff=0,g_image_dim-1 do
            if getpix(slot, xoff, yoff) then
              local neb_count = 0
              for yyoff=-1,1 do
                for xxoff=-1,1 do
                  neb_count += getpix(slot, xoff+xxoff, yoff+yyoff) and 1 or 0
                end
              end
              if neb_count <= 2 then
                setpix_raw(slot, scx(xoff), scy(yoff), 0)
                change_count += 1
              end
            end
          end
        end

        if change_count == 0 then break end
      end

      cur_pix  = 0
      is_done = true
    end

    return is_done
  end

  while true do
    local num = rnd()
    local diff = abs(g_image_dim/2-cur_pix%g_image_dim) + abs(g_image_dim/2-cur_pix\g_image_dim)
    local multiplier = 1 / (g_image_dim/2)

    if setpix(num < .75-diff*(1/26), num*2\1, 6) then
      break
    end
  end

  -- using same srand as beastie
  local b = {
    name=ri(name_part1)..ri(name_part2)..ri(name_part3),
    x=start_x,  y=start_y,
    slot=slot,
    lifetime=60*5+flr(rnd()*60*15),
    dx=0, dy=0,
    ax=0, ay=0,
  }

  srand(t())

  return b
end

function ri(l)
  return l[flr(rnd()*#l)+1]
end

flip()

-- local start_num = rnd()*1024\1
-- for i=0, 7 do
--   gen_beastie(i, start_num+i)
-- end

function draw_beastie(obj)
  pal{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  local flip = obj.dx > 0
  for xx=-1,1 do
    for yy=-1,1 do
      spr(obj.slot%8*2, obj.x+xx, obj.y+yy, 2, 2, flip, false)
    end
  end

  if obj != current_beastie then
    pal{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
  else
    pal{10,10,10,10,10,10,10,10,10,10,10,10,10,10,10}
  end

  spr(obj.slot%8*2, obj.x, obj.y, 2, 2, flip, false)
  pal()
end

-- function _draw()
--   cls(13)
--   for i=0,7 do
--     draw_beastie(i, 7+i*16, 7+i*16, false)
--   end
-- end
