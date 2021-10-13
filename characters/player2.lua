local peachy = require("3rd/peachy/peachy")

-- only one player2, so no metatable shenanigans here
local player2 = {}

function player2:load()
    self.width = 12
    self.height = 22
    self.x = 220
    self.y = 140 - self.height
    self.vel = 50
    self.spritesheet = love.graphics.newImage("assets/ui/player2_health_bar.png")
    self.asepriteMeta = "assets/ui/player2_health_bar.json"
    self.animation = peachy.new(self.asepriteMeta, self.spritesheet, "Health")
    self.frame = 1
    self.animation:setFrame(self.frame)
    self.animation:pause()
    self.anim = false
    self.anim_timer = 0
    self.health = 92
    self.hurtbox = {}
    self.hurtbox.x = self.x
    self.hurtbox.y = self.y
    self.hurtbox.width = self.width
    self.hurtbox.height = self.height
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

function player2:draw()
    self.animation:draw(WindowWidth/GlobalScale-2-self.animation:getWidth(), 2)
    love.graphics.setColor(0, 0, 0.8, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
    self:drawHurtBox()
    if self.attack then
        self:drawHitBox()
    end
end

function player2:update(dt)
    self:move(dt)
    self:attack_1(dt)
    self:updateHurtBox()
    self:updateHitBox()

    -- Process health bar
    if self.anim == true then
        self.anim_timer = self.anim_timer + dt
    end
    if self.anim_timer > 0.005 then
        if self.frame < 93 then
            self.animation:nextFrame()
            self.frame = self.frame + 1
        end
    end
    if self.health == 93 - self.animation:getFrame() then
        self.anim = false
        self. anim_timer = 0
    end
    self.animation:setFrame(self.frame)
    self.animation:update(dt)
    
    -- Process invulnerability
    if self.invuln == true then
        self.invuln_timer = self.invuln_timer + dt
    end
    if self.invuln_timer > 0.5 then
        self.invuln = false
        self.invuln_timer = 0
    end
end

function player2:attack_1(dt)
    if self.attack then
        self.attack_timer = self.attack_timer + dt
    end
    if self.attack_timer < 0.1 then
        self.hitbox.width = self.hitbox.width + 1
    elseif self.attack_timer < 0.2 then
        self.hitbox.width = self.hitbox.width - 1
    else
        self.attack = false
        self.attack_timer = 0
        self.hitbox.width = self.width
    end

end

function player2:move(dt)
    -- Jump
    if love.keyboard.isDown("space") then
        
    end
    -- Set left animations
    if love.keyboard.isDown("kp1") then
        self.x = self.x - self.vel*dt
    -- Set right animations
    elseif love.keyboard.isDown("kp3") then
        self.x = self.x + self.vel*dt
    end
    -- Apply gravity
    self.y = self.y + Gravity*dt*dt
    if self.y > 140 - self.height then
        self.y = 140 - self.height
    end
end

function player2:damage(d)
    print("Player 2 hit for "..tostring(d).." damage!")
    self.health = self.health - d
    if self.health < 0 then
        self.health = 0
    end
    self.anim = true
    self.invuln = true
    self.invuln_timer = 0
end

function player2:drawHurtBox()
    love.graphics.setColor(0, 0, 1, 0.5)
	love.graphics.rectangle("fill", self.hurtbox.x-2, self.hurtbox.y-2, self.hurtbox.width+4, self.hurtbox.height+4)
	love.graphics.setColor(1, 1, 1)
end

function player2:updateHurtBox()
    self.hurtbox.x = self.x
    self.hurtbox.y = self.y
    self.hurtbox.width = self.width
    self.hurtbox.height = self.height
end

function player2:drawHitBox()
    love.graphics.setColor(0, 0, 1, 0.5)
	love.graphics.rectangle("fill", self.hitbox.x-2*self.hitbox.width, self.hitbox.y, self.hitbox.width, self.hitbox.height)
	love.graphics.setColor(1, 1, 1)
end

function player2:updateHitBox()
    self.hitbox.x = self.x+self.width
    self.hitbox.y = self.y+self.height*0.4
    self.hitbox.width = self.width
    self.hitbox.height = self.height*0.2
end

function player2:detectHit(x, y, w, h)
    if x+w > self.hurtbox.x and x+w < self.hurtbox.x + self.hurtbox.width then
        if y > self.hurtbox.y and y < self.hurtbox.y + self.hurtbox.height then
            if not self.invuln then
                self:damage(10)
            end
        end
    end
end

return player2