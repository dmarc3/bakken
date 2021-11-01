local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

local fight_scene = scene:new("fight")

-- Gravity = 9.81
Gravity = 300
Meter = 64
Friction = 0.0
love.physics.setMeter(Meter)

function fight_scene:load()
    World = love.physics.newWorld(0, Meter*Gravity, false)
    World:setCallbacks(beginContact, endContact)
     -- Create Ground and Walls
    Ground = {}
    Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    Ground.body:setUserData("ground")
    Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
    Ground.fixture = love.physics.newFixture(Ground.body, Ground.shape)
    Ground.fixture:setFriction(Friction)
    Ground.fixture:setUserData("ground")
    Ground.y = WindowHeight/GlobalScale + 10
    Walls = {}
    Walls.left = {}
    Walls.left.body = love.physics.newBody(World, -10, WindowHeight/GlobalScale/2, "static")
    Walls.left.body:setUserData("wall")
    Walls.left.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    Walls.left.fixture = love.physics.newFixture(Walls.left.body, Walls.left.shape)
    Walls.left.fixture:setUserData("wall")
    Walls.right = {}
    Walls.right.body = love.physics.newBody(World, WindowWidth/GlobalScale+10, WindowHeight/GlobalScale/2, "static")
    Walls.right.body:setUserData("wall")
    Walls.right.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    Walls.right.fixture = love.physics.newFixture(Walls.right.body, Walls.right.shape)
    Walls.right.fixture:setUserData("wall")
    Toys = {}
    Toys.body = love.physics.newBody(World, WindowWidth/GlobalScale*0.765, WindowHeight/GlobalScale*0.68, "static")
    Toys.body:setUserData("obstacle")
    Toys.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.15, WindowHeight/GlobalScale*0.015)
    Toys.fixture = love.physics.newFixture(Toys.body, Toys.shape)
    Toys.fixture:setFriction(Friction)
    Toys.fixture:setUserData("obstacle")
    Roof = {}
    Roof.body = love.physics.newBody(World, WindowWidth/GlobalScale*0.797, WindowHeight/GlobalScale*0.455, "static")
    Roof.body:setUserData("obstacle")
    Roof.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.0975, WindowHeight/GlobalScale*0.11)
    Roof.fixture = love.physics.newFixture(Roof.body, Roof.shape)
    Roof.fixture:setFriction(Friction)
    Roof.fixture:setUserData("obstacle")

    local spritesheet = love.graphics.newImage("assets/levels/backyard.png")
    local asepriteMeta = "assets/levels/backyard.json"
    Backyard = {}
    Backyard.base = peachy.new(asepriteMeta, spritesheet, "idle")
    Backyard.bush = peachy.new(asepriteMeta, spritesheet, "bush")
    Backyard.tree = peachy.new(asepriteMeta, spritesheet, "tree")
    Backyard.foreground = peachy.new(asepriteMeta, spritesheet, "foreground")
    Backyard.toys = peachy.new(asepriteMeta, spritesheet, "toys")
    Backyard.toys_top = peachy.new(asepriteMeta, spritesheet, "toys_top")
    Backyard.toys_top_transparent = peachy.new(asepriteMeta, spritesheet, "toys_top_transparent")
    Backyard.toys_bottom = peachy.new(asepriteMeta, spritesheet, "toys_bottom")
    Backyard.sun = peachy.new(asepriteMeta, spritesheet, "sun")
    Backyard.clouds1 = peachy.new(asepriteMeta, spritesheet, "clouds")
    Backyard.clouds2 = peachy.new(asepriteMeta, spritesheet, "clouds")
    Backyard.bird1 = peachy.new(asepriteMeta, spritesheet, "bird")
    Backyard.bird2 = peachy.new(asepriteMeta, spritesheet, "bird")

    local spritesheet = love.graphics.newImage("assets/ui/fight.png")
    local asepriteMeta = "assets/ui/fight.json"
    Fight = {}
    Fight.x = 0
    Fight.y = 3*WindowHeight/GlobalScale/4
    Fight.x0 = Fight.x
    Fight.y0 = Fight.y
    Fight.zoomin = peachy.new(asepriteMeta, spritesheet, "zoomin")
    Fight.kabam = peachy.new(asepriteMeta, spritesheet, "kabam")
    self.fight_duration = 1.0
    self.fight_timer = 0
    self.fight_timer2 = 0
    self.fight = false
    
    -- Moving background
    self.cloudx = 0
    self.birdx = 100
    self.sunx = 0

    player1 = nil
    player2 = nil
end
  

function fight_scene:update(dt, gameState)
    -- Load players for the first time
    if player1 == nil then
        player1 = player:new(1, gameState.player1)
        player1:load()
    end
    if player2 == nil then
        player2 = player:new(2, gameState.player2)
        player2:load()
    end
    -- Increment Timers
    self:incrementTimers(dt)
    -- Supress controller inputs
    if not self.fight or player1.knocked_out or player2.knocked_out then
        ResetInputs()
        if player1.knocked_out or player2.knocked_out then
            self:resetFighters(dt)
        end
    end
    World:update(dt)
    player1:update(dt)
    player2:update(dt)
    self:updateFight(dt)
    self:updateBackground(dt)
    CheckKeys()
end

function fight_scene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawBackground()
    if player1 ~= nil then
        player1:draw()
    end
    if player2 ~= nil then
        player2:draw()
    end
    self:drawForeground()
    self:drawFight()
    love.graphics.pop()

    if Debug then
        if player1 ~= nil then
            love.graphics.print("xVel: "..player1.xVel, 20, 100)
            love.graphics.print("yVel: "..player1.yVel, 20, 120)
            love.graphics.print("MouseX: "..love.mouse:getX(), 20, 140)
            love.graphics.print("MouseY: "..love.mouse:getY(), 20, 160)
        end
    end
end

function fight_scene:updateBackground(dt)
    Backyard.base:update(dt)
    Backyard.bush:update(dt)
    Backyard.tree:update(dt)
    Backyard.foreground:update(dt)
    Backyard.toys:update(dt)
    Backyard.toys_top:update(dt)
    Backyard.toys_top_transparent:update(dt)
    Backyard.toys_bottom:update(dt)
    Backyard.bird1:update(dt)
    Backyard.bird2:update(dt)
    Backyard.clouds1:update(dt)
    Backyard.clouds2:update(dt)
    Backyard.sun:update(dt)
    self.cloudx = self.cloudx - 0.02
    if self.cloudx < -WindowWidth/GlobalScale then
        self.cloudx = self.cloudx + WindowWidth/GlobalScale
    end
    self.birdx = self.birdx - 0.5
    if self.birdx < -2*WindowWidth/GlobalScale then
        self.birdx = self.birdx + 2*WindowWidth/GlobalScale
    end
    self.sunx = self.sunx - 0.001
end

function fight_scene:drawForeground()
    Backyard.toys_bottom:draw(0,0)
    Backyard.toys_top:draw(0,0)
end

function fight_scene:drawBackground()
    Backyard.base:draw(0,0)
    Backyard.bush:draw(0,0)
    Backyard.tree:draw(0,0)
    Backyard.toys:draw(0,0)
    Backyard.sun:draw(self.sunx, 0)
    Backyard.clouds1:draw(self.cloudx,0)
    Backyard.clouds2:draw(self.cloudx+WindowWidth/GlobalScale,0)
    Backyard.bird1:draw(self.birdx, 0)
    Backyard.bird2:draw(self.birdx+2*WindowWidth/GlobalScale, 0)
    Backyard.foreground:draw(0,0)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.polygon("fill", Toys.body:getWorldPoints(Toys.shape:getPoints()))
        love.graphics.polygon("fill", Roof.body:getWorldPoints(Roof.shape:getPoints()))
        gx, gy = Ground.body:getPosition()
        love.graphics.rectangle("fill", gx-WindowWidth/GlobalScale/2, gy-10, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", gx, gy, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function fight_scene:incrementTimers(dt)
    self.fight_timer = self.fight_timer + dt
end

function fight_scene:updateFight(dt)
    Fight.zoomin:update(dt)
    Fight.kabam:update(dt)
    if self.fight_timer < self.fight_duration then
        -- Fight.x = Fight.x - 3*(WindowWidth/GlobalScale/self.fight_duration)*dt/4
        Fight.y = Fight.y - 3*(WindowHeight/GlobalScale/self.fight_duration)*dt/4
    end
end

function fight_scene:drawFight()
    if self.fight_timer < self.fight_duration then
        Fight.kabam:draw(Fight.x, Fight.y)
    elseif self.fight_timer < self.fight_duration*2 then
        Fight.kabam:draw(Fight.x, Fight.y)
    elseif self.fight_timer < self.fight_duration*3 then
        love.graphics.setColor(1, 1, 1, (3-self.fight_timer/self.fight_duration))
        Fight.kabam:draw(Fight.x, Fight.y)
        love.graphics.setColor(1, 1, 1, 1)
    else
        self.fight = true
    end
end

function fight_scene:resetFighters(dt)
    -- Reset player1
    player1.physics.fixture:setMask(2)
    if player1.x > player1.x0 then
        if player1.joystick then
            ButtonsPressed[player1.id][player1.left] = true
        end
    else
        if player1.joystick then
            ButtonsPressed[player1.id][player1.right] = true
        end
    end
    if math.abs(player1.x - player1.x0) < 0.05*player1.x0 then
        ButtonsPressed[player1.id][player1.left] = nil
        ButtonsPressed[player1.id][player1.right] = nil
        player1.physics.body:setPosition(player1.x0, player1.y0)
        player1.xDir = 1.0
    end
    -- Reset player2
    player2.physics.fixture:setMask(2)
    if player2.x > player2.x0 then
        if player2.joystick then
            ButtonsPressed[player2.id][player2.left] = true
        end
    else
        if player2.joystick then
            ButtonsPressed[player2.id][player2.right] = true
        end
    end
    if math.abs(player2.x - player2.x0) < 0.05*player2.x0 then
        ButtonsPressed[player2.id][player2.left] = nil
        ButtonsPressed[player2.id][player2.right] = nil
        player2.physics.body:setPosition(player2.x0, player2.y0)
        player2.xDir = -1.0
    end
    -- Switch boolean
    if (player1.x - player1.x0 < 0.05*player1.x0) and (player2.x - player2.x0 < 0.05*player2.x0) then
        player1.knocked_out = false
        player2.knocked_out = false
        player1.physics.fixture:setMask()
        player2.physics.fixture:setMask()
        self.fight = false
    end
end

function ResetInputs()
    KeysPressed = {}
    ButtonsPressed = {}
    ButtonsPressed[1] = {}
    ButtonsPressed[2] = {}
    AxisMoved = {}
    AxisMoved[1] = {}
    AxisMoved[2] = {}
end

function beginContact(a, b, collision)
    -- Process Damage
    if (a:getUserData() == "sensor1" and b:getUserData() == "player2") or (b:getUserData() == "sensor1" and a:getUserData() == "player2") then
        if not player2.invuln then
            if not player2.blocking then
                player2:damage(10)
            else
                player2:damage(10*0.2)
            end
        end
    end
    if (a:getUserData() == "sensor2" and b:getUserData() == "player1") or (b:getUserData() == "sensor2" and a:getUserData() == "player1") then
        if not player1.invuln then
            if not player1.blocking then
                player1:damage(10)
            else
                player1:damage(10*0.2)
            end
        end
    end
	player1:beginContact(a, b, collision)
    player2:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	player1:endContact(a, b, collision)
    player2:endContact(a, b, collision)
end

function CheckKeys()
    local function pconcat(tab)
        local keyset={}
        local n=0
        for k,v in pairs(tab) do
            n=n+1
            keyset[n]=k
        end
        return table.concat(keyset, " ")
    end
    player1:jump()
    player2:jump()
    player1:attack_1()
    player2:attack_1()
    player1:blocks()
    player2:blocks()
    --print(pconcat(AxisMoved[1]))
end

return fight_scene
