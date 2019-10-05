-- General class for an Enemy

Enemy = {}
Enemy.type = 'enemy'
Enemy.is_updatable = true

function Enemy:new(manager, name, x, y, rotation, speed)
    local instance = {
        manager = manager,
        name = name,
        x = x,
        y = y,
        rotation = rotation,
        speed = speed,
        vx = speed * math.cos(rotation),
        vy = speed * math.sin(rotation),
        vertices = {-24.5, -24.5, 24.5, -24.5, 24.5, 24.5, -24.5, 24.5 },   -- default
    }
    return setmetatable(instance, {__index = Enemy})
end

function Enemy:update(dt)
    self.x = self.x + self.vx*dt
    self.y = self.y + self.vy*dt
end

function Enemy:draw()   -- default behavior
    love.graphics.setColor(231/255, 76/255, 60/255)
    local points = {}
    for i = 1, #self.vertices - 1, 2 do
        points[i] = self.x + self.vertices[i]
        points[i + 1] = self.y + self.vertices[i + 1]
    end
    love.graphics.polygon('fill', points)
end

return Enemy
