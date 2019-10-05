-- Tile class
Tile = {}

function Tile:new()
    local instance = {
        draw = function(x, y) end,
        is_obstacle = false,
    }
    return setmetatable(instance, { __index = Tile })
end

return Tile
