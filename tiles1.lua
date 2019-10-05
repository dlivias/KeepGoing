-- Set of tiles for map1:
local Tile = require('tile')

tiles = {}
tiles.width = 50
tiles.height = 50

local colors = {
    grey = {133 / 255, 146 / 255, 158 / 255},
    dark_grey = {23 / 255, 32 / 255, 42 / 255},
}

tiles[0] = Tile:new()
tiles[0].draw = function(x, y)
    love.graphics.setColor(colors.dark_grey)
    love.graphics.rectangle('fill', x, y, tiles.width, tiles.height)
end

tiles[1] = Tile:new()
tiles[1].draw = function(x, y)
    love.graphics.setColor(colors.grey)
    love.graphics.rectangle('fill', x, y, tiles.width, tiles.height)
end
tiles[1].is_obstacle = true

tiles[2] = Tile:new()    -- rounded corners
tiles[2].draw = function(x, y)
    love.graphics.setColor(colors.dark_grey)
    love.graphics.rectangle('fill', x, y, tiles.width, tiles.height)
    love.graphics.setColor(colors.grey)
    love.graphics.rectangle('fill', x + 1, y + 1, tiles.width - 1, tiles.height - 1, 12)
end
tiles[2].is_obstacle = true

return tiles
