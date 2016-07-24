local Signal = require 'lib.hump.signal'
local Timer = require 'lib.hump.timer'
local Gamestate = require "lib.hump.gamestate"
require "lib.util"

require "lib.require"

local love = love

lgw, lgh = love.graphics:getWidth(), love.graphics:getHeight()



local music = {}
local img = {}
local sfx = {}
fonts = {}


local palettes = {
{ {56,47,50}, {255,234,242}, {252,217,229}, {251,197,216}, {241,57,109}, },
{ {239,216,187}, {243,183,161}, {245,141,143}, {241,104,142}, {191,98,134}, },
{ {255,244,206}, {208,222,184}, {255,164,146}, {255,127,129}, {255,92,113}, },
{ {70,64,64}, {124,113,113}, {228,199,204}, {219,146,158}, {236,77,104}, }
}

palette = palettes[3]

state = require.tree("state")


-------------- load



function love.load()

  music[1] = love.audio.newSource( 'music/SingingBowl.mp3', 'stream' )
  --music[1]:setVolume(0.85)
  music[1]:setLooping(true)
  music[1]:play()

  for _,v in ipairs(love.filesystem.getDirectoryItems("sfx")) do
    local k = v:match("^(.+)%..+$")
    sfx[k] = love.audio.newSource("sfx/"..v, "static")
    sfx[k]:setVolume(0.8)
  end
  --for _,v in ipairs({"idle", "going"}) do sfx[v]:setLooping(true) end
  --sfx.radiofm:setVolume(1)
  --sfx.cardooropenclose4:setVolume(1)

  for _,v in ipairs(love.filesystem.getDirectoryItems("img")) do
    local f = v:match("^(.+)%..+$")
    img[f] = {}
    img[f].img = love.graphics.newImage("img/"..f..".png")
    img[f].quads = getQuads(img[f].img)
    img[f].quads.current = img[f].quads[0]
  end

  fonts["big"] = love.graphics.newFont( "font/Hoftype - Equip-Light.otf", lgh*.15 )
  fonts["text"] = love.graphics.newFont( "font/Hoftype - Equip-Light.otf", lgh*.03 )


  --love.window.setFullscreen( true, "desktop")

  Gamestate.registerEvents()
  Gamestate.switch(state.mainmenu)

  Signal.emit('loaded')
end


function love.update(dt)
  Timer.update(dt)
end


function love.quit()
  state.playing:savegame()
  return true
end



 ----- global controls
 function love.keypressed(key)
   if key=='escape' then love.event.quit() end
 end
