local peachy = require("3rd/peachy/peachy")
local json = require("3rd/json/json")

Player = {}
Player.__index = Player

function Player:new(id, char)
    local instance = setmetatable({}, Player)
    instance.id = id
    instance.char = char
    if id == 1 then
        instance.enemy_id = 2
    else
        instance.enemy_id = 1
    end
    
    -- Process character
    instance.spritesheet = love.graphics.newImage("assets/Characters/"..char..".png")
    instance.asepriteMeta = "assets/Characters/"..char..".json"
    instance.animation = {
        idle = peachy.new(instance.asepriteMeta, instance.spritesheet, "idle"),
        walk = peachy.new(instance.asepriteMeta, instance.spritesheet, "walk forward"),
        jump = peachy.new(instance.asepriteMeta, instance.spritesheet, "jump"),
        airborne = peachy.new(instance.asepriteMeta, instance.spritesheet, "airborne"),
        land = peachy.new(instance.asepriteMeta, instance.spritesheet, "land"),
        block = peachy.new(instance.asepriteMeta, instance.spritesheet, "block"),
        block_start = peachy.new(instance.asepriteMeta, instance.spritesheet, "block start"),
        block_end = peachy.new(instance.asepriteMeta, instance.spritesheet, "block end"),
        a1 = peachy.new(instance.asepriteMeta, instance.spritesheet, "attack 1"),
    }
    instance.animationName = "idle"
    instance.width = instance.animation[instance.animationName]:getWidth()
    instance.height = instance.animation[instance.animationName]:getHeight()
    require("characters/"..char)
    instance.xorigin = xorigin
    instance.block_start_dur = block_start_dur
    instance.block_end_dur = block_end_dur
    instance.body_width_pad = body_width_pad
    instance.body_height_pad = body_height_pad
    instance.x_shift_pad = x_shift_pad
    instance.idle_duration = idle_duration
    instance.attack_1_duration = attack_1_duration
    instance.jump_duration = jump_duration
    instance.airborne_duration = airborne_duration
    instance.land_duration = land_duration
    instance.idle = idle
    instance.a1 = a1
    instance.walk = walk
    instance.block_start = block_start
    instance.block = block
    instance.block_end = block_end


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
        instance.red = 1
        instance.green = 0
        instance.blue = 0
        if instance.joystick then
            instance.left = "dpleft"
            instance.right = "dpright"
            instance.j = "a"
            instance.a = "x"
            instance.b = "triggerleft"
        else
            instance.left = "a"
            instance.right = "d"
            instance.j = "w"
            instance.a = "e"
            instance.b = "q"
        end
    else
        instance.x = WindowWidth/GlobalScale*0.7+instance.width/2
        instance.y = WindowHeight/GlobalScale*0.8
        instance.xShift = instance.x_shift_pad*instance.width
        instance.xDir = -1
        instance.hb_x = WindowWidth/GlobalScale-2-instance.hb_animation:getWidth()
        instance.hb_y = 2
        instance.red = 0
        instance.green = 0
        instance.blue = 1
        if instance.joystick then
            instance.left = "dpleft"
            instance.right = "dpright"
            instance.j = "a"
            instance.a = "x"
            instance.b = "triggerleft"
        else
            instance.left = "kp1"
            instance.right = "kp3"
            instance.j = "kp5"
            instance.a = "kp4"
            instance.b = "kp6"
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
    self.graceDuration = 0.2
    self.attack = false
    self.attack_timer = 0
    self.jumping = false
    self.jump_timer = 0
    self.airborne = false
    self.landing = false
    self.land_timer = 0
    self.anim_shift = 0
    self.blocking = false
    self.block_timer = 0
    self.end_block = false
    self.original_x = self.x
    self.frame_change = false
    self.delete_bodies = {}
    -- Add physics body
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.body:setUserData("player"..self.id)
    self.physics.bw = self.body_width_pad*self.width
    self.physics.bh = self.body_height_pad*self.height
    self.physics.shape = love.physics.newRectangleShape(self.physics.bw, self.physics.bh)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setUserData("player"..self.id)
    -- Hitbox / Hurtbox
    self.health = 92
    self.hurtbox = {}
    self:updateHurtBox()
    self.move = false
    self.invuln = false
    self.invuln_timer = 0
end

function Player:draw()
    self.hb_animation:draw(self.hb_x, self.hb_y)
    if self.animationName == "a1" then
        self.animation[self.animationName]:draw(self.original_x,
                                                self.y,
                                                0,
                                                self.xDir,
                                                1,
                                                self.xorigin,
                                                self.animation[self.animationName]:getHeight()/2)
    else
        self.animation[self.animationName]:draw(self.x,
                                                self.y,
                                                0,
                                                self.xDir,
                                                1,
                                                self.xorigin,
                                                self.animation[self.animationName]:getHeight()/2)
    end
    self:drawHitBox("a1")
    -- end
    if Debug then
        self:drawBody()
    end
end

function Player:setState()
    local current_state = self.animationName
    local current_x = self.x
    if self.attack then
        self.animationName = "a1"
    elseif self.blocking and self.block_timer < self.block_start_dur then
        self.animationName = "block_start"
    elseif self.blocking then
        self.animationName = "block"
    elseif self.end_block then
        self.animationName = "block_end"
    elseif self.jumping and not self.grounded then
        self.animationName = "jump"
    elseif self.landing then
        self.animationName = "land"
    elseif self.airborne and not self.grounded then
        self.animationName = "airborne"
    elseif self.xVel == 0 then
        self.animationName = "idle"
    else
        self.animationName = "walk"
    end
    -- Reset starting frame to 1 if state has changed
    if current_state ~= self.animationName then
        -- print("Changing from "..current_state.." to "..self.animationName)
        self.animation[self.animationName]:setFrame(1)
    end
    -- Apply animation shifts
    local current_frame = self.animation[self.animationName]:getFrame()
    if self.frame_change then
        if self.animationName == "a1" then
            if self[self.animationName]["f"..tostring(current_frame)]["hit"] then
                if self.xDir*self[self.animationName]["f"..tostring(current_frame)]["dx"] ~= 0 then
                    self.anim_shift = self.xDir*self[self.animationName]["f"..tostring(current_frame)]["dx"]
                end
            end
            self.physics.body:setX(self.x+self.xDir*self[self.animationName]["f"..tostring(current_frame)]["dx"])
        end
    end
end

function Player:drawBody()
    bx, by = self.physics.body:getPosition()
    love.graphics.setColor(self.red, self.green, self.blue, 0.2)
    love.graphics.rectangle("fill", bx-self.physics.bw/2, by-self.physics.bh/2, self.physics.bw, self.physics.bh)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", bx, by, 1, 1)
end

function Player:update(dt)
    if self.id == 1 then
        print(self.animationName)
    end
    local current_frame = self.animation[self.animationName]:getFrame()
    local current_anim = self.animationName
    -- Apply physics
    self:syncPhysics()
    self:applyGravity(dt)
    -- Move Player
    if self.joystick then
        self:moveJoystick(dt)
    else
        self:moveKeyboard(dt)
    end
    -- Increment Timers
    self:incrementTimers(dt)
    self:blockTimer(dt)

    self:updateHurtBox()
    self:updateHealthBar(dt)
    -- Update Animation
    self:setState()
    self.animation[self.animationName]:update(dt)
    if current_frame ~= self.animation[self.animationName]:getFrame() or current_anim ~= self.animationName then
        self.frame_change = true
    else
        self.frame_change = false
    end
    self:deleteBodies()
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

function Player:moveJoystick(dt)
    local xdir = self.joystick:getGamepadAxis("leftx")
    local jump_logic = not self.grounded
    local block_logic = not self.blocking
    local attack_logic = not self.attack
    local land_logic = not self.landing
    local logic_test = block_logic and attack_logic or jump_logic and land_logic
    if xdir > 0.3 and logic_test then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = 1
        self.xShift = 0
    elseif self.joystick:isGamepadDown(self.left) and logic_test then
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    elseif xdir < -0.3 and logic_test then
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    elseif self.joystick:isGamepadDown(self.right) and logic_test then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = 1
        self.xShift = 0
    else
        self:applyFriction(dt)
    end
end

function Player:moveKeyboard(dt)
    local jump_logic = not self.grounded
    local block_logic = not self.blocking
    local attack_logic = not self.attack
    local land_logic = not self.landing
    local logic_test = block_logic and attack_logic or jump_logic and land_logic
    -- Set left animations
    if love.keyboard.isDown(self.left) and logic_test then
        if self.xVel > -self.maxSpeed then
            self.xVel = math.min(self.xVel - self.acceleration * dt, -self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = -1
        self.xShift = self.x_shift_pad*self.animation[self.animationName]:getWidth()
    -- Set right animations
    elseif love.keyboard.isDown(self.right) and logic_test then
        if self.xVel < self.maxSpeed then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        end
        self.original_x = self.original_x + self.xVel * dt
        self.xDir = 1
        self.xShift = 0
    else
        self:applyFriction(dt)
    end

end

function Player:damage(d)
    print("Player "..self.id.." hit for "..tostring(d).." damage!")
    self.health = self.health - d
    if self.health < 0 then
        self.health = 0
    end
    self.hb_anim = true
    self.invuln = true
    self.invuln_timer = 0
end

function Player:drawHurtBox()
    love.graphics.setColor(self.red, self.green, self.blue, 0.15)
	love.graphics.rectangle("fill", self.hurtbox.x, self.hurtbox.y, self.hurtbox.width, self.hurtbox.height)
	love.graphics.setColor(1, 1, 1)
end

function Player:updateHurtBox()
    self.hurtbox.width = self.xDir*self.width
    self.hurtbox.height = self.height
    self.hurtbox.x = self.x + self.xShift - self.width/2
    self.hurtbox.y = self.y
end

function Player:drawHitBox(anim)
    -- love.graphics.setColor(self.red, self.green, self.blue, 0.9)
    local current_frame = self.animation[self.animationName]:getFrame()
    if self.animationName == "a1" then
        if self[self.animationName]["f"..tostring(current_frame)]["hit"] then
            self.a1.hitbox.vertices = _G[self.char.."Hitbox"](self.xDir)
            self.a1.hitbox.body = love.physics.newBody(World, self.x, self.y, "static")
            self.a1.hitbox.body:setFixedRotation(true)
            self.a1.hitbox.body:setUserData("player"..self.id.."_a1")
            self.a1.hitbox.shape = love.physics.newPolygonShape(self.a1.hitbox.vertices)
            self.a1.hitbox.fixture = love.physics.newFixture(self.a1.hitbox.body, self.a1.hitbox.shape)
            self.a1.hitbox.fixture:setSensor(true)
            self.a1.hitbox.fixture:setUserData("sensor"..self.id)
            if Debug then
                love.graphics.setColor(1, 1, 1, 0.25)
                love.graphics.polygon("fill", self[anim].hitbox.body:getWorldPoints(self[anim].hitbox.shape:getPoints()))
                love.graphics.setColor(1, 1, 1)
            end
            self.delete_bodies["player"..self.id.."_a1"] = 1
        end
    end
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

function Player:land(collision)
	self.currentGroundCollision = collision
	self.yVel = 0
	self.grounded = true
    self.airborne = false
    self.landing = true
    self.hasDoubleJump = true
    self.graceTime = self.graceDuration
    self.jump_timer = 0
end

function Player:jump()
    if self.joystick then
        if ButtonsPressed[self.id][self.j] == true and not self.attack then
            if self.grounded then
                self.yVel = self.jumpAmount
                self.grounded = false
                self.jumping = true
            elseif self.hasDoubleJump and self.graceTime < 0 then
                self.hasDoubleJump = false
                self.yVel = self.jumpAmount
                self.jumping = true
                self.jump_timer = 0
            end
        end
    else
        if KeysPressed[self.j] == true and not self.attack then
            if self.grounded or self.graceTime > 0 then
                self.yVel = self.jumpAmount
                self.grounded = false
                self.jumping = true
                --self.graceTime = 0
            elseif self.hasDoubleJump then
                self.hasDoubleJump = false
                self.yVel = self.jumpAmount
                self.jumping = true
                self.jump_timer = 0
            end
        end
    end
end

function Player:attack_1()
    local current_attack = self.attack
    if self.joystick then
        if ButtonsPressed[self.id][self.a] == true then
            self.attack = true
        end
    else
        if KeysPressed[self.a] == true then
            self.attack = true
        end
    end
    if not current_attack and self.attack then
        self.original_x = self.physics.body:getX()
    end
end

function Player:incrementTimers(dt)
    -- Jump timers
    if not self.grounded then
        self.jump_timer = self.jump_timer + dt
        self.graceTime = self.graceTime - dt
    end
    if self.jump_timer > self.jump_duration then
        self.jumping = false
        self.jump_timer = 0
        if not self.grounded then
            self.airborne = true
        end
    end
    -- Land timers
    if self.landing then
        self.land_timer = self.land_timer + dt
    end
    if self.land_timer > self.land_duration then
        self.landing = false
        self.land_timer = 0
    end
    -- Attack timer
    if self.attack then
        if self.attack_timer == 0 then
            self.animation[self.animationName]:setFrame(1)
        end
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer > self.attack_1_duration then
        self.attack = false
        self.attack_timer = 0
        -- self.original_x = self.original_x - self.a1["f1"]["x"]
    end
end

function Player:increaseAttack1Timer(dt)
    if self.attack then
        if self.attack_timer == 0 then
            self.animation[self.animationName]:setFrame(1)
        end
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer > self.attack_1_duration then
        self.attack = false
        self.attack_timer = 0
        -- self.original_x = self.original_x - self.a1["f1"]["x"]
    end
end

function Player:blocks()
    -- Current block status
    local cur_block = self.blocking
    -- Set block flag
    if self.joystick then
        if AxisMoved[self.id][self.b] == nil then
            self.blocking = false
        elseif AxisMoved[self.id][self.b] > 0.5 then
            self.blocking = true
        else
            self.blocking = false
        end
    else
        if KeysPressed[self.b] == true then
            self.blocking = true
        else
            self.blocking = false
        end
    end
    
    -- Detect if block has ended
    if cur_block == true and self.blocking == false then
        self.end_block = true
        self.block_timer = 0
    end
end

function Player:blockTimer(dt)
    -- Increment block timer
    if self.blocking then
        self.block_timer = self.block_timer + dt
    elseif self.end_block then
        self.block_timer = self.block_timer + dt
    else
        self.block_timer = 0
    end
    -- Detect completion of end block
    if self.end_block and self.block_timer > self.block_end_dur then
        self.end_block = false
        self.block_timer = 0
    end
end

function Player:deleteBodies()
    if self.delete_bodies ~= {} then
        local bodies = World:getBodies()
        for j, wbody in pairs(bodies) do
            local body_data = wbody:getUserData()
            for delete_body, i in pairs(self.delete_bodies) do
                if body_data == delete_body then
                    wbody:destroy()
                    self.delete_bodies[delete_body] = nil
                end
            end
        end
    end
end

function Player:beginContact(a, b, collision)
	-- print("Being Contact!")
    if self.grounded == true then return end
    local logic_a = a:getUserData() == "player"..self.id and (b:getUserData() == "ground" or b:getUserData() == "player"..self.enemy_id)
    local logic_b = b:getUserData() == "player"..self.id and (a:getUserData() == "ground" or a:getUserData() == "player"..self.enemy_id)
	local nx, ny = collision:getNormal()
	if logic_a then
		if ny > 0 then
			self:land(collision)
		end
	elseif logic_b then
		if ny < 0 then
			self:land(collision)
		end
	end
end

function Player:endContact(a, b, collision)
    -- print("End Contact!")
    local logic_a = a:getUserData() == "player"..self.id and b:getUserData() == "ground"
    local logic_b = b:getUserData() == "player"..self.id and a:getUserData() == "ground"
	if logic_a or logic_b then
		if self.currentGroundCollision == collision then
			self.grounded = false
		end
	end
end

return Player