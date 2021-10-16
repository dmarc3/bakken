local peachy = require("3rd/peachy/peachy")
local json = require("3rd/json/json")

Player = {}
Player.__index = Player

function Player:new(id, char)
    local instance = setmetatable({}, Player)
    
    -- Process character
    instance.spritesheet = love.graphics.newImage("assets/Characters/"..char..".png")
    instance.asepriteMeta = "assets/Characters/"..char..".json"
    instance.animation = {
        idle = peachy.new(instance.asepriteMeta, instance.spritesheet, "idle"),
        a1 = peachy.new(instance.asepriteMeta, instance.spritesheet, "attack 1"),
    }
    instance.animationName = "idle"
    instance.width = instance.animation[instance.animationName]:getWidth()
    instance.height = instance.animation[instance.animationName]:getHeight()
    local data = require("characters/"..char)
    instance.body_width_pad = data.body_width_pad
    instance.x_shift_pad = data.x_shift_pad
    instance.idle_duration = data.idle_duration
    instance.attack_1_duration = data.attack_1_duration

    -- Process id + healthbar
    instance.id = id
    instance.hb_spritesheet = love.graphics.newImage("assets/ui/player"..id.."_health_bar.png")
    instance.hb_asepriteMeta = "assets/ui/player"..id.."_health_bar.json"
    instance.hb_animation = peachy.new(instance.hb_asepriteMeta, instance.hb_spritesheet, "Health")
    instance.hb_frame = 1
    instance.hb_animation:setFrame(instance.hb_frame)
    instance.hb_animation:pause()
    instance.hb_anim = false
    instance.hb_anim_timer = 0
    if id == 1 then
        instance.x = WindowWidth/GlobalScale*0.2
        instance.y = WindowHeight/GlobalScale*0.8
        instance.xShift = 0
        instance.xDir = 1
        instance.hb_x = 2
        instance.hb_y = 2
        instance.r = 1
        instance.g = 0
        instance.b = 0
        instance.left = "a"
        instance.right = "d"
        instance.j = "w"
        instance.a = "e"
    else
        instance.x = WindowWidth/GlobalScale*0.7+instance.width/2
        instance.y = WindowHeight/GlobalScale*0.8
        instance.xShift = instance.x_shift_pad*instance.width
        instance.xDir = -1
        instance.hb_x = WindowWidth/GlobalScale-2-instance.hb_animation:getWidth()
        instance.hb_y = 2
        instance.r = 0
        instance.g = 0
        instance.b = 1
        instance.left = "kp1"
        instance.right = "kp3"
        instance.j = "kp5"
        instance.a = "kp4"
    end
    instance.xVel = 0
    instance.yVel = 0

    return instance
end

function Player:load()
    -- Define constants
    self.maxSpeed = 80
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.jumpAmount = -450
    self.grounded = true
    self.vel = 80
    self.jump_vel = 475
    -- Add physics body
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.bw = self.body_width_pad*self.width
    self.physics.bh = self.height
    self.physics.shape = love.physics.newRectangleShape(self.physics.bw, self.physics.bh)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    -- Hitbox / Hurtbox
    self.health = 92
    self.hurtbox = {}
    self:updateHurtBox()
    self.attack = false
    self.attack_timer = 0
    self.hitbox ={}
    self.hitbox.x = self.x+self.width
    self.hitbox.y = self.y+self.height*0.4
    self.hitbox.width = self.width
    self.hitbox.height = self.height*0.2
    self.invuln = false
    self.invuln_timer = 0
end

function Player:draw()
    self.hb_animation:draw(self.hb_x, self.hb_y)
    self.animation[self.animationName]:draw(self.x + self.xShift - self.body_width_pad*self.width,
                                            self.y - self.height/2, 0, self.xDir, 1)
    if Debug then
        self:drawBody()
    end
end

function Player:drawBody()
    bx, by = self.physics.body:getPosition()
    love.graphics.setColor(self.r, self.g, self.b, 0.2)
    love.graphics.rectangle("fill", bx-self.physics.bw/2, by-self.physics.bh/2, self.physics.bw, self.physics.bh)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", bx, by, 1, 1)
end

function Player:update(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
    -- Process attack animations
    self:attack_1(dt)
    if self.attack then
        if self.animationName ~= "a1" then
            self.animationName = "a1"
            self.animation[self.animationName]:setFrame(1)
            --self.animation[self.animationName]:play()
        end
    else
        if self.animationName ~= "idle" then
            self.animationName = "idle"
            self.animation[self.animationName]:setFrame(1)
            self.animation[self.animationName]:play()
        end
    end
    self.animation[self.animationName]:update(dt)
    self:updateHurtBox()
    self:updateHitBox()

    -- Process health bar
    if self.hb_anim == true then
        self.hb_anim_timer = self.hb_anim_timer + dt
    end
    if self.hb_anim_timer > 0.005 then
        if self.hb_frame < 93 then
            self.hb_animation:nextFrame()
            self.hb_frame = self.hb_frame + 1
        end
    end
    if self.health == 93 - self.hb_animation:getFrame() then
        self.hb_anim = false
        self.hb_anim_timer = 0
    end
    self.hb_animation:setFrame(self.hb_frame)
    self.hb_animation:update(dt)
    
    -- Process invulnerability
    if self.invuln == true then
        self.invuln_timer = self.invuln_timer + dt
    end
    if self.invuln_timer > 0.7 then
        self.invuln = false
        self.invuln_timer = 0
    end
    
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:attack_1(dt)
    if self.attack then
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer > self.attack_1_duration then
        self.attack = false
        self.attack_timer = 0
        self.hitbox.width = self.width
    end
end

function Player:move(dt)
    -- Set left animations
    if love.keyboard.isDown(self.left) then
        -- self.physics.body:applyForce(-self.physics.xforce, 0)
        -- self.physics.body:applyLinearImpulse(-self.physics.ximpulse, 0)
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        -- self.xVel = -self.vel
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    -- Set right animations
    elseif love.keyboard.isDown(self.right) then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        -- self.physics.body:applyForce(self.physics.xforce, 0)
        -- self.physics.body:applyLinearImpulse(self.physics.ximpulse, 0)
        -- self.xVel = self.vel
        self.xDir = 1
        self.xShift = 0
    else
        self:applyFriction(dt)
    end
end

function Player:damage(d)
    print("Player 1 hit for "..tostring(d).." damage!")
    self.health = self.health - d
    if self.health < 0 then
        self.health = 0
    end
    self.hb_anim = true
    self.invuln = true
    self.invuln_timer = 0
end

function Player:drawHurtBox()
    love.graphics.setColor(self.r, self.g, self.b, 0.15)
	love.graphics.rectangle("fill", self.hurtbox.x, self.hurtbox.y, self.hurtbox.width, self.hurtbox.height)
	love.graphics.setColor(1, 1, 1)
end

function Player:updateHurtBox()
    self.hurtbox.width = self.xDir*self.width
    self.hurtbox.height = self.height
    self.hurtbox.x = self.x + self.xShift - self.width/2
    self.hurtbox.y = self.y
end

function Player:drawHitBox()
    love.graphics.setColor(self.r, self.g, self.b, 0.5)
	love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.width, self.hitbox.height)
	love.graphics.setColor(1, 1, 1)
end

function Player:updateHitBox()
    self.hitbox.x = self.x+self.width
    self.hitbox.y = self.y+self.height*0.4
    self.hitbox.width = self.width
    self.hitbox.height = self.height*0.2
end

-- function Player:detectHit(x, y, w, h)
--     if x-2*w > self.hurtbox.x and x-2*w < self.hurtbox.x + self.hurtbox.width then
--         if y > self.hurtbox.y and y < self.hurtbox.y + self.hurtbox.height then
--             if not self.invuln then
--                 self:damage(10)
--             end
--         end
--     end
-- end

function Player:applyGravity(dt)
    if not self.grounded then
        -- self.physics.body:applyForce(0, Gravity)
        self.yVel = self.yVel + Gravity*dt
    end
end

function Player:applyFriction(dt)
    if self.xVel > 0 then
        self.xVel = math.max(self.xVel - self.friction * dt, 0)
    elseif self.xVel < 0 then
        self.xVel = math.min(self.xVel + self.friction * dt, 0)
    end
end

function Player:BeginContact(a, b, collision)
	print("Being Contact!")
    if self.grounded == true then return end
	local nx, ny = collision:getNormal()
	if a == self.physics.fixture then
		if ny > 0 then
			self:land(collision)
		end
	elseif b == self.physics.fixture then
		if ny < 0 then
			self:land(collision)
		end
	end
end

function Player:land(collision)
	self.currentGroundCollision = collision
	self.yVel = 0
	self.grounded = true
end

function Player:jump(key)
    if key == self.j and self.grounded then
        self.yVel = self.jumpAmount
        self.grounded = false
    end
end

function Player:EndContact(a, b, collision)
    print("End Contact!")
	if a == self.physics.fixture or b == self.physics.fixture then
		if self.currentGroundCollision == collision then
			self.grounded = false
		end
	end
end

return Player