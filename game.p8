pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- road rascal rumble
-- by noah smith

-- game variables
game_won = false

-- car variables
local car_x = 64
local car_y = 104 - 8
local car_speed = 2
local lane_width = 24


-- traffic cone variables
local cones = {}
local cone_timer = 0
local cone_spawn_rate = 60

-- squirrel variables
local squirrel = nil
local squirrel_timer = 0
local squirrel_spawn_rate = 180

-- road speed variable
local road_speed = 1

-- score variable
local score = 0

function _init()
end

function update_car()
  -- car movement
  if btn(2) then
    car_y = mid(104 - 8, car_y - car_speed, 104 - 32) -- move forward
  else
    car_y = min(car_y + car_speed, 104 - 8) -- move back to standard position
  end

  if btn(0) then
    car_x = car_x - car_speed
  elseif btn(1) then
    car_x = car_x + car_speed
  end

  -- keep car within screen boundaries and lanes
  car_x = mid(8 + lane_width / 2, car_x, 8 + lane_width * 4.5)
end


function update_cones()
  -- spawn traffic cones
  cone_timer = cone_timer + 1
  if cone_timer % cone_spawn_rate == 0 then
    local lane = flr(rnd(5))
    add(cones, {x = 8 + lane * lane_width + lane_width / 2, y = -8})
  end

  -- update traffic cones
  for cone in all(cones) do
    cone.y = cone.y + road_speed

    -- check for collision
    if (abs(cone.x - car_x) < lane_width / 2) and (abs(cone.y - car_y) < 8) then
      -- game over (reset the game)
      cones = {}
      car_x = 64
      car_y = 104
      score = 0 -- reset the score
    end

    -- remove cones when they go off screen and increase score
    if cone.y > 128 then
      del(cones, cone)
      score = score + 1 -- increment the score
    end
  end
end

function update_squirrel()
  -- spawn squirrel
  squirrel_timer = squirrel_timer + 1
  if squirrel_timer % squirrel_spawn_rate == 0 then
    local lane = flr(rnd(5))
    squirrel = {x = -8, y = rnd(64)}
  end

  -- update squirrel
  if squirrel then
    squirrel.x = squirrel.x + road_speed
    squirrel.y = squirrel.y + road_speed

    -- check for collision
    if (abs(squirrel.x - car_x) < lane_width / 2) and (abs(squirrel.y - car_y) < 8) then
      -- collision with squirrel (add bonus points)
      squirrel = nil
      score = score + 2 -- add bonus points
    end

    -- remove squirrel when it goes off screen
    if squirrel and (squirrel.x > 128 or squirrel.y > 128) then
      squirrel = nil
    end
  end
end

function update_score()
  -- update road speed based on score
  road_speed = 1 + (flr(score / 10) * 0.5)
end

function _update()
  update_car()
  update_cones()
  update_squirrel()
  update_score()

  -- check if the player has won
  if score >= 10 then
    game_won = true
  end
end

function draw_grass()
  for i = 0, 127, 4 do
    for j = 0, 3 do
      rectfill(j * 4, i, j * 4 + 3, i + 3, j % 2 == 0 and 3 or 11)
      rectfill(127 - j * 4, i, 127 - j * 4 - 3, i + 3, j % 2 == 0 and 3 or 11)
    end
  end
end

function draw_road()
  rectfill(8, 0, 119, 127, 1)
  for i = 0, 15 do
    for j = 1, 4 do
      line(8 + j * lane_width, i * 8 + flr(t() * 30 * road_speed) % 8, 8 + j * lane_width, i * 8 + 4 + flr(t() * 30 * road_speed) % 8, 7)
    end
  end
end

function draw_car()
  spr(1, car_x - 8, car_y - 8)
end

function draw_cones()
  for cone in all(cones) do
    spr(2, cone.x - 8, cone.y - 8)
  end
end

function draw_squirrel()
  if squirrel then
    spr(3, squirrel.x - 8, squirrel.y - 8) -- assume squirrel sprite is at index 3
  end
end

function draw_score()
  print("score: " .. score, 2, 2, 7)
end

function draw_button_info()
  local btn_text = ""

  if btn(0) then
    btn_text = "left"
  elseif btn(1) then
    btn_text = "right"
  elseif btn(2) then
    btn_text = "up"
  elseif btn(3) then
    btn_text = "down"
  end

  print("button: " .. btn_text, 2, 12, 7)
end

function draw_checkered_pattern()
  local pattern_size = 2
  for x = 0, 127, pattern_size do
    for y = 0, 127, pattern_size do
      if (x / pattern_size + y / pattern_size) % 2 == 0 then
        rectfill(x, y, x + pattern_size - 1, y + pattern_size - 1, 7) -- white
      else
        rectfill(x, y, x + pattern_size - 1, y + pattern_size - 1, 0) -- black
      end
    end
  end
end

function _draw()
  cls()
  draw_grass()

  -- draw the checkered pattern if the player has won
  if game_won then
    draw_checkered_pattern()
  end

  draw_road()
  draw_cones()
  draw_car()
  draw_squirrel()
  draw_score()
end

__gfx__
00000000008788000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000058788500007700055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700058788500007700056005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008118000099990055055150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008788000099990005555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700058788500777777005555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000058118500777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008788009999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
