local peachy = require"3rd/peachy/peachy"
local utils = require"utils"
local scene = require"scene"

local pickLevelScene = scene:new("pickLevelScene")

-- Gravity = 9.81
Gravity = 10
Meter = 64
Friction = 5
love.physics.setMeter(Meter)

function pickLevelScene:load(gameState)
    -- print("Loading pickLevelScene")
    self.game_canvas = gameState.canvas
    World = love.physics.newWorld(0, Meter*Gravity, false)
    World:setCallbacks(beginContact, endContact)
    gameState.world = World

    self.levels = {"bakke_backyard", "everhart_backyard", "curlew"}
    self.level = 1
    self.level_x = 0.2*WindowWidth
    self.level_y = 0.15*WindowHeight
    self.canvas = love.graphics.newCanvas(WindowWidth, WindowHeight)
    -- Import level
    Levels = {}
    Levels[1] = require("levels/"..self.levels[1])
    Levels[1]:load(gameState.player1, gameState.player2, self.canvas, false, false)
    Levels[2] = require("levels/"..self.levels[2])
    Levels[2]:load(gameState.player1, gameState.player2, self.canvas, false, false)
    Levels[3] = require("levels/"..self.levels[3])
    Levels[3]:load(gameState.player1, gameState.player2, self.canvas, false, false)

    self.y = {170, 185, 200}
    self.animations = {}
    for _, level in pairs(self.levels) do
        local spritesheet = love.graphics.newImage("assets/ui/"..level.."_title.png")
        local asepriteMeta = "assets/ui/"..level.."_title.json"
        self.animations[level] = {}
        self.animations[level].not_selected = peachy.new(asepriteMeta, spritesheet, "not_selected")
        self.animations[level].selected = peachy.new(asepriteMeta, spritesheet, "selected")
    end
    local spritesheet = love.graphics.newImage("assets/ui/level_border.png")
    local asepriteMeta = "assets/ui/level_border.json"
    self.level_border = peachy.new(asepriteMeta, spritesheet, "idle")
    self.selected = false
    self.selection_timer = 0
    self.move = false
    self.move_timer = 0
    self.delay = true
    self.delay_timer = 0
    -- Process controller
    local joystickcount = love.joystick.getJoystickCount( )
    if joystickcount == 2 then
        local joysticks = love.joystick.getJoysticks()
        self.joystick1 = joysticks[1]
        self.joystick2 = joysticks[2]
    else
        self.joystick1 = nil
        self.joystick2 = nil
    end
    -- Load sound effects
    self.sfx = {
        change_sel = love.audio.newSource(
            "assets/audio/sfx/ui/change_selection.ogg", "static"
        ),
        invalid_sel = love.audio.newSource(
            "assets/audio/sfx/ui/invalid_selection.ogg", "static"
        ),
        accept_all = love.audio.newSource(
            "assets/audio/sfx/ui/accept_all.ogg", "static"
        )
    }
    -- Transition loads
    Transition_Out = require"scenes/transition_out"
    Transition_Out:load()
    Transition_In = require"scenes/transition_in"
    Transition_In:load("setFightScene")

    -- Import banner
    local spritesheet = love.graphics.newImage("assets/ui/banner.png")
    local asepriteMeta = "assets/ui/banner.json"
    self.banner = peachy.new(asepriteMeta, spritesheet, "pick_level")

    -- Reset Inputs on load
    ResetInputs()
end

function pickLevelScene:update(dt, gameState)
    self:processDelay()
    self:updateLevel(dt)
    if KeysPressed["return"] == true then
        self.sfx.accept_all:play()
        gameState.level = self.levels[self.level]
        Transition_In.transition_in = true
    end
    if ButtonsPressed[1]["start"] == true or ButtonsPressed[1]["a"] == true then
        self.sfx.accept_all:play()
        gameState.level = self.levels[self.level]
        Transition_In.transition_in = true
    end
    self:incrementTimers(dt)
    if Transition_Out.transition_out then
        Transition_Out:update(dt)
    end
    if Transition_In.transition_in then
        Transition_In:update(dt, gameState)
    end
end

function pickLevelScene:draw(sx, sy)
    self:processDelay()
    self:drawLevel(sx, sy)
    self:drawBackground(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self.banner:draw(WindowWidth/GlobalScale*0.55 - self.banner:getWidth()/2, 5)
    if Transition_Out.transition_out then
        Transition_Out:draw()
    end
    if Transition_In.transition_in then
        Transition_In:draw()
    end
    love.graphics.pop()
end

function pickLevelScene:drawBackground(sx, sy)
    love.graphics.setColor(0.05, 0.05, 0.05)
    love.graphics.rectangle("fill", 0, 0, WindowWidth/2 - 0.6*sx*self.level_border:getWidth()/2, WindowHeight)
    love.graphics.rectangle("fill", WindowWidth/2 + 0.6*sx*self.level_border:getWidth()/2, 0, WindowWidth/2 + 0.6*sx*self.level_border:getWidth()/2, WindowHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(3*sx/4, 3*sy/4)
    for i, level in pairs(self.levels) do
        if self.level == i then
            self.animations[level].selected:draw(0.5*WindowWidth/GlobalScale, self.y[i], 0, 0.8, 0.8)
        else
            self.animations[level].not_selected:draw(0.5*WindowWidth/GlobalScale, self.y[i], 0, 0.8, 0.8)
        end
    end
    love.graphics.pop()
end

function pickLevelScene:drawLevel(sx, sy)
    local sf = 0.6
    Levels[self.level]:draw(self.level_x + (SysWidth-WindowWidth)/2, self.level_y, sf*sx, sf*sy)
    self.level_border:draw(self.level_x-3*sf*sx, self.level_y-3*sf*sy, 0, sf*sx, sf*sy)
end

function pickLevelScene:updateLevel(dt)
    if (KeysPressed["s"] or (AxisMoved[1]["lefty"] ~= nil and AxisMoved[1]["lefty"] > 0) or ButtonsPressed[1]['dpdown']) and not self.move then
        self:levelDecrement()
    end
    if (KeysPressed["w"] or (AxisMoved[1]["lefty"] ~= nil and AxisMoved[1]["lefty"] < 0) or ButtonsPressed[1]['dpup']) and not self.move then
        self:levelIncrement()
    end
    for i, level in pairs(self.levels) do
        self.animations[level].not_selected:update(dt)
        self.animations[level].selected:update(dt)
    end
    Levels[self.level]:update(dt)
    if self.move then
        self.move_timer = self.move_timer + dt
        if self.move_timer > 0.3 then
            self.move_timer = 0
            self.move = false
        end
    end
end

function pickLevelScene:levelIncrement()
    self.level = self.level - 1
    if self.level == 0 then
        self.sfx.invalid_sel:play()
        self.level = 1
    else
        utils.snplay(self.sfx.change_sel)
        self.move = true
    end
end

function pickLevelScene:levelDecrement()
    self.level = self.level + 1
    if self.level > 3 then
        self.sfx.invalid_sel:play()
        self.level = 3
    else
        utils.snplay(self.sfx.change_sel)
        self.move = true
    end
end

function pickLevelScene:selectLevel()
    
end

function pickLevelScene:incrementTimers(dt)
    self.delay_timer = self.delay_timer + dt
    if self.delay_timer > 0.25 then
        self.delay = false
    end
    if Transition_Out.transition_out then
        Transition_Out.transition_timer = Transition_Out.transition_timer + dt
    end
    if Transition_In.transition_in then
        Transition_In.transition_timer = Transition_In.transition_timer + dt
    end
end

function pickLevelScene:processDelay()
    if self.delay then
        self.selected = false
        ResetInputs()
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

return pickLevelScene