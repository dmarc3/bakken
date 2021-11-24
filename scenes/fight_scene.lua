local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

local fight_scene = scene:new("fight")

-- Gravity = 9.81
Gravity = 10
Meter = 64
Friction = 5
love.physics.setMeter(Meter)

function fight_scene:load(GameState)
    World = love.physics.newWorld(0, Meter*Gravity, false)
    World:setCallbacks(beginContact, endContact)

    -- Load canvas
    self.canvas = love.graphics.newCanvas(WindowWidth, WindowHeight)
    self.canvas1 = love.graphics.newCanvas(WindowWidth, WindowHeight)
    self.canvas2 = love.graphics.newCanvas(WindowWidth, WindowHeight)

    -- Import level
    local level = "curlew"
    Level = require("levels/"..level)
    Level:load(GameState.player1, GameState.player2, self.canvas)
    --[[ if Level.name == "curlew" then
        local water_effect = love.filesystem.read("levels/water_shader.glsl")
        self.eff = love.graphics.newShader(water_effect)
    end ]]

    -- Import fight ui
    local spritesheet = love.graphics.newImage("assets/ui/fight.png")
    local asepriteMeta = "assets/ui/fight.json"
    Fight = {}
    Fight.x = 0
    Fight.y = 3*WindowHeight/GlobalScale/4
    Fight.x0 = Fight.x
    Fight.y0 = Fight.y
    Fight.kabam = peachy.new(asepriteMeta, spritesheet, "kabam")
    self.fight_duration = 1.0
    self.fight_timer = 0
    self.fight_timer2 = 0
    self.fight = false
    self.delta = 0

    -- Set players to nil
    --player1 = nil
    --player2 = nil
end
  

function fight_scene:update(dt, GameState)
    -- Load players for the first time
    if player1 == nil then
        player1 = player:new(1, GameState.player1, Level.x1, Level.y1)
        player1:load()
    end
    if Level.player2 == nil then
        Level.player2 = player:new(2, GameState.Level.player2, Level.x2, Level.y2)
        Level.player2:load()
    end
    -- print("Player 1 has mass of "..player1.physics.body:getMass())
    -- print("Player 2 has mass of "..player2.physics.body:getMass())
    -- Increment Timers
    self:incrementTimers(dt)
    -- Supress controller inputs
    if not self.fight or player1.knocked_out or Level.player2.knocked_out then
        ResetInputs()
        if player1.knocked_out or Level.player2.knocked_out then
            self:resetFighters(dt)
        end
    end
    World:update(dt)
    --player1:update(dt)
    --player2:update(dt)
    self:updateFight(dt)
    Level:update(dt)
    -- Apply shader if Curlew level
    --[[ if Level.name == "curlew" then
        self.eff:send("image2", self.canvas2)
        self.eff:send("normal_map", Level.normal_map)
        self.delta = self.delta - dt*0.03
        if self.delta < -1.0 then
            self.delta = 0.0
        end
        self.eff:send("d", self.delta)
        --self.eff:send("time", love.timer:getTime())
        self.eff:send("dock2_y", Level.Dock[2].body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("dock3_y", Level.Dock[3].body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("dock4_y", Level.Dock[4].body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("dock5_y", Level.Dock[5].body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("float1_y", Level.Floaty1.body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("float1_x", Level.Floaty1.body:getX()/(WindowWidth/GlobalScale))
        self.eff:send("float2_y", Level.Floaty2.body:getY()/(WindowHeight/GlobalScale))
        self.eff:send("float2_x", Level.Floaty2.body:getX()/(WindowWidth/GlobalScale))
        --self.eff:send("Debug", Debug);
    end ]]
    CheckKeys()
end

function fight_scene:draw(sx, sy)
    Level:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawFight()
    love.graphics.pop()
    --[[ -- Activate canvas
    love.graphics.setCanvas(self.canvas1)
    -- Draw background to have shader applied to it
    love.graphics.clear()
    love.graphics.push()
    love.graphics.scale(sx, sy)
    Level:drawShadedBackground()
    if player1 ~= nil then
        player1:draw()
    end
    if player2 ~= nil then
        player2:draw()
    end
    Level:drawForeground()
    self:drawFight()
    love.graphics.pop()
    -- Draw canvas
    love.graphics.setCanvas()
    -- Apply shader if Curlew level
    if Level.name == "curlew" then
        love.graphics.setShader(self.eff)
    end
    love.graphics.setCanvas(self.canvas2)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    Level:drawWater()
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas1, 0, 0)
    love.graphics.setShader()
    --love.graphics.setCanvas(self.canvas)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    Level:drawBackground()
    if player1 ~= nil then
        player1:draw()
    end
    if player2 ~= nil then
        player2:draw()
    end
    self:drawFight()
    love.graphics.pop()
    --love.graphics.draw(self.canvas, 0, 0) ]]
end

function fight_scene:incrementTimers(dt)
    self.fight_timer = self.fight_timer + dt
end

function fight_scene:updateFight(dt)
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
    Level.player1.physics.fixture:setMask(2)
    if Level.player1.x > Level.player1.x0 then
        if Level.player1.joystick then
            ButtonsPressed[Level.player1.id][Level.player1.left] = true
        end
    else
        if Level.player1.joystick then
            ButtonsPressed[Level.player1.id][Level.player1.right] = true
        end
    end
    if math.abs(Level.player1.x - Level.player1.x0) < 0.05*Level.player1.x0 then
        ButtonsPressed[Level.player1.id][Level.player1.left] = nil
        ButtonsPressed[Level.player1.id][Level.player1.right] = nil
        Level.player1.physics.body:setPosition(Level.player1.x0, Level.player1.y0)
        Level.player1.xDir = 1.0
    end
    -- Reset player2
    Level.player2.physics.fixture:setMask(2)
    if Level.player2.x > Level.player2.x0 then
        if Level.player2.joystick then
            ButtonsPressed[Level.player2.id][Level.player2.left] = true
        end
    else
        if Level.player2.joystick then
            ButtonsPressed[Level.player2.id][Level.player2.right] = true
        end
    end
    if math.abs(Level.player2.x - Level.player2.x0) < 0.05*Level.player2.x0 then
        ButtonsPressed[Level.player2.id][Level.player2.left] = nil
        ButtonsPressed[Level.player2.id][Level.player2.right] = nil
        Level.player2.physics.body:setPosition(Level.player2.x0, Level.player2.y0)
        Level.player2.xDir = -1.0
    end
    -- Switch boolean
    if (Level.player1.x - Level.player1.x0 < 0.05*Level.player1.x0) and (Level.player2.x - Level.player2.x0 < 0.05*Level.player2.x0) then
        Level.player1.knocked_out = false
        Level.player2.knocked_out = false
        Level.player1.physics.fixture:setMask()
        Level.player2.physics.fixture:setMask()
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
    -- print("Begin contact between "..a:getUserData().." and "..b:getUserData())
    -- Process Damage
    if (a:getUserData() == "sensor1" and b:getUserData() == "player2") or (b:getUserData() == "sensor1" and a:getUserData() == "player2") then
        if not Level.player2.invuln then
            if not Level.player2.blocking then
                Level.player2:damage(10)
            else
                Level.player2:damage(10*0.2)
            end
        end
    end
    if (a:getUserData() == "sensor2" and b:getUserData() == "Level.player1") or (b:getUserData() == "sensor2" and a:getUserData() == "player1") then
        if not Level.player1.invuln then
            if not Level.player1.blocking then
                Level.player1:damage(10)
            else
                Level.player1:damage(10*0.2)
            end
        end
    end
	Level.player1:beginContact(a, b, collision)
    Level.player2:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    -- print("End contact between "..a:getUserData().." and "..b:getUserData())
	Level.player1:endContact(a, b, collision)
    Level.player2:endContact(a, b, collision)
end

function CheckKeys(dt)
    local function pconcat(tab)
        local keyset={}
        local n=0
        for k,v in pairs(tab) do
            n=n+1
            keyset[n]=k
        end
        return table.concat(keyset, " ")
    end
    Level.player1:jump()
    Level.player2:jump()
    Level.player1:attack_1()
    Level.player2:attack_1()
    Level.player1:blocks()
    Level.player2:blocks()
    --print(pconcat(AxisMoved[1]))
end

return fight_scene
