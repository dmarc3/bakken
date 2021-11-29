local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local pickLevelScene = scene:new("pickLevelScene")

-- Gravity = 9.81
Gravity = 10
Meter = 64
Friction = 5
love.physics.setMeter(Meter)

function pickLevelScene:load(GameState)
    World = love.physics.newWorld(0, Meter*Gravity, false)
    World:setCallbacks(beginContact, endContact)

    self.levels = {"bakke_backyard", "everhart_backyard", "curlew"}
    self.level = 1
    self.level_x = 0.35*WindowWidth
    self.level_y = 0.35*WindowHeight
    self.canvas = love.graphics.newCanvas(WindowWidth, WindowHeight)
    -- Import level
    Levels = {}
    Levels[1] = require("levels/"..self.levels[1])
    Levels[1]:load(GameState.player1, GameState.player2, self.canvas)
    Levels[2] = require("levels/"..self.levels[2])
    Levels[2]:load(GameState.player1, GameState.player2, self.canvas)
    Levels[3] = require("levels/"..self.levels[3])
    Levels[3]:load(GameState.player1, GameState.player2, self.canvas)

    self.y = {10, 30, 50}
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
    -- Reset Inputs on load
    ResetInputs()
end

function pickLevelScene:update(dt, GameState)
    self:processDelay()
    self:incrementTimers(dt)
    self:updateLevel(dt)
    if KeysPressed["return"] == true then
        self:deleteBodies()
        GameState.level = self.levels[self.level]
        GameState.scenes.fightScene:load(GameState)
        GameState:setFightScene()
    end
    if ButtonsPressed[1]["start"] == true then
        self:deleteBodies()
        GameState.level = self.levels[self.level]
        GameState.scenes.fightScene:load(GameState)
        GameState:setFightScene()
    end
end

function pickLevelScene:draw(sx, sy)
    self:processDelay()
    self:drawLevel(sx, sy)
    self:drawBackground(sx, sy)
end

function pickLevelScene:drawBackground(sx, sy)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, self.level_x-3*0.6*sx, WindowHeight)
    love.graphics.rectangle("fill", WindowWidth - 50 + 3*0.6*sx, 0, 50, WindowHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(3*sx/4, 3*sy/4)
    for i, level in pairs(self.levels) do
        if self.level == i then
            self.animations[level].selected:draw(10, self.y[i])
        else
            self.animations[level].not_selected:draw(10, self.y[i])
        end
    end
    love.graphics.pop()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function pickLevelScene:drawLevel(sx, sy)
    Levels[self.level]:draw(self.level_x, self.level_y, 0.60*sx, 0.60*sy, false)
    self.level_border:draw(self.level_x-3*0.6*sx, self.level_y-3*0.6*sy, 0, 0.60*sx, 0.60*sy)
end

function pickLevelScene:updateLevel(dt)
    if KeysPressed["s"] and not self.move then
        self.level = self.level + 1
        self.move = true
    end
    if KeysPressed["w"] and not self.move then
        self.level = self.level - 1
        self.move = true
    end
    if self.level > 3 then
        self.level = 3
    elseif self.level == 0 then
        self.level = 1
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

function pickLevelScene:selectLevel()
    
end

function pickLevelScene:incrementTimers(dt)
    self.delay_timer = self.delay_timer + dt
    if self.delay_timer > 0.25 then
        self.delay = false
    end
end

function pickLevelScene:processDelay()
    if self.delay then
        self.selected = false
        ResetInputs()
    end
end

function pickLevelScene:deleteBodies()
    local bodies = World:getBodies()
    for j, wbody in pairs(bodies) do
        wbody:destroy()
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