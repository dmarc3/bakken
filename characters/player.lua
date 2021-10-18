local peachy = require("3rd/peachy/peachy")
local json = require("3rd/json/json")

Player = {}
Player.__index = Player

function Player:new(id, char)
    local instance = setmetatable({}, Player)
    instance.id = id
    
    -- Process character
    instance.spritesheet = love.graphics.newImage("assets/Characters/"..char..".png")
    instance.asepriteMeta = "assets/Characters/"..char..".json"
    instance.animation = {
        idle = peachy.new(instance.asepriteMeta, instance.spritesheet, "idle"),
        walk = peachy.new(instance.asepriteMeta, instance.spritesheet, "walk forward"),
        jump = peachy.new(instance.asepriteMeta, instance.spritesheet, "jump"),
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

    -- Process controller
    local joystickcount = love.joystick.getJoystickCount( )
    if joystickcount == 2 then
        local joysticks = love.joystick.getJoysticks()
        instance.joystick = joysticks[instance.id]
        print("Player "..instance.id.." is using "..instance.joystick:getName())
    else
        print("Player "..instance.id.." is using the keyboard")
        instance.joystick = nil
    end

    -- Process healthbar
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
        if instance.joystick then
            instance.left = "a"
            instance.right = "d"
            instance.j = 1
            instance.a = 3
        else
            instance.left = "a"
            instance.right = "d"
            instance.j = "w"
            instance.a = "e"
        end
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
        if instance.joystick then
            instance.left = "kp1"
            instance.right = "kp3"
            instance.j = 1
            instance.a = 3
        else
            instance.left = "kp1"
            instance.right = "kp3"
            instance.j = "kp5"
            instance.a = "kp4"
        end
        
    end
    instance.xVel = 0
    instance.yVel = 0

    return instance
end

function Player:load()
    -- Define constants
    self.maxSpeed = 60
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.jumpAmount = -450
    self.grounded = true
    self.vel = 80
    self.jump_vel = 475
    self.hasDoubleJump = true
    self.graceTime = 0
    self.graceDuration = 0.1
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
    self.move = false
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

function Player:setState()
    if self.attack then
        self.animationName = "a1"
    elseif not self.grounded then
        self.animationName = "jump"
    elseif self.xVel == 0 then
        self.animationName = "idle"
    else
        self.animationName = "walk"
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
    self:setState()
    if self.joystick then
        self:moveJoystick(dt)
    else
        self:moveKeyboard(dt)
    end
    self:applyGravity(dt)
    self:attack_1(dt)
    self.animation[self.animationName]:update(dt)
    self:updateHurtBox()
    self:updateHitBox()
    self:updateHealthBar(dt)
    self:decreaseGraceTime(dt)
end

function Player:updateHealthBar(dt)
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
        if self.attack_timer == 0 then
            self.animation[self.animationName]:setFrame(1)
        end
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer > self.attack_1_duration then
        self.attack = false
        self.attack_timer = 0
        self.hitbox.width = self.width
    end
end

function Player:moveJoystick(dt)
    local xdir = self.joystick:getAxis(1)
    if xdir > 0.3 then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        self.xDir = 1
        self.xShift = 0
    elseif xdir < -0.3 then
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    else
        self:applyFriction(dt)
    end
end

function Player:moveKeyboard(dt)
    -- Set left animations
    if love.keyboard.isDown(self.left) then
        -- self.physics.body:applyForce(-self.physics.xforce, 0)
        -- self.physics.body:applyLinearImpulse(-self.physics.ximpulse, 0)
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    -- Set right animations
    elseif love.keyboard.isDown(self.right) then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        -- self.physics.body:applyForce(self.physics.xforce, 0)
        -- self.physics.body:applyLinearImpulse(self.physics.ximpulse, 0)
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
    self.hasDoubleJump = true
    self.graceTime = self.graceDuration
end

function Player:jump(button)
    if button == self.j then
        if self.grounded or self.graceTime > 0 then
            self.yVel = self.jumpAmount
            self.grounded = false
            self.graceTime = 0
        elseif self.hasDoubleJump then
            self.hasDoubleJump = false
            self.yVel = self.jumpAmount
        end
    end
end

function Player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
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