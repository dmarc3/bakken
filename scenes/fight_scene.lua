local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"
local utils = require"utils"

local fight_scene = scene:new("fight")

-- -- Gravity = 9.81
-- Gravity = 10
-- Meter = 64
-- Friction = 5
-- love.physics.setMeter(Meter)

function fight_scene:load(gameState)
    -- World = love.physics.newWorld(0, Meter*Gravity, false)
    -- World:setCallbacks(beginContact, endContact)

    -- Load canvas
    self.game_canvas = gameState.canvas
    self.canvas = love.graphics.newCanvas(WindowWidth, WindowHeight)

    -- Import level
    Level = require("levels/"..gameState.level)
    Level:load(gameState.player1, gameState.player2, self.canvas, true, true)

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
    self.pause = false
    self.pause_timer = 0.0

    -- Import player names
    local spritesheet = love.graphics.newImage("assets/ui/names.png")
    local asepriteMeta = "assets/ui/names.json"
    Names = {}
    Names.player1 = peachy.new(asepriteMeta, spritesheet, gameState.player1)
    Names.player2 = peachy.new(asepriteMeta, spritesheet, gameState.player2)
    Names.wins = peachy.new(asepriteMeta, spritesheet, "wins")
    -- Transition loads
    Transition_Out = require"scenes/transition_out"
    Transition_Out:load()
    Transition_In = nil
    -- Import pause box
    local spritesheet = love.graphics.newImage("assets/ui/pause_box.png")
    local asepriteMeta = "assets/ui/pause_box.json"
    self.pause_box = peachy.new(asepriteMeta, spritesheet, "idle")
    local spritesheet = love.graphics.newImage("assets/ui/pause_menu.png")
    local asepriteMeta = "assets/ui/pause_menu.json"
    self.pause_menu = {}
    self.pause_menu.resume = {}
    self.pause_menu.resume.not_selected = peachy.new(asepriteMeta, spritesheet, "resume_not_selected")
    self.pause_menu.resume.selected = peachy.new(asepriteMeta, spritesheet, "resume_selected")
    self.pause_menu.change = {}
    self.pause_menu.change.not_selected = peachy.new(asepriteMeta, spritesheet, "change_not_selected")
    self.pause_menu.change.selected = peachy.new(asepriteMeta, spritesheet, "change_selected")
    self.pause_menu.exit = {}
    self.pause_menu.exit.not_selected = peachy.new(asepriteMeta, spritesheet, "exit_not_selected")
    self.pause_menu.exit.selected = peachy.new(asepriteMeta, spritesheet, "exit_selected")
    self.pause_selection = 1
    self.pause_move_timer = 0.0
    -- Load sound effects
    self.sfx = {
        change_sel = love.audio.newSource(
            "assets/audio/sfx/ui/change_selection.ogg", "static"
        )
        ,
        invalid_sel = love.audio.newSource(
            "assets/audio/sfx/ui/invalid_selection.ogg", "static"
        ),
        accept_all = love.audio.newSource(
            "assets/audio/sfx/ui/accept_all.ogg", "static"
        )
    }
    -- Load music theme
    if gameState.level == "bakke_backyard" then
        gameState:setMusic("assets/audio/music/bakke_theme.ogg")
    elseif gameState.level == "everhart_backyard" then
        gameState:setMusic("assets/audio/music/everhart_theme.ogg")
    elseif gameState.level == "curlew" then
        gameState:setMusic("assets/audio/music/curlew_theme.ogg")
    end
    self.end_timer = 0
end
  

function fight_scene:update(dt, gameState)
    utils.pplay(gameState.music)
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
    self:updatePause(dt)
    if not self.pause then
        CheckKeys()
    end
    if Transition_In ~= nil then
        if Transition_In.transition_in == true then
            Transition_In:update(math.max(dt, Pause_dt), gameState, nil)
        end
    end
    if Level.complete and self.end_timer > 7.0 and Transition_In == nil then
        print("Transitioning!")
        Transition_In = require"scenes/transition_in"
        Transition_In:load("setTitleScene")
        Transition_In.transition_in = true
    end
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
    Level:draw((SysWidth-WindowWidth)/2, 0, sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawFight()
    if Level.complete then
        self:drawVictory()
    end
    if Transition_Out.transition_out then
        Transition_Out:draw()
    end
    if self.pause then
        self:drawPause()
    end
    if Transition_In ~= nil then
        if Transition_In.transition_in then
            Transition_In:draw()
        end
    end
    love.graphics.pop()
end

function fight_scene:incrementTimers(dt)
    self.fight_timer = self.fight_timer + dt
    if Transition_Out.transition_out then
        Transition_Out.transition_timer = Transition_Out.transition_timer + dt
    end
    self.pause_timer = self.pause_timer + dt
    self.pause_move_timer = self.pause_move_timer + Pause_dt
    if Transition_In ~= nil then
        if Transition_In.transition_in then
            Transition_In.transition_timer = Transition_In.transition_timer + math.max(dt, Pause_dt)
        end
    end
    if Level.complete then
        self.end_timer = self.end_timer + dt
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

function fight_scene:drawPause()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, WindowWidth/GlobalScale, WindowHeight/GlobalScale)
    love.graphics.setColor(1, 1, 1, 1)
    self.pause_box:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2)
    local dx = 4
    local dy = 4
    local sf = 0.5
    if self.pause_selection == 1 then
        self.pause_menu.resume.selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+dy, 0, sf, sf)
    else
        self.pause_menu.resume.not_selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+dy, 0, sf, sf)
    end
    if self.pause_selection == 2 then
        self.pause_menu.change.selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+3*dy, 0, sf, sf)
    else
        self.pause_menu.change.not_selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+3*dy, 0, sf, sf)    
    end
    if self.pause_selection == 3 then
        self.pause_menu.exit.selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+5*dy, 0, sf, sf)
    else
        self.pause_menu.exit.not_selected:draw(WindowWidth/GlobalScale*0.5-self.pause_box:getWidth()/2+dx, WindowHeight/GlobalScale*0.5-self.pause_box:getHeight()/2+5*dy, 0, sf, sf)
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

function fight_scene:updatePause(dt)
    if (KeysPressed["escape"] == true or ButtonsPressed[1]["start"] == true or ButtonsPressed[2]["start"] == true) and (self.pause_timer > 0.3 or Debug_Pause_Duration > 0.3) then
        self.pause_selection = 1
        self.pause_timer = 0
        self.pause = not self.pause
        Debug_Pause = self.pause
        utils.snplay(self.sfx.change_sel)
    end
    if self.pause then
        if (KeysPressed["return"] or ButtonsPressed[1]["a"] or ButtonsPressed[2]["a"]) and self.pause_selection == 1 and (self.pause_timer > 0.3 or Debug_Pause_Duration > 0.3) and self.pause then
            self.pause_timer = 0
            self.pause = not self.pause
            Debug_Pause = self.pause
            utils.snplay(self.sfx.change_sel)
        end
        if(KeysPressed["return"] or ButtonsPressed[1]["a"] or ButtonsPressed[2]["a"]) and self.pause_selection == 2 and (self.pause_timer > 0.3 or Debug_Pause_Duration > 0.3) and self.pause and Transition_In == nil then
            Transition_In = require"scenes/transition_in"
            Transition_In:load("setPickFighterScene")
            Transition_In.transition_in = true
            Debug_Pause = false
            utils.snplay(self.sfx.change_sel)
        end
        if (KeysPressed["return"] or ButtonsPressed[1]["a"] or ButtonsPressed[2]["a"]) and self.pause_selection == 3 and self.pause then
            utils.snplay(self.sfx.change_sel)
            love.event.quit()
        end
    end
    self.pause_menu.resume.selected:update(Pause_dt)
    self.pause_menu.change.selected:update(Pause_dt)
    self.pause_menu.exit.selected:update(Pause_dt)
    if self.pause then
        -- process Keyboard input
        if (KeysPressed["w"] or KeysPressed["kp5"]) and self.pause_move_timer > 0.3 then
            self:pauseDecrement()
            self.pause_move_timer = 0
        end
        if (KeysPressed["s"] or KeysPressed["kp2"]) and self.pause_move_timer > 0.3 then
            self:pauseIncrement()
            self.pause_move_timer = 0
        end
        -- process gamepad axis input
        if AxisMoved[1]["lefty"] ~= nil then
            if AxisMoved[1]["lefty"] < 0 and self.pause_move_timer > 0.3 then
                self:pauseDecrement()
                self.pause_move_timer = 0
            end
            if AxisMoved[1]["lefty"] > 0 and self.pause_move_timer > 0.3 then
                self:pauseIncrement()
                self.pause_move_timer = 0
            end
        end
        if AxisMoved[2]["lefty"] ~= nil then
            if AxisMoved[2]["lefty"] < 0 and self.pause_move_timer > 0.3 then
                self:pauseDecrement()
                self.pause_move_timer = 0
            end
            if AxisMoved[2]["lefty"] > 0 and self.pause_move_timer > 0.3 then
                self:pauseIncrement()
                self.pause_move_timer = 0
            end
        end
        -- process gamepad button input
        if (ButtonsPressed[1]["dpup"] or ButtonsPressed[2]["dpup"]) and self.pause_move_timer > 0.3 then
            self:pauseDecrement()
            self.pause_move_timer = 0
        end
        if (ButtonsPressed[1]["dpdown"] or ButtonsPressed[2]["dpown"]) and self.pause_move_timer > 0.3 then
            self:pauseIncrement()
            self.pause_move_timer = 0
        end
    end
end

function fight_scene:pauseIncrement()
    -- increment selection
    if self.pause_selection == 3 then
        utils.snplay(self.sfx.invalid_sel)
    else
        utils.snplay(self.sfx.change_sel)
        self.pause_selection = self.pause_selection + 1
    end
end

function fight_scene:pauseDecrement()
    -- increment selection
    if self.pause_selection == 1 then
        utils.snplay(self.sfx.invalid_sel)
    else
        utils.snplay(self.sfx.change_sel)
        self.pause_selection = self.pause_selection - 1
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
