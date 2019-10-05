--[[ Core-Gameplay prototype of the "Keep Going Game" ]]--

-- import:
local Player = require 'player'
local Manager = require 'manager'   -- singleton
local map1 = require 'map1'

-- Global vars:
local manager   -- контроль игры
local player    -- управляемый игроком персонаж

function love.load()
    love.window.setMode(1000, 500)
    manager = Manager -- singleton
    player = Player:new()
    manager:addGameObject(player)
    manager:loadLevel(map1)
end

function love.update(dt)
    manager:update(dt)
end

function love.draw()
    love.graphics.translate(-0.5, -0.5)   -- {1, 1} - top left corner; {width, height} - bottom right corner
    map1:draw()
    player:draw()
    love.graphics.print('collision: '..tostring(manager.is_collision))
end

-- Fast quit
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit(0)
    end
end


--[[ Utils ]]--
function round(n)
    return (n > 0 and math.floor(n + 0.5) or math.ceil(n - 0.5))
end
