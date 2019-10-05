--[[ Core-Gameplay prototype of the "Keep Going Game" ]]--

-- import:
local Manager = require 'manager'   -- singleton

-- Global vars:
local manager   -- контроль игры

function love.load()
    love.window.setMode(1000, 500)
    manager = Manager -- singleton
    manager:load()
end

function love.update(dt)
    manager:update(dt)
end

function love.draw()
    love.graphics.translate(-0.6, -0.6)   -- {1, 1} - top left corner; {width, height} - bottom right corner
    manager:draw()
end

-- Fast quit
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit(0)
    end
end
