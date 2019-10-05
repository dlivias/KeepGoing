-- Player character class

Player = {}
Player.type = 'player'
Player.is_updatable = true
Player.Mods = { 'normal', 'repulsion', 'wait_for_turn', 'stop' }

-- x, y - start position, default - center of the screen
function Player:new(manager, x, y)
    -- instance - экземпляр класса Player
    local instance = {    -- fields
        manager = manager,
        mod = 'stop',     -- 1 of Mods
        x = x or math.floor((1 + love.graphics.getWidth()) / 2 + 0.5),  -- default - center of screen
        y = y or math.floor((1 + love.graphics.getHeight()) / 2 + 0.5),
        rotation = -math.pi / 2,    -- (-pi, pi]
        vx = 0,
        vy = 0,
        speed = 0,  -- px/seconds
        max_speed = 300,
        acceleration = 600, -- from 0 to max_speed
        deceleration = 600,    -- from speed to 0
        vertices = { -15, -10, 15, 0, -15, 10 },

        collision_objs_set = {},
    }
    setmetatable(instance, { __index = Player }) -- теперь instance может использовать методы и поля Player
    return instance
end

function Player:startMoving()
    if self.mod == 'stop' or self.mod == 'wait_for_turn' then
        self.mod = 'normal'
    end
end

-- WASD, that already treated should not affect before they will released
local prv_treated_keys = { -- prv_ means var may be used only in the closest function below (private)
    ['w'] = false, ['a'] = false, ['s'] = false, ['d'] = false
}

local function normalModUpdate(self, dt)
    -- Повороты (user control)
    local treated_keys = prv_treated_keys
    for key, is_treated in pairs(treated_keys) do
        if is_treated and not love.keyboard.isDown(key) then
            treated_keys[key] = false
        end
    end
    if love.keyboard.isDown('a') and not treated_keys['a']
    and (self.rotation == -math.pi / 2 or self.rotation == math.pi / 2) then
        self.rotation = math.pi
        treated_keys['a'] = true
    end
    if love.keyboard.isDown('d') and not treated_keys['d']
    and (self.rotation == -math.pi / 2 or self.rotation == math.pi / 2) then
        self.rotation = 0
        treated_keys['d'] = true
    end
    if love.keyboard.isDown('w') and not treated_keys['w']
    and (self.rotation == 0 or self.rotation == math.pi) then
        self.rotation = -math.pi / 2
        treated_keys['w'] = true
    end
    if love.keyboard.isDown('s') and not treated_keys['s']
    and (self.rotation == 0 or self.rotation == math.pi) then
        self.rotation = math.pi / 2
        treated_keys['s'] = true
    end

    -- Вычисление скорости
    self.vx = self.speed * math.cos(self.rotation)
    self.vy = self.speed * math.sin(self.rotation)
    if self.speed ~= self.max_speed then
        self.speed = self.speed + self.acceleration * dt
        if self.speed > self.max_speed then self.speed = self.max_speed end
    end

    -- Вычесление позиции
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    local screen_w, screen_h = love.graphics.getDimensions()
    if self.x >= screen_w then self.x = self.x - screen_w
    elseif self.x < 0 then self.x = self.x + screen_w end
    if self.y >= screen_h then self.y = self.y - screen_h
    elseif self.y < 0 then self.y = self.y + screen_h end
end

local function repulsionModUpdate(self, dt)
    -- Вычесление скорости
    self.vx = self.speed * math.cos(self.rotation)
    self.vy = self.speed * math.sin(self.rotation)
    if self.speed ~= 0 then
        self.speed = self.speed + self.deceleration * dt
        if self.speed > 0 then self.speed = 0 end
    end

    -- Вычесление позиции
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Изменение мода
    if self.speed == 0 then
        self.collision_objs_set = {}
        self.mod = 'stop'
        self.manager:restart()
    end
end

local function waitForTurnModUpdate(self, dt)
    -- Повороты (user control)
    for key, is_treated in pairs(prv_treated_keys) do
        prv_treated_keys[key] = false
    end
    self.mod = 'normal' -- if appropriate move key pressed
    if love.keyboard.isDown('a') and (self.rotation == -math.pi / 2 or self.rotation == math.pi / 2) then
        self.rotation = math.pi
        prv_treated_keys['a'] = true
    elseif love.keyboard.isDown('d') and (self.rotation == -math.pi / 2 or self.rotation == math.pi / 2) then
        self.rotation = 0
        prv_treated_keys['d'] = true
    elseif love.keyboard.isDown('w') and (self.rotation == 0 or self.rotation == math.pi) then
        self.rotation = -math.pi / 2
        prv_treated_keys['w'] = true
    elseif love.keyboard.isDown('s') and (self.rotation == 0 or self.rotation == math.pi) then
        self.rotation = math.pi / 2
        prv_treated_keys['s'] = true
    else
        self.mod = 'wait_for_turn'
    end
end

function Player:update(dt)
    if self.mod == 'normal' then
        normalModUpdate(self, dt)
    elseif self.mod == 'repulsion' then
        repulsionModUpdate(self, dt)
    elseif self.mod == 'wait_for_turn' then
        waitForTurnModUpdate(self, dt)
    elseif self.mod == 'stop' then
        -- nothing to do
    end
end

function Player:onCollision(obj)
    if not self.collision_objs_set[obj] then
        self.speed = -self.speed * 0.75
        self.mod = 'repulsion'

        -- For not collide with one object twice (or more)
        self.collision_objs_set[obj] = true
    end
end

function Player:draw()
    love.graphics.setColor(243/255, 156/255, 18/255)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    love.graphics.polygon('fill', self.vertices)
    love.graphics.pop()
end

return Player
