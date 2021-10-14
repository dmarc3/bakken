local peachy = require("3rd/peachy/peachy")

-- only one player1, so no metatable shenanigans here
local player1 = {}

function player1:load()
    -- Health Bar
    self.hb_spritesheet = love.graphics.newImage("assets/ui/player1_health_bar.png")
    self.hb_asepriteMeta = "assets/ui/player1_health_bar.json"
    self.hb_animation = peachy.new(self.hb_asepriteMeta, self.hb_spritesheet, "Health")
    self.hb_frame = 1
    self.hb_animation:setFrame(self.hb_frame)
    self.hb_animation:pause()
    self.hb_anim = false
    self.hb_anim_timer = 0
    -- Sprite Animation
    self.spritesheet = love.graphics.newImage("assets/Characters/drew.png")
    self.asepriteMeta = "assets/Characters/drew.json"
    self.animation = {
        idle = peachy.new(self.asepriteMeta, self.spritesheet, "idle"),
        a1 = peachy.new(self.asepriteMeta, self.spritesheet, "attack 1"),
    }
    self.animationName = "idle"
    -- Player location
    self.width = self.animation[self.animationName]:getWidth()
    self.height = self.animation[self.animationName]:getHeight()
    self.x = WindowWidth/GlobalScale*0.2
    self.y = WindowHeight/GlobalScale*0.8
    self.vel = 50
    self.jump_vel = 175
    self.xVel = 0
    self.yVel = 0
    self.xShift = 0
    self.xDir = 1
    -- Add physics
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.bw = 0.32*self.width
    self.physics.bh = self.height
    self.physics.shape = love.physics.newRectangleShape(self.physics.bw, self.physics.bh)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.grounded = true
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

function player1:draw()
    self.hb_animation:draw(2, 2)
    self.animation[self.animationName]:draw(self.x + self.xShift - 0.32*self.width,
                                            self.y - self.height/2, 0, self.xDir, 1)
    
    if Debug then
        self:drawBody()
    end
end

function player1:drawBody()
    bx, by = self.physics.body:getPosition()
    love.graphics.setColor(1,0,0,0.2)
    love.graphics.rectangle("fill", bx-self.physics.bw/2, by-self.physics.bh/2, self.physics.bw, self.physics.bh)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", bx, by, 1, 1)
end

function player1:update(dt)
    self:move(dt)
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

    -- Sync Phyiscs
    self:applyGravity(dt)
    self:syncPhysics()
end

function player1:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    -- self.x = bx - self.width/2
    -- self.y = by - self.height/2
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function player1:attack_1(dt)
    if self.attack then
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer > 0.60 then
        self.attack = false
        self.attack_timer = 0
        self.hitbox.width = self.width
    end
end

function player1:move(dt)
    -- Jump
    if love.keyboard.isDown("w") then
        self.yVel = -self.jump_vel
        self.physics.grounded = false
    end
    -- Set left animations
    if love.keyboard.isDown("a") then
        self.xVel = -self.vel
        -- self.x = self.x - self.vel*dt
        self.xDir = -1
        self.xShift = 0.65*self.animation[self.animationName]:getWidth()
    -- Set right animations
    elseif love.keyboard.isDown("d") then
        self.xVel = self.vel
        -- self.x = self.x + self.vel*dt
        self.xDir = 1
        self.xShift = 0
    else
        self.xVel = 0
    end
end

function player1:damage(d)
    print("Player 1 hit for "..tostring(d).." damage!")
    self.health = self.health - d
    if self.health < 0 then
        self.health = 0
    end
    self.hb_anim = true
    self.invuln = true
    self.invuln_timer = 0
end

function player1:drawHurtBox()
    love.graphics.setColor(1, 0, 0, 0.15)
	love.graphics.rectangle("fill", self.hurtbox.x, self.hurtbox.y, self.hurtbox.width, self.hurtbox.height)
	love.graphics.setColor(1, 1, 1)
end

function player1:updateHurtBox()
    self.hurtbox.width = self.xDir*self.width
    self.hurtbox.height = self.height
    self.hurtbox.x = self.x + self.xShift - self.width/2
    self.hurtbox.y = self.y
end

function player1:drawHitBox()
    love.graphics.setColor(1, 0, 0, 0.5)
	love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.width, self.hitbox.height)
	love.graphics.setColor(1, 1, 1)
end

function player1:updateHitBox()
    self.hitbox.x = self.x+self.width
    self.hitbox.y = self.y+self.height*0.4
    self.hitbox.width = self.width
    self.hitbox.height = self.height*0.2
end

function player1:detectHit(x, y, w, h)
    if x-2*w > self.hurtbox.x and x-2*w < self.hurtbox.x + self.hurtbox.width then
        if y > self.hurtbox.y and y < self.hurtbox.y + self.hurtbox.height then
            if not self.invuln then
                self:damage(10)
            end
        end
    end
end

function player1:applyGravity(dt)
    if not self.physics.grounded then
        self.yVel = self.yVel + Gravity * dt
    end
end

function player1:beginContact(a, b, collision)
	print("Being Contact!")
    if self.physics.grounded == true then return end
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

function player1:land(collision)
	self.currentGroundCollision = collision
	self.yVel = 0
	self.physics.grounded = true
end

function player1:endContact(a, b, collision)
    print("End Contact!")
	if a == self.physics.fixture or b == self.physics.fixture then
		if self.currentGroundCollision == collision then
			self.physics.grounded = false
		end
	end
end

return player1