-- Level class (contains map, enemies and player start location)

Level = {}

function Level:new(map, player_start_pos, enemies_data)
    local instance = {
        map = map,  -- type: Map
        player_start_pos = player_start_pos,  -- type: { x=, y= }
        enemies_data = enemies_data,  -- type: { { name=, row=, col=, rotation=, speed= }, ... }
    }
    return setmetatable(instance, {__index = Level})
end

function Level:draw()
    self.map:draw()
end

return Level
