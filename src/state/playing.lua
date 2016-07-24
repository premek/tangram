local Gamestate = require "lib.hump.gamestate"
local Timer = require 'lib.hump.timer'
local vector = require "lib.hump.vector-light"
local bitser = require 'lib.bitser'
local love = love

return {

  save = "tangram_save.bitser",

  initShapes = {
    {0, 0, 2, 0, 0, 2},
    {0, 2, 1, 3, 0, 4},
    {0, 2, 1, 1, 2, 2, 1, 3},
    {2, 0, 4, 0, 3, 1, 1, 1},
    {1, 1, 3, 1, 2, 2},
    {4, 0, 4, 4, 2, 2},
    {0, 4, 2, 2, 4, 4}
  },
  selected = nil,
  dragged = nil,
  scale = 60,


savegame = function(self) love.filesystem.write(self.save, bitser.dumps(self.shapes)) end,
loadgame = function(self)
  if love.filesystem.exists(self.save) then
    print("Loading from", love.filesystem.getRealDirectory(self.save))
    self.shapes = bitser.loads(love.filesystem.read(self.save))
    return true
  end
  print("No save found")
  return false
end,


update = function(self, dt)
  self.selected = nil

  --move
  if self.dragged then
    local ox = love.mouse.getX() - self.dragged.dragX - self.dragged[1]
    local oy = love.mouse.getY() - self.dragged.dragY - self.dragged[2]
    for i = 1, #self.dragged, 2 do
      self.dragged[i] = ox + self.dragged[i]
      self.dragged[i+1] = oy + self.dragged[i+1]
    end
  end

  for _,shape in ipairs(self.shapes) do
    if shape.rvel and math.abs(shape.rvel) > 0.01 then
      shape.rvel = shape.rvel - shape.rvel * math.min(dt * 20, 1)
    else
      shape.rvel =0
    end


    shape.rot = (shape.rot or 0) + shape.rvel *dt

    local cx, cy = self.stupidCenter(shape)

    if not self.dragged then
    --find selected
    -- mouse have to be right of all or left of all
    -- when it's flipped, all the vectors go back
    local allRight = true
    local allLeft = true
    for i=1,#shape,2 do
      local p = i%#shape
      local x1, y1 = vector.rotate(shape.rot, vector.sub(shape[p], shape[p+1], cx, cy))
      x1 = x1+cx
      y1 = y1 +cy
      p = (i+2)%#shape
      local x2, y2 = vector.rotate(shape.rot, vector.sub(shape[p], shape[p+1], cx, cy))
      x2 = x2+cx
      y2 = y2 +cy
      local right = ((x2 - x1)*(love.mouse:getY() - y1) > (y2 - y1)*(love.mouse:getX() - x1))
      allRight = allRight and right
      allLeft = allLeft and not right
    end
    shape.selected = allRight or allLeft

    if shape.selected then
      if self.selected then self.selected.selected = false end -- deselect previous one of 2 shapes overlapping
      self.selected = shape
    end
    end
  end
end,

stupidCenter = function(shape)
  local minx, maxx, maxy, miny = shape[1], shape[1], shape[2], shape[2]
  for i=1,#shape,2 do
    minx = math.min(minx, shape[i])
    maxx = math.max(maxx, shape[i])
    miny = math.min(miny, shape[i+1])
    maxy = math.max(maxy, shape[i+1])
  end
  return (maxx+minx)/2, (maxy+miny)/2
end,

flip = function(self, shape)
  local cx = self.stupidCenter(shape)
  shape.rot = - shape.rot
  for i=1,#shape,2 do
    shape[i] = -shape[i] + 2*cx
  end
self.selected.selected = false
self.selected = nil

end,


init = function(self)
  if not self:loadgame() then self:newgame() end

  for _,shape in ipairs(self.shapes) do
    shape.rvel = love.math.random(-10,10)*.1
  end

  Timer.every(20, function() self:savegame() end)

end,

newgame = function (self)
  local scx, scy = love.graphics:getWidth()/2, love.graphics:getHeight()/2

  self.shapes = deepcopy(self.initShapes)

  local offx = (love.graphics:getWidth() - 4*self.scale)/2
  local offy = (love.graphics:getHeight() - 4*self.scale)/2

  for _,shape in ipairs(self.shapes) do

    for i=1,#shape,2 do
      shape[i] = shape[i] * self.scale + offx
      shape[i+1] = shape[i+1] * self.scale + offy
    end

    local cx, cy = self.stupidCenter(shape)

    local ox = (cx-scx)*.3+love.math.random(-5,5)
    local oy = (cy-scy)*.3+love.math.random(-5,5)
    for i = 1, #shape, 2 do
      shape[i] = shape[i] + ox
      shape[i+1] = shape[i+1] + oy
    end
  end
end,

wheelmoved = function(self, _, dy )
  if self.selected then self.selected.rvel = math.max(-40, math.min(40,(self.selected.rvel + dy/2) * 3)) end
end,


mousereleased = function(self, x, y, button, istouch)
  self.dragged = nil
end,

mousepressed = function(self, x, y, button, istouch)
  if self.selected then
    if button == 1 then
    self.dragged = self.selected
    self.dragged.dragX = x - self.dragged[1]
    self.dragged.dragY = y - self.dragged[2]

    elseif button == 3 then
      self:flip(self.selected)
    end
  end
end,

keypressed = function(self, key)
   if key=='r' then self:newgame() end
 end,


draw = function(self)
  love.graphics.setColor(palette[2])
  love.graphics.rectangle("fill", 0,0, love.graphics:getWidth(), love.graphics:getHeight())

  love.graphics.setColor(palette[5])
  love.graphics.setFont(fonts["text"])
  love.graphics.printf("Press R to reset, Esc to quit", 10,lgh*0.95, lgw, "left")


  for _,s in ipairs(self.shapes) do

    local cx, cy = self.stupidCenter(s)

    love.graphics.translate(cx, cy)
    love.graphics.rotate(s.rot)
    love.graphics.translate(-cx, -cy)

    love.graphics.setColor(palette[3])
    if s.selected then love.graphics.setColor(palette[4]) end
    love.graphics.setLineWidth(1)


    love.graphics.polygon('fill', s)
    love.graphics.setColor(palette[5])
    love.graphics.polygon('line', s)

    love.graphics.translate(cx, cy)
    love.graphics.rotate(-s.rot)
    love.graphics.translate(-cx, -cy)

  end

end
}
