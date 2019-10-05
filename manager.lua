-- Central class, singleton

-- imports:
local Player = require 'player'
local Enemy = require 'enemy'
local level1 = require 'level1'

-- Class
Manager = {
    state = 'start',
    level = {},     -- initialize via .load()
    player = {},    -- initialize via .load()
    game_objects = {},
    is_collision = false,   -- for debuging purpose
}

Manager.States = { 'start', 'play' }

function loadLevel(self, level)
    self.level = level
    local map = level.map
    -- Load enemies
    for i, enemy_data in ipairs(level.enemies_data) do
        local enemy = Enemy:new(self, 'classic',
                                (enemy_data.col - 0.5)*map.tile_w + 0.5, (enemy_data.row - 0.5)*map.tile_h + 0.5,
                                enemy_data.rotation, enemy_data.speed)
        print(tostring(enemy.x)..', '..tostring(enemy.y))
        table.insert(self.game_objects, enemy)
    end
    -- Load obstacles
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

function drawStartMenu()
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(244 / 255, 246 / 255, 247 / 255) -- white
    love.graphics.rectangle('fill', 1, 1, width, height)
    love.graphics.setColor(243/255, 156/255, 18/255)    -- yellow, like the player color
    love.graphics.print('PRESS SPACE TO START', width/2 - 75, height/2 - 7, 0)
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

function Manager:restart()
    if self.state == 'start' then
        return
    end

    local new_player = Player:new(self)
    self.player = new_player
    self.game_objects[1] = new_player
    self.state = 'start'
end

function Manager:load()
    self.player = Player:new(self)
    table.insert(self.game_objects, self.player)
    loadLevel(self, level1)
end

function Manager:update(dt)
    if self.state == 'start' then
        if love.keyboard.isDown('space') then
            self.state = 'play'
            --!!self.player:startMoving()
        end
    end

    if self.state == 'play' then
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
end

function Manager:draw()
    if self.state == 'start' then
        drawStartMenu()
    elseif self.state == 'play' then
        self.level:draw()
        for i, obj in ipairs(self.game_objects) do
            if obj.type == 'enemy' then obj:draw() end
        end
        self.player:draw()
    end
end

return Manager
