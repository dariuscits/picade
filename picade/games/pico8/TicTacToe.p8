pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- tic tac toe
-- by: daniel escoz
btn_lft = 0
btn_rgt = 1
btn_up = 2
btn_dn = 3
btn_o = 4
btn_x = 5

spr_big = {1,3}
spr_sml = {33,34}
spr_spk = {35, 36}
spr_cur = {9,11}

map_brdx = 0
map_brdy = 0
map_brdsz = 10

scr_brdx = 24
scr_brdy = 24

winlines = {
  -- vertical
  {1,1, 1,2, 1,3},
  {2,1, 2,2, 2,3},
  {3,1, 3,2, 3,3},
  -- horizontal
  {1,1, 2,1, 3,1},
  {1,2, 2,2, 3,2},
  {1,3, 2,3, 3,3},
  -- diagonal
  {1,1, 2,2, 3,3},
  {1,3, 2,2, 3,1},
}

board = {}
curx = 2
cury = 2
turn = 0
first = 0
win = 0
winline = nil
full = false
play = true

sparktime = 0

function _init_game ()
  if first == 0 then
    first = 1 + flr(rnd(2))
  else
    first = (first%2)+1
  end
  
  board = {{0,0,0},{0,0,0},{0,0,0}}
  turn = first
  win = 0
  full = false
  play = true
  
  sparks = {}
  sparktime = 0 
  
  curx = 2
  cury = 2
  
  sfx(0, 0)
  sfx(-1, 1)
end

function getwinner ()
  for ln in all(winlines) do
    c1 = board[ln[1]][ln[2]]
    c2 = board[ln[3]][ln[4]]
    c3 = board[ln[5]][ln[6]]
    
    if c1==c2 and c2==c3 and c1~=0 then
      return c1,ln
    end
  end

  return 0,nil
end

function isboardfull ()
  for i=1,3 do
    for j=1,3 do
      if board[i][j] == 0 then
        return false
      end
    end
  end
  
  return true
end

function _update_game ()
  updateai()

  if play then
		  if btnpa(btn_lft) and curx > 1 then
		    sfx(8)
		    curx -= 1
		  elseif btnpa(btn_rgt) and curx < 3 then
		    sfx(8)
		    curx += 1
		  elseif btnpa(btn_up) and cury > 1 then
		    sfx(8)
		    cury -= 1
		  elseif btnpa(btn_dn) and cury < 3 then
		    sfx(8)
		    cury += 1
		  end
		end

  play = win==0 and not full
	 if board[curx][cury] == 0 
	   and btnpa(btn_o)
	   and turn ~= 0
	   and play
	 then
	   board[curx][cury] = turn
	   win,winline = getwinner()
    full = isboardfull()
    
	   if win==0 then
	     sfx(1+turn, -1)
	     if full then
	       sfx(6, -1)
	     end
	   else
	     sfx(3+turn, -1)
	   end
	   turn = turn%2 + 1
	 end
  
  if win~=0 and sparktime<=0 then
    local c = flr(rnd(3))
    local cx = winline[c*2+1]
    local cy = winline[c*2+2]
    
    local x = scr_brdx+24*cx-12
    local y = scr_brdy+24*cy-12
    
    for i=1,10 do
		    local ra = rnd(1)
		    local rp = 1 + rnd(.75)
		    local sx = rp * sin(ra)
		    local sy = rp * cos(ra)
      add(sparks, {win,x,y,sx,sy})
      sfx(7, -1)
    end
    
    sparktime = 15 + flr(rnd(45))
  end
  sparktime = max(sparktime-1, 0)
  
  if not play and btnp(btn_x) then
    _init_title()
  end
  if not play and btnp(btn_o) then
    _init_game()
  end
end


function drawboard ()
  color(15)
  rectfill(
    scr_brdx+4, scr_brdy+4,
    scr_brdx+74, scr_brdy+74
  )
  
  if win~=0 then
    for i=0,2 do
      local cx = winline[i*2+1]
      local cy = winline[i*2+2]
      
      color(7)
      rectfill(
        scr_brdx+24*cx-18,
        scr_brdy+24*cy-18,
        scr_brdx+24*cx,
        scr_brdy+24*cy)
    end
  end

  map(map_brdx, map_brdy,
  	   scr_brdx, scr_brdy,
      map_brdsz, map_brdsz)

  for i=1,3 do
		  for j=1,3 do
		    local s = board[i][j]
		      
		    if s ~= 0 then
		      local x = scr_brdx+24*i-16
		      local y = scr_brdy+24*j-16
		      
				    spr(spr_big[s], x, y, 2, 2)
		    end
		  end
  end
end

function drawcursor ()
  local x = scr_brdx + 24*(curx-1)
  local y = scr_brdy + 24*(cury-1)
  local f = flr(time() * 3) % 2
  
  s = spr_cur[turn]
  spr(s, x+2-f, y+2-f, 2, 2, false, false)
  spr(s, x+14+f, y+2-f, 2, 2, true, false)
  spr(s, x+2-f, y+14+f, 2, 2, false, true)
  spr(s, x+14+f, y+14+f, 2, 2, true, true)
end

function drawturn ()
  local s = "player   turn"
  local x = 64 - 2*#s
  local y = 10
  
  txtb(s, x, y, 2, 1)
  spr(spr_sml[turn], x+26, y-1)
end

function drawwin ()
  local s = "player   wins!"
  if (win==0) s = "draw!"
  
  local x = 64 - 2*#s
  local y = 10.5
  
  txtbw(s, x, y, 1.5, 1.2, .1)
  if (win~=0) then
    local w = wave(1.5, 1.2, .1, 7.5)
    spr(spr_sml[win], x+26, round(y-1+w))
  end
end


function _bgline (x, y, cx, cy, c1, c2, m)
  local t = m * time() / 10
  local a = t + atan2(x-cx, y-cy)
  local c
  if flr(a * 32)%2 == 0 then
    c = c1
  else
    c = c2
  end
  
  line(cx, cy, x, y, c)
end

function drawbg (c1, c2, _x, _y, _m)
  local x = _x or 63
  local y = _y or 63
  local m = _m or 1
  
  for i=0,127 do
    if (y>0) _bgline(i, 0, x, y, c1, c2, m)
    if (x>0) _bgline(0, i, x, y, c1, c2, m)
    if (y<127) _bgline(i, 127, x, y, c1, c2, m)
    if (x<127) _bgline(127, i, x, y, c1, c2, m)
  end
end

balls = {}
ballspawn = 0
ballangle = rnd()
function drawplaybg ()
  ballspawn -= 1
  if ballspawn <= 0 then
    ballspawn = 2
    
    ballangle = ballangle + .25 + rnd(.5)
    local p = .5 + rnd()
    add(balls, {
      x=63, y=63,
      r=5+rnd(10),
      as=rnd()-.5,
      sx=p*cos(ballangle),
      sy=p*sin(ballangle),
      l=128/p,
    })
  end

  color(3)
  for ball in all(balls) do
    ball.l -= 1
    if ball.l <= 0 then
      del(balls, ball)
    else
      ball.x += ball.sx
      ball.y += ball.sy
    end
    
    color(3)
    local a = vertex(ball.x, ball.y, ball.r, ball.as, 0)
    local b = vertex(ball.x, ball.y, ball.r, ball.as, .333)
    local c = vertex(ball.x, ball.y, ball.r, ball.as, .667) 
    trifill(a, b, c)
  end
end

function _draw_game ()
  cls(11)
  
  palt(0, false)
  palt(11, true)
  
  if win==1 then
    drawbg(7, 12)
  elseif win==2 then
    drawbg(7, 8)
  elseif full then
    drawbg(6, 5)
  else
    drawplaybg()
  end

  drawboard()
  if play then
    drawturn()
    drawcursor()
    
    if aiplays and aithink < ai_thinktime then
      txtbw("thinking",
        48, 112)
    end
  else
    drawwin()
    drawsparks()
    txtb("🅾️ to play again",
      32, 108)
    txtb("❎ to go back",
      36, 117)
  end
end

-->8
-- utils

txt_border_pos = {
  {-1,-1,5},
  {-1,1,5},
  {1,-1,5},
  {1,1,5},
  {-1,0,0},
  {0,-1,0},
  {1,0,0},
  {0,1,0},
}
function txtb (str, x, y)
  for o in all(txt_border_pos) do
    print(str, x+o[1], y+o[2], o[3])
  end
  print(str, x, y, 7)
end

function wave(pwr_, spd_, frq_, ph_)
	 local pwr = pwr_ or 1
	 local spd = spd_ or 1
	 local frq = frq_ or .1
	 local ph = ph_ or 0
	 
  local x = time() * spd - frq*ph
  return pwr * sin(x)
end

function round (x)
  return flr(x + .5)
end

function txtbw (str, x, y, pwr, spd, frq)
  p = 0
  for i=1,#str do
    s = sub(str,i,i)
    w = wave(pwr, spd, frq, i)
    txtb(s, round(x+4*p), round(y+w))
    p += 1
    if (s=="🅾️") p+=1
  end
end

function rndo ()
  local x = rnd(1.2)
  return flr(x - .1)
end


ai_thinktime = 30
ai_inputtime = 8

aiplays = false
aiframe = 0
ailast = 0
aibtns = {}
aithink = 0

function updateai ()
  aibtn = -1
  
  if #aibtns > 0 then
    aiframe += 1
		  if aibtns[1].f == aiframe then
		    aibtn = aibtns[1].b
		    del(aibtns, aibtns[1])
		  end
		  
  else
    aiframe = 0
    ailast = 0
  end
  
  aiplays = play and aiplayer == turn
  if aiplays then
    if aithink == ai_thinktime then
      local aipos = aiselect()
      aimove(aipos)
      addaibtn(btn_o)
    end
    aithink += 1
    
  else
    aithink = 0
  end
end

function addaibtn (b)
  add(aibtns, {f=ailast+1, b=b})
  ailast += ai_inputtime
end

function btnpa (b)
  if aiplays then
    return aibtn == b
  else
    return btnp(b)
  end
end

function aimove (to)
  tox = to.x
  toy = to.y
  
  px = curx
  py = cury
  
  -- horizontal move
  while px < tox do
    px += 1
    addaibtn(btn_rgt)
  end
  while px > tox do
    px -= 1
    addaibtn(btn_lft)
  end
  
  -- vertical move
  while py < toy do
    py += 1
    addaibtn(btn_dn)
  end
  while py > toy do
    py -= 1
    addaibtn(btn_up)
  end
end

-->8
-- title screen

screen = 0
sparks = {}

spkalt = false

block = nil
blkspawn = 30
blkspr = 1

opt_hvh = 0
opt_hvc = 1
opt = opt_hvh

function _init_title ()
  sfx(10, 0)
  sfx(11, 1)
  
  sparks = {}
  screen = 0
end

function _init ()
  _init_title()
end

function _update_title ()
  if (btnp(btn_o)) then
    screen = 1
    first = 0
    
    if opt == opt_hvh then
      aiplayer = 0
    else
      aiplayer = 2
    end
    
    _init_game()
  end
  
  blkspawn -= 1
  if blkspawn < 0 then
    blkspawn = 50
    
    x = (blkspr-1) * 140 - 10
    y = 100
    sx = -((blkspr-1) * 4 - 2)
    sy = -2
    l = 10 + 20 * rnd() 
    
    block = {s=blkspr, x=x, y=y, sx=sx, sy=sy, l=l}
    blkspr = (blkspr % 2) + 1
  end
  
  if block ~= nil then
    block.x += block.sx
    block.y += block.sy
    block.sy += .07
    
    block.l -= 1
    if block.l <= 0 then
      sfx(1, -1)
      for i=1,5 do
        local ra = rnd(1)
		      local rp = .25 + rnd(.25)
		      local sx = rp * sin(ra)
		      local sy = rp * cos(ra)
        add(sparks, {
          block.s,
          block.x + rnd(4)-2,
          block.y + rnd(4)-2,
          sx + block.sx,
          sy + block.sy
        })
      end
      
      block = nil
    end
  end
  
  if rnd() < .05 then
    xo = rnd() * 8
    y = 100 + rnd() * 8
    ao = rnd() * .05
    s = 2 + rnd() * 1.5
    
    if spkalt then
      p = 1
      a = .1 + ao
      x = -4 - xo
    else
      p = 2
      a = .4 - ao
      x = 124 + xo
    end
    spkalt = not spkalt
    
    add(sparks, {
      p, x, y,
      s*cos(a),
      s*sin(a)
    })
  end
  
  if opt == 0 and btnp(btn_dn) then
    sfx(9)
    opt = 1
  elseif opt == 1 and btnp(btn_up) then
    sfx(9)
    opt = 0
  end
end


words = {
  {64, 66, 68},
  {64, 70, 68},
  {64, 72, 74}
}
recolor = {
  {-1,-1,0}, {0,-1,0}, {1,-1,0},
  {-1, 0,0},           {1, 0,0},
  {-1, 1,0},           {1, 1,0},
  {-1, 2,0}, {0, 2,0}, {1, 2,0},
  { 0, 1,6}, {0, 0,7}
}

function drawtitle ()
  for w,word in pairs(words) do
    for l,let in pairs(word) do
      v = wave(2, .75, 1, w*.25)
      spr(let,
        14 + (w-1)*18+l*12,
        w*11+v,
        2, 2)
    end
  end
end

function _draw_title ()
  cls(15)
  
  palt(0, false)
  palt(11, true)
  
  drawbg(9, 10, 63, 150, -.5)
  
  if block then
    spr(spr_sml[block.s],
      block.x, block.y)
  end
  
  drawsparks()
  
  drawtitle()
  
  txtb("player vs player", 28, 68)
  txtb("player vs computer", 28, 80)
  spr(40, 16, 67 + opt*12)
  
  txtbw("press 🅾️ to play",
    32, 110)
end


function drawsparks ()
  for spark in all(sparks) do
    p = spark[1]
    
    if p~=0 then
	     spr(spr_spk[p],
	       spark[2], spark[3])
	   end
  end
end


function _update ()
  if screen==0 then
    _update_title()
  elseif screen==1 then
    _update_game()
  end
  
  for spark in all(sparks) do
    spark[2] += spark[4]
    spark[3] += spark[5]
    spark[5] += .07
    
    if spark[3] > 127 then
      del(sparks, spark)
    end
  end
end

function _draw ()
  if screen==0 then
    _draw_title()
  elseif screen==1 then
    _draw_game()
  end
end
-->8
-- triangles

function sort_vertices_y (vertices)
  for i=1,#vertices-1 do
    for j=i,1,-1 do
      if vertices[j].y > vertices[j+1].y then
        local tmp = vertices[j]
        vertices[j] = vertices[j+1]
        vertices[j+1] = tmp
      end
    end
  end
  return vertices
end

function vertex (x, y, r, spd, ph)
  local t = time()*spd+ph
  return {
   x=x+r*cos(t),
   y=y+r*sin(t),
  }
end

function flattrifill(a, bx1, bx2, by)
  local dy = by - a.y
  if (dy==0) return
  
  local d = 1
  if (a.y > by) d = -1
  
  for y=a.y,by,d do
    local ry = (y-a.y)/dy
    local x1 = a.x + ry * (bx1 - a.x)
    local x2 = a.x + ry * (bx2 - a.x)
    line(
      flr(x1), y,
      flr(x2), y)
  end
  line(bx1, by, bx2, by)
end

function trifill (a_, b_, c_)
  local after = sort_vertices_y({a_, b_, c_})
  local a = after[1]
  local b = after[2]
  local c = after[3]
  
  local mp = (b.y-a.y)/(c.y-a.y)
  local mx = a.x + (mp * (c.x-a.x))
  flattrifill(a, b.x, mx, b.y)
  flattrifill(c, b.x, mx, b.y)
end
-->8
-- ai startegies
function aiselect ()
  local win = get_win_move(aiplayer)
  if (win) return win
  
  local block = get_win_move((aiplayer%2)+1)
  if (block) return block
  
  if (board[2][2]==0) return {x=2,y=2}
  return select_random()
end

function wmline (ln, tp)
  local epos
  local mycells = 0
  
  for i=1,5,2 do
  		local cell = board[ln[i]][ln[i+1]]
  		if cell == 0 then
  		  epos = {x=ln[i],y=ln[i+1]}
  		elseif cell == tp then
  		  mycells += 1
  		else
  		  return nil
  		end
  end
  
  if (mycells == 2) return epos
end

function get_win_move (tp)
  for ln in all(winlines) do
    local move = wmline(ln, tp)
    if (move) return move
  end
  return nil
end

function select_random ()
  local pos = {}
  for x=1,3 do
    for y=1,3 do
      if board[x][y] == 0 then
        add(pos, {x=x,y=y})
      end
    end
  end
  return pos[1 + flr(rnd() * #pos)]
end
__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb076650bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000bbb00bbbbbb00bbbbbbbbb0000bbbbbbbbb000000000000000000bbbb076650bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00700700bb0cc0bbbb0cc0bbbbbb00888800bbbbbb07777777777777777770bbb076650bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00077000b0cccc0bb0cccc0bbbb0888888880bbbb0766666666666666666650bb076650bbbbb00000000bbbbbbbb00000000bbbb000000000000000000000000
00077000b0ccccc00ccccc0bbb088888888880bbb0766666666666666666650bb076650bbbb0cccccccc0bbbbbb0888888880bbb000000000000000000000000
00700700bb0cccccccccc0bbbb088880088880bbb0766555556665555566650bb076650bbbb0cccccccc0bbbbbb0888888880bbb000000000000000000000000
00000000bbb0cccccccc0bbbb088880bb088880bb0766500007665000076650bb076650bbbb0cc000000bbbbbbb088000000bbbb000000000000000000000000
00000000bbbb0cccccc0bbbbb08880bbbb08880bb076650bb076650bb076650bb076650bbbb0cc0bbbbbbbbbbbb0880bbbbbbbbb000000000000000000000000
00000000bbbb0cccccc0bbbbb08880bbbb08880bb076650bb076650bb076650bbbbbbbbbbbb0cc0bbbbbbbbbbbb0880bbbbbbbbb000000000000000000000000
00000000bbb0cccccccc0bbbb088880bb088880bb0766500007665000076650b00000000bbb0cc0bbbbbbbbbbbb0880bbbbbbbbb000000000000000000000000
00000000bb0cccccccccc0bbbb088880088880bbb0766677776666777766650b77777777bbb0cc0bbbbbbbbbbbb0880bbbbbbbbb000000000000000000000000
00000000b0ccccc00ccccc0bbb088888888880bbb0766666666666666666650b66666666bbb0cc0bbbbbbbbbbbb0880bbbbbbbbb000000000000000000000000
00000000b0cccc0bb0cccc0bbbb0888888880bbbb0766666666666666666650b66666666bbbb00bbbbbbbbbbbbbb00bbbbbbbbbb000000000000000000000000
00000000bb0cc0bbbb0cc0bbbbbb00888800bbbbb0766555556665555566650b55555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000bbb00bbbbbb00bbbbbbbbb0000bbbbbbb0766500007665000076650b00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb076650bb076650bb076650bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
000000005005005bb50005bbbbbbbbbbbbbbbbbbb076650bb076650bb076650bbbb505bb00000000000000000000000000000000000000000000000000000000
000000000cc0cc0b5088805bbbbbbbbbbbbbbbbbb0766500007665000076650bbbb0705b00000000000000000000000000000000000000000000000000000000
000000000ccccc0b0888880bbbb11bbbbbb22bbbb0766677776666777766650bbbb0770500000000000000000000000000000000000000000000000000000000
0000000050ccc05b0880880bbb1cc1bbbb2882bbb0766666666666666666650bbbb0777000000000000000000000000000000000000000000000000000000000
000000000ccccc0b0888880bbb1cc1bbbb2882bbb0766666666666666666550bbbb0770500000000000000000000000000000000000000000000000000000000
000000000cc0cc0b5088805bbbb11bbbbbb22bbbbb05555555555555555550bbbbb0705b00000000000000000000000000000000000000000000000000000000
000000005005005bb50005bbbbbbbbbbbbbbbbbbbbb000000000000000000bbbbbb505bb00000000000000000000000000000000000000000000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000bbbbb00000000000bbbbbbb000000000bbbbbbb0000000bbbbbbbbb0000000bbbbbbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
07777777770bbbbb07777777770bbbbbb0077777770bbbbbb007777700bbbbbbb007777700bbbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
07777777770bbbbb07777777770bbbbb00777777770bbbbb00777777700bbbbb00777777700bbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
07777777770bbbbb07777777770bbbbb07777777770bbbbb07777777770bbbbb07777777770bbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0ddd777ddd0bbbbb0ddd777ddd0bbbbb07777ddddd0bbbbb07777d77770bbbbb07777d77770bbbbb0777dddddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00007770000bbbbb00007770000bbbbb0777d000000bbbbb0777d0d7770bbbbb0777d0d7770bbbbb07770000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbbbbb07770bbbbbbbb077700bbbbbbbbbb07770007770bbbbb07770007770bbbbb07777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbbbbb07770bbbbbbbb07770bbbbbbbbbbb07777777770bbbbb07770b07770bbbbb07777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbbbbb07770bbbbbbbb077700bbbbbbbbbb07777777770bbbbb07770007770bbbbb0777ddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbb00007770000bbbbb07777000000bbbbb07777777770bbbbb07777077770bbbbb07770000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbb07777777770bbbbb07777777770bbbbb0777ddd7770bbbbb07777777770bbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbb07777777770bbbbb0d777777770bbbbb07770007770bbbbb0d7777777d0bbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb07770bbbbbbbb07777777770bbbbb00d77777770bbbbb07770b07770bbbbb00d77777d00bbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0ddd0bbbbbbbb0ddddddddd0bbbbbb00ddddddd0bbbbb0ddd0b0ddd0bbbbbb00ddddd00bbbbbb0ddddddddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb00000bbbbbbbb00000000000bbbbbbb000000000bbbbb00000b00000bbbbbbb0000000bbbbbbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000ff00000fffffffffff0000ffff00000fff00000fff00000fff00000fff000fffff00000fff00000fff00000ffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0cc0cc0f0088800fff000ffff0660ffff06660fff06660fff06060fff06660fff060fffff06660fff06660fff06660ffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0ccccc0f0888880ff00b00fff0560ffff05560fff05560fff06060fff06550fff06000fff05560fff06560fff06560ffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
01ccc10f0882880ff0bbb0fff0060ffff06660fff00660fff06660fff06660fff06660fff00060fff06660fff06660ffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0ccccc0f0888880ff03b30fff0060000f0655000f0056000f0556000f0556000f0656000fff06000f0656000f0556000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0cc1cc0f0288820ff00300fff0666060f0666060f0666060f0006060f0666060f0666060fff06060f0666060f0006060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0110110f0022200fff000ffff0555050f0555050f0555050fff05050f0555050f0555050fff05050f0555050fff05050bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000ff00000fffffffffff0000000f0000000f0000000fff00000f0000000f0000000fff00000f0000000fff00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__label__
99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999
99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999
99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999
999999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999
a99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999
a99999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999
aa9999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999
aa9999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999
aaa9999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999
aaa9999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999
aaaa999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999
aaaa999999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999
aaaa999999999999999999999900000000000a00000000000aaa000000000a999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999
aaaaa99999999999999999999907777777770a07777777770aa0077777770a999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999
aaaaa99999999999999999999907777777770a07777777770a00777777770a99999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999
aaaaaa9999999999999999999907777777770a07777777770a07777777770a99999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999
aaaaaa999999999999999999990ddd777ddd0a0ddd777ddd0a07777ddddd0a99999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999
aaaaaaa999999999999999999900007770000a00007770000a0777d000000a99999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999
aaaaaaa99999999999999999999990777099aaaaa07770aaaa077700aaaaaa99999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999
aaaaaaa99999999999999999999990777099aaaaa07770aaaa07770aaaaaaa9999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999
aaaaaaaa9999999999999999999990777099aaaaa077000000000000aa00000009999900000000099999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999
aaaaaaaa9999999999999999999990777099aa0000770777777777000007777700999007777777099999999aaaaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999
aaaaaaaaa9999999999999999999907770999a0777770777777777070077777770090077777777099999999aaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999
aaaaaaaaa9999999999999999999907770999a0777770777777777070777777777090777777777099999999aaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999
aaaaaaaaaa999999999999999999907770999a0777770ddd777ddd0707777d77770907777ddddd099999999aaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999
aaaaaaaaaa99999999999999999990ddd0999a0ddddd00007770000d0777d0d777090777d0000009999999aaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999
aaaaaaaaaa999999999999999999900000999a000000000077700000077700077709077700999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999
aaaaaaaaaaa999999999999999999999999999aaaaaaaaa07770aaaa077777777709077709999999999999aaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999
aaaaaaaaaaa999999999999999999999999999aaaaaaaaa07770aaaa077777777709077700999999999999aaaaaaaaaaaaaaaaaaaaaaaaaa9999999999999999
aaaaaaaaaaaa99999999999999999999999999aaaaaaaaa07770aaaa077777777709077770000009999999aaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999
aaaaaaaaaaaa99999999999999999999999999aaaaaaaaa07770aaaa0777ddd7770907777777770999999aaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999
aaaaaaaaaaaaa9999999999999999999999999aaaaaaaaa07770aaaa07770000000000000777000000099a00000000000aaaaaaaaaaaaaa99999999999999999
aaaaaaaaaaaaa99999999999999999999999999aaaaaaaa07770aaaa07770a07777777770770077777009a07777777770aaaaaaaaaaaaa999999999999999999
aaaaaaaaaaaaaa9999999999999999999999999aaaaaaaa0ddd0aaaa0ddd0a07777777770d00777777700a07777777770aaaaaaaaaaaaa999999999999999999
aaaaaaaaaaaaaa9999999999999999999999999aaaaaaaa00000aaaa00000a07777777770007777777770a07777777770aaaaaaaaaaaa9999999999999999999
aaaaaaaaaaaaaa9999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaa0ddd777ddd0907777d77770a0777dddddd0aaaaaaaaaaaa9999999999999999999
aaaaaaaaaaaaaaa999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaa0000777000090777d0d7770a07770000000aaaaaaaaaaaa9999999999999999999
aaaaaaaaaaaaaaa9999999999999999999999999aaaaaaaaaaaaaaaaaaaaaa99907770999907770007770a07777770aaaaaaaaaaaaaa99999999999999999999
aaaaaaaaaaaaaaaa999999999999999999999999aaaaaaaaaaaaaaaaaaaaaa99907770999907770907770a07777770aaaaaaaaaaaaaa99999999999999999999
aaaaaaaaaaaaaaaa999999999999999999999999aaaaaaaaaaaaaaaaaaaaaa99907770999907770007770a0777ddd0aaaaaaaaaaaaa999999999999999999999
aaaaaaaaaaaaaaaaa99999999999999999999999aaaaaaaaaaaaaaaaaaaaaa99907770999907777077770a07770000000aaaaaaaaaa999999999999999999999
aaaaaaaaaaaaaaaaa99999999999999999999999aaaaaaaaaaaaaaaaaaaaaa99907770999907777777770a07777777770aaaaaaaaaa999999999999999999999
aaaaaaaaaaaaaaaaa999999999999999999999999aaaaaaaaaaaaaaaaaaaaa9990777099990d7777777d0a07777777770aaaaaaaaa9999999999999999999999
aaaaaaaaaaaaaaaaaa99999999999999999999999aaaaaaaaaaaaaaaaaaaaa99907770999900d77777d00a07777777770aaaaaaaaa9999999999999999999999
aaaaaaaaaaaaaaaaaa99999999999999999999999aaaaaaaaaaaaaaaaaaaaa9990ddd09999900ddddd00aa0ddddddddd0aaaaaaaa99999999999999999999999
aaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaaaaaaaaaaaaaa999000009999990000000aaa00000000000aaaaaaaa99999999999999999999999
aaaaaaaaaaaaaaaaaaa99999999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999
aaaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999999
aaaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999999
aaaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaaaa9999999999999999999999999
aaaaaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaaaa9999999999999999999999999
aaaaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaaaa9999999999999999999999999
aaaaaaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaaa9999999999999999999999999a
aaaaaaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaaa999999999999999999999999aa
aaaaaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaa9999999999999999999999999aa
aaaaaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaa999999999999999999999999aaa
aaaaaaaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999999aaaa
aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaaa999999999999999999999999aaaa
aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaaa99999999999999999999999aaaaa
9aaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaa99999999999999999999999aaaaaa
99aaaaaaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaa99999999999999999999999aaaaaa
99aaaaaaaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaa
999aaaaaaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaa
9999aaaaaaaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaa
9999aaaaaaaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaa
99999aaaaaaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaaaa9999999999999999999999aaaaaaaaa
999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaa
9999999aaaaaaaaaaaaaaaaaaaaa999999999999991199aaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaa
9999999aaaaaaaaaaaaaaaaaaaaaa9999999999991cc19aaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaa
99999999aaaaaaaaaaaaaaaaaaaaa9999999999991cc19aaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaa999999999999999999999aaaaaaaaaaaa
999999999aaaaaaaaaaaaaaaaaaaa99999999999991199aaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaa
999999999aaaaaaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaa
9999999999aaaaaaaaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaa
99999999999aaaaaaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaa
99999999999aaaaaaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaa99999999999999999999aaaaaaaaaaaaaaa
999999999999aaaaaaaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaa
9999999999999aaaaaaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaa99999999999999aaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaa
9999999999999aaaaaaa5005005aaaaa9999999999999999aaaaaaaaaaaaaaa99999999999999aaaaaaaaaaaaaaa9999999999999999999aaaaaaaaaaaaaaaaa
99999999999999aaaaaa0cc0cc0aaaaaa999999999999999aaaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaa
999999999999999aaaaa0ccccc0aaaaaa999999999999999aaaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaaaa999999999999999999aaaaaaaaaaaaaaaaaaa
9999999999999999aaaa50ccc05aaaaaaa999999999999999aaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaaaa999922999999999999aaaaaaaaaaaaaaaaaaa
9999999999999999aaaa0ccccc0aaaaaaa999999999999999aaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaaaa99928829999999999aaaaaaaaaaaaaaaaaaaa
99999999999999999aaa0cc0cc0aaaaaaaa99999999999999aaaaaaaaaaaaaa9999999999999aaaaaaa22aaaaa99992882999999999aaaaaaaaaaaaaaaaaaaaa
999999999999999999aa5005005aaaaaaaa99999999999999aaaaaaaaaaaaaa9999999999999aaaaaa2882aaaa99999229999999999aaaaaaaaaaaaaaaaaaaaa
999999999999999999aaaaaaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaaa999999999999aaaaaaa2882aaa99999999999999999aaaaaaaaaaaaaaaaaaaaaa
9999999999999999999aaaaaaaaaaaaaaaaa99999999999999aaaaaaaaaaaaa999999999999aaaaaaaa22aaaa9999999999999999aaaaaaaaaaaaaaaaaaaaaa9
99999999999999999999aaaaaaaaaaaaaaaa99999999999999aaaaaaaaaaaaa999999999999aaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaaaaaa99
99999999999999999999aaaaaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaa999999999999aaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaaaaaa999
999999999999999999999aaaaaaaaaaaaaaaa9999999999999aaaaaaaaaaaaa999999999999aaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaaaaa9999
a999999999999999999999aaaaaaaaaaaaaaaa999999999999aaaaaaaaaaaaa99999999999aaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaaaaaaaaa99999
aa99999999999999999999aaaaaaaaaa11aaaa9999999999999aaaaaaaaaaaa99999999999aaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaaaa999999
aaa99999999999999999999aaaaaaaa1cc1aaaa999999999999aaaaaaaaaaaa99999999999aaaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaaa9999999
aaaa99999999999999999999aaaaaaa1cc1aaaa999119999999aaaaaaaaaaaa99999999999aaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaaa99999999
aaaaa99999999999999999999aaaaaaa11aaaaa991cc1999999aaaaaaaaaaaa99999999999aaaaaaaaaaaa99999999999999aaaaaaaaaaaaaaaaaaa999999999
aaaaaa9999999999999999999aaaaaaaaaaaaaaa91cc1999999aaaaaaaaaaaa9999999999aaaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaa9999999999
aaaaaaa9999999999999999999aaaaaaaaaaaaaa991199999999aaaaaaaaaaa9999999999aaaaaaaaaaaa99999999999999aaaaaaaaaaaaaaaaaa99999999999
aaaaaaaa9999999999999999999aaaaaaaaaaaaaa99999999999aaaaaaaaaaa9999999999aaaaaaaaaaaa9999999999999aaaaaaaaaaaaaaaaaa999999999999
aaaaaaaaa999999999999999999aaaaaaaaaaaaaa99999999999aaaaaaaaaaa9999999999aaaaaaaaaaa99999999999999aaaaaaaaaaaaaaaaa9999999999999
aaaaaaaaaa999999999999999999aaaaaaaaaaaaaa9999999999aaaaaaaaaaa9999999999aaaaaaaaaaa9999999999999aaaaaaaaaaaaaaaaa99999999999999
aaaaaaaaaaa999999999999999999aaaaaaaaaaaaa9999999999aaaaaaaaaaa9999999999aaaaaaaaaa9999999999999aaaaaaaaaaaaaaaaa999999999999999
aaaaaaaaaaaa99999999999999999aaaaaaaaaaaaa99999999999aaaaaaaaaa999999999aaaaaaaaaaa9999999999999aaaaaaaaaaaaaaaa9999999999999999
aaaaaaaaaaaaa99999999999999999aaaaaaaaaaaaa9999999999aaaaaaaaaa999999999aaaaaaaaaaa999999999999aaaaaaaaaaaaaaaa99999999999999999
aaaaaaaaaaaaaa99999999999999999aaaaaaaaaaaa9999999999aaaaaaaaaa999999999aaaaaaaaaa999999999999aaaaaaaaaaaaaaaa999999999999999999
aaaaaaaaaaaaaaa9999999999999999aaaaaaaaaaaaa999999999aaaaaaaaaa999999999aaaaaaaaaa999999999999aaaaaaaaaaaaaaa9999999999999999999
aaaaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaa999999999aaaaaaaaaa999999999aaaaaaaaa999999999999aaaaaaaaaaaaaaa99999999999999999999
aaaaaaaaaaaaaaaaaa999999999999999aaaaaaaaaaaa999999999aaaaaaaaa99999999aaaaaaaaaa99999999999aaaaaaaaaaaaaaa999999999999999999999
aaaaaaaaaaaaaaaaaaa999999999999999aaaaaaaaaaa999999999aaaaaaaaa99999999aaaaaaaaaa99999999999aaaaaaaaaaaaaa9999999999999999999999
aaaaaaaaaaaaaaaaaaaa99999999999999aaaaaaaaaaa999999999aaaaaaaaa99999999aaaaaaaaa99999999999aaaaaaaaaaaaaa9999999999999999999999a
aaaaaaaaaaaaaaaaaaaaa99999999999999aaaaaaaaaaa99999999aaaaaaaaa9999500055005aaaa9999999999aaaaaaaaaaaaaa999999999999999999999aaa
aaaaaaaaaaaaaaaaaaaaaa999999999500050005aaaaaa999999999a50000059999077750770aaa50005999999aaaaaaaaaaaaa999999999999999999999aaaa
9aaaaaaaaaaaaaaaaaaaaaa99999999077707775000550055005999507777705999507007070aaa07775059500050505aaaaaa99999999999999999999aaaaaa
999aaaaaaaaaaaaaaaaaaaaa9999999070707070777507750770999077000770999907007070aaa07070709077707070aaaaa99999999999999999999aaaaaaa
9999aaaaaaaaaaaaaaaaaaaaa999999077707700700070007005999077070770999907007070aa907770709070707070aaaa9999999999999999999aaaaaaaaa
999999aaaaaaaaaaaaaaaaaaaa99999070007070770077707770999077000770999907007705aa907000709077707770aaa9999999999999999999aaaaaaaaaa
99999999aaaaaaaaaaaaaaaaaaa999907090707070050075007099950777770599995055005aa9907090700070750070aa999999999999999999aaaaaaaaaaaa
999999999aaaaaaaaaaaaaaaaaaa999505950500777077007705999950000059999999aaaaaaa9950590777070707770a999999999999999999aaaaaaaaaaaaa
99999999999aaaaaaaaaaaaaaaaaa999999999950005005500599999aaaaaaa999999aaaaaaaa999999500050505000599999999999999999aaaaaaaaaaaaaaa
999999999999aaaaaaaaaaaaaaaaaa99999999999aaaaaaaaa999999aaaaaaa999999aaaaaaa999999999aaaaaaaaaa99999999999999999aaaaaaaaaaaaaaaa
99999999999999aaaaaaaaaaaaaaaaa99999999999aaaaaaaa999999aaaaaaa999999aaaaaaa99999999aaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaa
99999999999999922aaaaaaaaaaaaaaa99999999999aaaaaaaa999999aaaaaa999999aaaaaa99999999aaaaaaaaaaa999999999999999aaaaaaaaaaaaaaaaaaa
999999999999992882aaaaaaaaaaaaaaa9999999999aaaaaaaa999999aaaaaa999999aaaaaa99999999aaaaaaaaaa99999999999999aaaaaaaaaaaaaaaaaaaaa
9999999999999928829aaaaaaaaaaaaaaa9999999999aaaaaaa999999aaaaaa99999aaaaaaa9999999aaaaaaaaaa99999999999999aaaaaaaaaaaaaaaaaaaaaa
99999999999999922999aaaaaaaaaaaaaaa9999999999aaaaaaa99999aaaaaa99999aaaaaa9999999aaaaaaaaaa9999999999999aaaaaaaaaaaaaaaaaaaaaaaa
9999999999999999999999aaaaaaaaaaaaaa999999999aaaaaaa99999aaaaaa99999aaaaaa9999999aaaaaaaaa9999999999999aaaaaaaaaaaaaaaaaaaaaaa99
99999999999999999999999aaaaaaaaaaaaaa999999999aaaaaaa99999aaaaa99999aaaaa9999999aaaaaaaaa999999999999aaaaaaaaaaaaaaaaaaaaaaa9999
aa99999999999999999999999aaaaaaaaaaaaa999999999aaaaaa99999aaaaa99999aaaaa999999aaaaaaaaa999999999999aaaaaaaaaaaaaaaaaaaaaa999999
aaaa9999999999999999999999aaaaaaaaaaaaa99999999aaaaaaa9999aaaaa9999aaaaaa999999aaaaaaaa99999999999aaaaaaaaaaaaaaaaaaaaa999999999
aaaaaaa999999999999999999999aaaaaaaaaaaa99999999aaaaaa99999aaaa9999aaaaa999999aaaaaaaa99999999999aaaaaaaaaaaaaaaaaaaa99999999999

__map__
0518180618180618180700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1518181618181618181700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1518181618181618181700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000800000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2518182618182618182700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0006000015750000100000015750000101575000010227502275022750000000060001000030000400004000050000f7000600007000080000900009000090000800008000070000500005000040000300003000
0004000000550000400053000010183002430020000207000010010000137001c0002770003100150001c0001f0001f0001d0001b0001600013000100000f0000000000000000000000000000000000000000000
000300001c5501c750003001f5501f750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f7501f550000001c7501c550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c5501c750000001f5501f7500000000500000003a0000750000000080002155021750000001f5001f5501f7501f5001f5001f5501f7501f5001f5002355023750000000000000000000000000000000
000300001f7501f550000001c7501c550000000000000000000000000000000000001f7501f55000000000001f7501f5500000000000247502455000000000001f7501f550000000000000000000000000000000
000300000000000000000000000000000000000000000000000000000000000000001d7501d55000000000000000016550167500000000000000000e7500e5500000000000000000855008750000000000000000
000400000055006040065300c710183002430020000207000010010000137001c0002770003100150001c0001f0001f0001d0001b0001600013000100000f0000000000000000000000000000000000000000000
000300002355025750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c34019230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00001a5401c0001c5403970018540215001c540235001d5401d5202e7002750029500020001100012000130001400015000160001700018000190001a0001b0001c0001d0001e0001f000000000000000000
010b000013130000001513000000101300000015130000001813018110000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0a0b4344

