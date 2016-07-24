local Gamestate = require "lib.hump.gamestate"


return {
instructions = "Instructions \n\nDrag and drop moves,\nmouse wheel revolves,\nand the wheel click flips.\n\n"..
"Do what you want,\nthe game does not care,\nyou just have fun.",

update = function(self, dt)
end,

draw = function(self)
  love.graphics.setColor(palette[3])
  love.graphics.rectangle("fill", 0, 0, lgw, lgh)

  love.graphics.setFont(fonts["big"])
  love.graphics.setColor(palette[1])
  love.graphics.printf("Tangram", 0, lgh*.08, lgw, "center")

  love.graphics.setFont(fonts["text"])
  love.graphics.printf(self.instructions, lgw*.34, lgh*.32, lgw, "left")
  love.graphics.printf("Click to play", lgw*.55, lgh*.72, lgw, "left")

end,

keypressed = function(self, key)

end,

mousepressed = function(self, x, y, button, istouch)
  Gamestate.switch(state.playing)
end
}
