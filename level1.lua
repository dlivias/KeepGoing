-- Level#1

local Level = require 'level'
local map1 = require 'map1'

function tilePosToCartesianPos(map, col, row)    -- col, row -> x, y
    return 1 + map.tile_w*(col - 0.5), 1 + map.tile_h*(row - 0.5)
end
local player_x, player_y = tilePosToCartesianPos(map1, 3, 3)

local enemies_data = {
    { name = 'classic', col = 19, row = 2, rotation = math.pi, speed = 100 },
    { name = 'classic', col = 2, row = 9, rotation = -math.pi/2, speed = 100 },
}
level = Level:new(map1, { x = player_x, y = player_y }, enemies_data)

return level
