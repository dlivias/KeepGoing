-- Central class, singleton
Manager = {
    game_objects = {},
    is_collision = false,   -- for debuging purpose
}

function Manager:loadLevel(map)
    for row = 1, map.height do
        for col = 1, map.width do
            local tile = map.tiles[map.data[row][col]]
            if tile.is_obstacle then
                local obj = {
                    tile = tile,
                    type = 'obstacle_tile',
                    x = (col - 0.5) * map.tile_w + 0.5,     -- 25.5 +- 24.5
                    y = (row - 0.5) * map.tile_h + 0.5,
                    rotation = 0,
                    vertices = {
                        -(map.tile_w - 1) / 2, -(map.tile_h - 1) / 2, (map.tile_w - 1) / 2, -(map.tile_h - 1) / 2,
                        (map.tile_w - 1) / 2, (map.tile_h - 1) / 2, -(map.tile_w - 1) / 2, (map.tile_h - 1) / 2
                    }
                }
                table.insert(self.game_objects, obj)
            end
        end
    end
end

function Manager:addGameObject(obj)
    table.insert(self.game_objects, obj)
end

function vectorMul(line1, line2)
    local vec1 = { x = line1[2].x - line1[1].x, y = line1[2].y - line1[1].y }
    local vec2 = { x = line2[2].x - line2[1].x, y = line2[2].y - line2[1].y }
    return vec1.x*vec2.y - vec1.y*vec2.x
end

function isCollideLines(line1, line2)
    -- Both lines on one straight case
    if vectorMul(line1, line2) == 0 then
        local function isPointInLine(point, line)
            return line[1].x <= point.x and point.x <= line[2].x and line[1].y <= point.y and point.y <= line[2].y
                or line[2].x <= point.x and point.x <= line[1].x and line[2].y <= point.y and point.y <= line[1].y
        end
        return isPointInLine(line1[1], line2) or isPointInLine(line1[2], line2)
    end
    -- line1 - straight, line2 - have to be in both sides of plane, divided by line1
    local tied_line1 = { { x = line1[1].x, y = line1[1].y }, { x = line2[1].x, y = line2[1].y }}
    local tied_line2 = { { x = line1[1].x, y = line1[1].y }, { x = line2[2].x, y = line2[2].y }}
    -- Vector multiplication (component k) have to have same sign
    if vectorMul(tied_line1, line1) * vectorMul(line1, tied_line2) < 0 then
        return false
    end
    -- line2 - straight, line1 - have to be in both sides of plane, devided by line2
    tied_line1 = { { x = line2[1].x, y = line2[1].y }, { x = line1[1].x, y = line1[1].y }}
    tied_line2 = { { x = line2[1].x, y = line2[1].y }, { x = line1[2].x, y = line1[2].y }}
    -- Vector multiplication (component k) have to have same sign
    if vectorMul(tied_line1, line2) * vectorMul(line2, tied_line2) < 0 then
        return false
    end
    return true
end

function isCollide(obj1, obj2)
    if obj1.vertices == nil or obj2.vertices == nil then
        return false
    end

    -- From list to { {{x=,y=}, {x=,y=}}, ...}
    -- params x, y - center of form.
    local function getLines(x, y, rotation, vertices)
        if #vertices < 4 or #vertices % 2 == 1 then
            return nil
        end

        -- Get point positions
        local points = {}
        for xi = 1, #vertices - 1, 2 do
            local yi = xi + 1
            points[(xi + 1) / 2] = {
                x = x + vertices[xi]*math.cos(rotation) - vertices[yi]*math.sin(rotation),
                y = y + vertices[xi]*math.sin(rotation) + vertices[yi]*math.cos(rotation)
            }
        end

        -- Get lines from points
        local lines = {}
        for i = 1, #points - 1 do
            lines[i] = { points[i], points[i + 1] }
        end
        if #points > 2 then
            table.insert(lines, { points[#points], points[1] })
        end
        return lines
    end
    local lines1 = getLines(obj1.x, obj1.y, obj1.rotation, obj1.vertices)
    local lines2 = getLines(obj2.x, obj2.y, obj2.rotation, obj2.vertices)

    for i1, line1 in ipairs(lines1) do
        for i2, line2 in ipairs(lines2) do
            if isCollideLines(line1, line2) then
                return true
            end
        end
    end

    return false
end

function Manager:update(dt)
    -- Check for collisions
    self.is_collision = false
    for i, obj1 in ipairs(self.game_objects) do
        for j = i + 1, #self.game_objects do
            local obj2 = self.game_objects[j]
            if isCollide(obj1, obj2) then
                self.is_collision = true
                if obj1.onCollision then obj1:onCollision(obj2) end
                if obj2.onCollision then obj2:onCollision(obj1) end
            end
        end
    end

    -- Update game objects
    for i, obj in ipairs(self.game_objects) do
        if obj.is_updatable then
            obj:update(dt)
        end
    end
end

return Manager
