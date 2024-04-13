g_cur_pix = 0
g_cur_img = 0
g_image_dim = 16
g_gap_px_len = 4
g_image_len = g_image_dim^2
g_max_num_images = 32

g_row_len =ceil(sqrt(g_max_num_images))

function scx(xoff) return g_cur_img%g_row_len*g_image_dim + mid(0, xoff, g_image_dim-1) + g_gap_px_len\2 + g_cur_img%g_row_len*g_gap_px_len end
function scy(yoff) return g_cur_img\g_row_len*g_image_dim + mid(0, yoff, g_image_dim-1) + g_gap_px_len\2 + g_cur_img\g_row_len*g_gap_px_len end
function snx(xoff) return g_cur_img%g_row_len*g_image_dim + xoff + g_gap_px_len\2 + g_cur_img%g_row_len*g_gap_px_len end
function sny(yoff) return g_cur_img\g_row_len*g_image_dim + yoff + g_gap_px_len\2 + g_cur_img\g_row_len*g_gap_px_len end

function getpix_raw(x, y)
  if x < 0 or x >= g_image_dim then return 0 end
  if y < 0 or y >= g_image_dim then return 0 end
  return pget(snx(x), sny(y))
end

function getpix(x, y)
  if x < 0 or x >= g_image_dim then return false end
  if y < 0 or y >= g_image_dim then return false end
  return pget(scx(x), scy(y)) == 6
end

function setpix(shouldset, size, col)
  printh("h "..tostr(shouldset).." "..tostr(size).." "..tostr(col))
  if shouldset then
    for xoff=-size,size do
      for yoff=-size,size do
        if xoff == 0 or yoff == 0 then
          printh(xoff)
          local x = g_cur_img%g_row_len*g_image_dim + mid(0, xoff, g_image_dim-1) + g_gap_px_len\2 + g_cur_img%g_row_len*g_gap_px_len
          local y = g_cur_img\g_row_len*g_image_dim + mid(0, yoff, g_image_dim-1) + g_gap_px_len\2 + g_cur_img\g_row_len*g_gap_px_len
          pset(g_cur_pix%g_image_dim+xoff, g_cur_pix\g_image_dim+yoff, col)
          printh("| "..(g_cur_pix%g_image_dim+xoff))
          printh("| "..(g_cur_pix\g_image_dim+yoff))
          printh("| "..col)
        end
      end
    end
  end

  g_cur_pix += 1
  if g_cur_pix == g_image_len then
    while true do
      change_count = 0
      for yoff=0,g_image_dim-1 do
        for xoff=0,g_image_dim-1 do
          if getpix(xoff, yoff) then
            neb_count = 0
            for yyoff=-1,1 do
              for xxoff=-1,1 do
                neb_count += getpix(xoff+xxoff, yoff+yyoff) and 1 or 0
              end
            end
            if neb_count <= 2 then
              pset(scx(xoff), scy(yoff), 13)
              change_count += 1
            end
          end
        end
      end

      if change_count == 0 then break end
    end

    for yoff=0,g_image_dim-1 do
      for xoff=0,g_image_dim-1 do
        if getpix_raw(xoff, yoff) == 6 then
          if getpix_raw(xoff-1, yoff)   != 6 then pset(snx(xoff-1), sny(yoff),   1) end
          if getpix_raw(xoff+1, yoff)   != 6 then pset(snx(xoff+1), sny(yoff),   1) end
          if getpix_raw(xoff,   yoff-1) != 6 then pset(snx(xoff),   sny(yoff-1), 1) end
          if getpix_raw(xoff,   yoff+1) != 6 then pset(snx(xoff),   sny(yoff+1), 1) end

          if getpix_raw(xoff-1, yoff-1) != 6 then pset(snx(xoff-1), sny(yoff-1), 1) end
          if getpix_raw(xoff-1, yoff+1) != 6 then pset(snx(xoff-1), sny(yoff+1), 1) end
          if getpix_raw(xoff+1, yoff-1) != 6 then pset(snx(xoff+1), sny(yoff-1), 1) end
          if getpix_raw(xoff+1, yoff+1) != 6 then pset(snx(xoff+1), sny(yoff+1), 1) end
        end
      end
    end

    g_cur_pix  = 0
    g_cur_img += 1
  end

  return g_cur_img >= 1
end

srand(59) -- use a custom starting position for the beasties

function draw_all_beasties()
  while true do
    local num = rnd()
    local diff = abs(g_image_dim/2-g_cur_pix%g_image_dim) + abs(g_image_dim/2-g_cur_pix\g_image_dim)
    local multiplier = 1 / (g_image_dim/2)
    printh("hhh: "..(diff*multiplier*.25))

    if setpix(num < .75-diff*(1/26), num*2\1, 6) then
      printh("hello")
      break
    end
  end
end

cls(13)
draw_all_beasties()
flip()

function _draw() end
