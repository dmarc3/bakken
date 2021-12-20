local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

local fight_scene = scene:new("fight")

-- -- Gravity = 9.81
-- Gravity = 10
-- Meter = 64
-- Friction = 5
-- love.physics.setMeter(Meter)

function fight_scene:load(GameState)
    print("Loading fight_scene")
    -- World = love.physics.newWorld(0, Meter*Gravity, false)
    -- World:setCallbacks(beginContact, endContact)

    -- Load canvas
    self.canvas = love.graphics.newCanvas(WindowWidth, WindowHeight)
    self.canvas1 = love.graphics.newCanvas(WindowWidth, WindowHeight)
    self.canvas2 = love.graphics.newCanvas(WindowWidth, WindowHeight)

    -- Import level
    Level = require("levels/"..GameState.level)
    Level:load(GameState.player1, GameState.player2, self.canvas, true, true)

    -- Import fight ui
    local spritesheet = love.graphics.newImage("assets/ui/fight.png")
    local asepriteMeta = "assets/ui/fight.json"
    Fight = {}
    Fight.x = 0
    Fight.y = 3*WindowHeight/GlobalScale/4
    Fight.x0 = Fight.x
    Fight.y0 = Fight.y
    Fight.kabam = peachy.new(asepriteMeta, spritesheet, "kabam")
    self.fight_duration = 1.5
    self.fight_timer = 0
    self.fight_timer2 = 0
    self.fight = false
    self.delta = 0

    -- Import player names
    local spritesheet = love.graphics.newImage("assets/ui/names.png")
    local asepriteMeta = "assets/ui/names.json"
    Names = {}
    Names.player1 = peachy.new(asepriteMeta, spritesheet, GameState.player1)
    Names.player2 = peachy.new(asepriteMeta, spritesheet, GameState.player2)
    Names.wins = peachy.new(asepriteMeta, spritesheet, "wins")
    -- Transition loads
    Transition_Out = require"scenes/transition_out"
    Transition_Out:load()
end
  

function fight_scene:update(dt, GameState)
    -- Check victory
    if Level.player1.victory or Level.player2.victory then
        ResetInputs()
    end
    -- Increment Timers
    self:incrementTimers(dt)
    -- Supress controller inputs
    if not self.fight then
        ResetInputs()
    end
    self:resetFighters(dt)
    World:update(dt)
    self:updateFight(dt)
    Level:update(dt)
    if Transition_Out.transition_out then
        Transition_Out:update(dt)
    end
    CheckKeys()
end

function fight_scene:resetFighters(dt)
    -- Set both players to knocked_out if one is knocked_out
    -- This triggers resetFighters function for both people
    if Level.player1.knocked_out then
        Level.player2.knocked_out = true
    end
    if Level.player2.knocked_out then
        Level.player1.knocked_out = true
    end
    -- Reset player1
    local attack_logic = Level.player2.knocked_out and not Level.player1.attack
    local knock_out_logic = Level.player1.knocked_out
    local kneel_logic = not Level.player1.kneel
    if attack_logic and (knock_out_logic and kneel_logic) then
        --print("Resetting player1...")
        Level:resetFighters(dt, 1)
        ResetInputs()
    end
    -- Reset player2
    local attack_logic = Level.player1.knocked_out and not Level.player2.attack
    local knock_out_logic = Level.player2.knocked_out
    local kneel_logic = not Level.player2.kneel
    --print("Knockout logic: "..tostring(knock_out_logic))
    if attack_logic and (knock_out_logic and kneel_logic) then
        --print("Resetting player2...")
        Level:resetFighters(dt, 2)
        ResetInputs()
    end
end

function fight_scene:draw(sx, sy)
    Level:draw(0, 0, sx, sy, true)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawFight()
    if Level.complete then
        self:drawVictory()
    end
    if Transition_Out.transition_out then
        Transition_Out:draw()
    end
    love.graphics.pop()
end

function fight_scene:incrementTimers(dt)
    self.fight_timer = self.fight_timer + dt
    if Transition_Out.transition_out then
        Transition_Out.transition_timer = Transition_Out.transition_timer + dt
    end
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

function fight_scene:drawVictory()
    if Level.complete then
        if Level.player1.dead then
            Names.player2:draw(WindowWidth/GlobalScale*0.38, WindowHeight/GlobalScale*0.3)
        end
        if Level.player2.dead then
            Names.player1:draw(WindowWidth/GlobalScale*0.38, WindowHeight/GlobalScale*0.3)
        end
        if Level.player1.dead or Level.player2.dead then
            Names.wins:draw(WindowWidth/GlobalScale*0.38, WindowHeight/GlobalScale*0.4)
        end
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
                Level.player2:damage(50)
            else
                Level.player2:damage(50*0.2)
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
    --print(pconcat(KeysPressed))
end

return fight_scene
