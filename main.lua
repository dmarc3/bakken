-- Full Medical Alchemist

-- In the medicinal alchemy world, humoralism based treatments are considered especially unstable.
-- In Ballurdia, the dedicated physickers who investigate these dangerous practices are members 
-- of an elite group known as the Full Medical Alchemists. These are their stories.

-- Load Modules / Libraries
local push = require("3rd/push/push")

love.graphics.setDefaultFilter("nearest", "nearest")

SysWidth, SysHeight = love.window.getDesktopDimensions()
GlobalScale = SysHeight/160
local gameWidth, gameHeight = 240*GlobalScale, 160*GlobalScale --fixed game resolution

push:setupScreen(gameWidth, gameHeight, SysWidth, SysHeight, {fullscreen = true})
push:setBorderColor(0.05, 0.05, 0.05)
WindowWidth, WindowHeight = push:getWidth(), push:getHeight()

-- Declare Global Parameters Here
-- WindowWidth = love.graphics.getWidth()
-- WindowHeight = love.graphics.getHeight()


-- Define Local Parameters Here
local titleScene = require"scenes/title_scene"
local pickFighterScene = require"scenes/pick_fighter_scene"
local pickLevelScene = require"scenes/pick_level_scene"
local fightScene = require"scenes/fight_scene"

-- Load gamepad mappings
love.joystick.loadGamepadMappings("3rd/SDL_GameControllerDB/gamecontrollerdb.txt")

-- Set windows icon
local icon = love.image.newImageData("assets/icon.png")
love.window.setIcon(icon)

-- levels or scenes in our game.
local GameState = {
    world = nil,
    current = titleScene,
    canvas = love.graphics.newCanvas(WindowWidth, WindowHeight),
    scenes = {
        titleScene = titleScene,
        pickFighterScene = pickFighterScene,
        pickLevelScene = pickLevelScene,
        fightScene = fightScene,
    },
    player1 = "",
    player2 = "",
    level = "",
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
Debug = false
Debug_Pause = false
Debug_Pause_Duration = 0
Pause_dt = 0
Debug_Speed = 1.0

-- hooks for updating state. free to call from within
-- a scene.

function GameState:setTitleScene()
    self.current = self.scenes.titleScene
end

function GameState:setPickFighterScene()
    self.current = self.scenes.pickFighterScene
end
    
function GameState:setPickLevelScene()
    self.current = self.scenes.pickLevelScene
end

function GameState:setFightScene()
    self.current = self.scenes.fightScene
end

-- A primary callback of LÖVE that is called only once
function love.load()
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    -- Gamestate and scene handling
    GameState.current:load(GameState)
end

-- A primary callback of LÖVE that is called continuously
function love.update(dt)
    if Debug_Pause then
        Pause_dt = dt
        Debug_Pause_Duration = Debug_Pause_Duration + dt
        dt = 0
    else
        Debug_Pause_Duration = 0
    end
    if Debug then
        if Debug_Speed ~= 1 then
            dt = dt*Debug_Speed
        end
    end
    CheckKeys(dt)
    GameState.current:update(dt, GameState)
end

-- A primary callback of LÖVE that is called continuously
function love.draw()
    push:start()
    love.graphics.setCanvas(GameState.canvas)
    love.graphics.clear()
    GameState.current:draw(GameState.sx, GameState.sy)
    -- Only for debugging
    -- With (36, 24) grids are 20 pixels by 20 pixels
    -- 1440/36 = 20 pixels and 960/24 = 20 pixels
    if Debug then
        drawPhysicsBodies()
        debugGrid(36, 24)
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    end
    love.graphics.setCanvas()
    love.graphics.draw(GameState.canvas, (SysWidth-WindowWidth)/2, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, (SysWidth-WindowWidth)/2, SysHeight)
    love.graphics.rectangle("fill", SysWidth - (SysWidth-WindowWidth)/2, 0, (SysWidth-WindowWidth)/2, SysHeight)
    love.graphics.setColor(1, 1, 1, 1)
    push:finish()
end

function love.keypressed(key)
    if key == "escape" and Debug then
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

function drawPhysicsBodies()
    if GameState.world ~= nil then
        love.graphics.push()
        love.graphics.scale(GameState.sx, GameState.sy)
        love.graphics.setColor(0, 0, 0, 0.7)
        for _, body in pairs(GameState.world:getBodies()) do
            for _, fixture in pairs(body:getFixtures()) do
                local shape = fixture:getShape()
        
                if shape:typeOf("CircleShape") then
                    local cx, cy = body:getWorldPoints(shape:getPoint())
                    love.graphics.circle("fill", cx, cy, shape:getRadius())
                elseif shape:typeOf("PolygonShape") then
                    love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
                else
                    love.graphics.line(body:getWorldPoints(shape:getPoints()))
                end
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()
    end
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
    -- print(pconcat(ButtonsPressed[1]))
end