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
    Backyard.foreground = peachy.new(asepriteMeta, spritesheet, "foreground")
    Backyard.toys_top = peachy.new(asepriteMeta, spritesheet, "toys_top")
    Backyard.toys_top_transparent = peachy.new(asepriteMeta, spritesheet, "toys_top_transparent")
    Backyard.toys_bottom = peachy.new(asepriteMeta, spritesheet, "toys_bottom")
    Backyard.clouds = peachy.new(asepriteMeta, spritesheet, "clouds")

    local spritesheet = love.graphics.newImage("assets/ui/fight.png")
    local asepriteMeta = "assets/ui/fight.json"
    Fight = {}
    Fight.x = 0
    -- Fight.x = 3*WindowWidth/GlobalScale/4
    Fight.y = 3*WindowHeight/GlobalScale/4
    Fight.zoomin = peachy.new(asepriteMeta, spritesheet, "zoomin")
    Fight.kabam = peachy.new(asepriteMeta, spritesheet, "kabam")
    self.fight_duration = 1.0
    self.fight_timer = 0
    self.fight_timer2 = 0
    self.fight = false
    

    cloudx = 0
    player1 = nil
    player2 = nil
end
  

function fight_scene:update(dt, gameState)
    self:incrementTimers(dt)
    if not self.fight then
        ResetInputs()
    end
    if player1 == nil then
        player1 = player:new(1, gameState.player1)
        player1:load()
    end
    if player2 == nil then
        player2 = player:new(2, gameState.player2)
        player2:load()
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
    cloudx = cloudx - 0.02
end

function fight_scene:drawForeground()
    Backyard.toys_bottom:draw(0,0)
    Backyard.toys_top:draw(0,0)
end

function fight_scene:drawBackground()
    Backyard.base:draw(0,0)
    Backyard.clouds:draw(cloudx,0)
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
