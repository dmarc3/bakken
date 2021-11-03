-- Full Medical Alchemist

-- In the medicinal alchemy world, humoralism based treatments are considered especially unstable.
-- In Ballurdia, the dedicated physickers who investigate these dangerous practices are members 
-- of an elite group known as the Full Medical Alchemists. These are their stories.

-- Load Modules / Libraries

-- Declare Global Parameters Here
WindowWidth = love.graphics.getWidth()
WindowHeight = love.graphics.getHeight()
love.graphics.setDefaultFilter("nearest", "nearest")

-- Define Local Parameters Here
local titleScene = require"scenes/title_scene"
local pickFighterScene = require"scenes/pick_fighter_scene"
local fightScene = require"scenes/fight_scene"
-- Load gamepad mappings
love.joystick.loadGamepadMappings("3rd/SDL_GameControllerDB/gamecontrollerdb.txt")

-- levels or scenes in our game.
local GameState = {
    current = titleScene,
    scenes = {
        titleScene = titleScene,
        pickFighterScene = pickFighterScene,
        fightScene = fightScene,
    },
    player1 = "",
    player2 = "",
    sx = GlobalScale,
    sy = GlobalScale
}

-- Capture keyboard / controller inputs
KeysPressed = {}
ButtonsPressed = {}
ButtonsPressed[1] = {}
ButtonsPressed[2] = {}
AxisMoved = {}
AxisMoved[1] = {}
AxisMoved[2] = {}

-- Declare Debug Mode
Debug = true
Debug_Pause = false
Debug_Speed = 1.0

-- hooks for updating state. free to call from within
-- a scene.

function GameState:setTitleScene()
    self.current = self.scenes.titleScene
end

function GameState:setPickFighterScene()
    self.current = self.scenes.pickFighterScene
end

function GameState:setFightScene()
    self.current = self.scenes.fightScene
end

-- A primary callback of LÖVE that is called only once
function love.load()
    GameState.current:load()
    for _, scene in pairs(GameState.scenes) do
        scene:load()
    end
end

-- A primary callback of LÖVE that is called continuously
function love.update(dt)
    if Debug then
        if Debug_Pause then
            dt = 0
        elseif Debug_Speed ~= 1 then
            dt = dt*Debug_Speed
        end
    end
    GameState.current:update(dt, GameState)
end

-- A primary callback of LÖVE that is called continuously
function love.draw()
    -- print(GameState.current.name)
    GameState.current:draw(GameState.sx, GameState.sy)
    -- Only for debugging
    -- With (36, 24) grids are 20 pixels by 20 pixels
    -- 1440/36 = 20 pixels and 960/24 = 20 pixels
    if Debug then
        debugGrid(36, 24)
    end
end

function love.keypressed(key)
    if key == "escape" then
        Debug_Pause = not Debug_Pause
    end
    KeysPressed[key] = true
end

function love.keyreleased(key)
    KeysPressed[key] = nil
end

function love.gamepadpressed(joystick, button)
    ButtonsPressed[joystick:getID()][button] = true
end

function love.gamepadreleased(joystick, button)
    ButtonsPressed[joystick:getID()][button] = nil
end

function love.gamepadaxis(joystick, axis, value)
    AxisMoved[joystick:getID()][axis] = value
    if math.abs(value) < math.abs(0.3) then
        AxisMoved[joystick:getID()][axis] = nil
    end
end

-- Draws a grid over the window for debugging
function debugGrid(i, j)
    ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(1,1,1, 0.2)
    for k = 1, i do
        for l = 1, j do
            love.graphics.rectangle("line", (k-1)*ww/i, (l-1)*wh/j, ww/i, wh/j)
        end
    end
    love.graphics.setColor(1,1,1,1)
end