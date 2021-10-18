local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"
-- local player2 = require"characters/player2"

local fight_scene = scene:new("fight")

-- Gravity = 9.81
Gravity = 300
Meter = 64
Friction = 0.0
love.physics.setMeter(Meter)

function fight_scene:load()
    World = love.physics.newWorld(0, Meter*Gravity, false)
    World:setCallbacks(BeginContact, EndContact)
     -- Create Ground and Walls
    Ground = {}
    Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
    Ground.fixture = love.physics.newFixture(Ground.body, Ground.shape)
    Ground.fixture:setFriction(Friction)
    Walls = {}
    Walls.left = {}
    Walls.left.body = love.physics.newBody(World, -10, WindowHeight/GlobalScale/2, "static")
    Walls.left.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    Walls.left.fixture = love.physics.newFixture(Walls.left.body, Walls.left.shape)
    Walls.right = {}
    Walls.right.body = love.physics.newBody(World, WindowWidth/GlobalScale+10, WindowHeight/GlobalScale/2, "static")
    Walls.right.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    Walls.right.fixture = love.physics.newFixture(Walls.right.body, Walls.right.shape)
    player1 = player:new(1, "lilah")
    player1:load()
    player2 = player:new(2, "drew")
    player2:load()
end
  

function fight_scene:update(dt, gamestate)
    World:update(dt)
    player1:update(dt)
    player2:update(dt)

    -- Process Player 1 attacks
    if player1.attack then
        -- if not player2.invuln then
        --     player2:detectHit(player1.hitbox.x, player1.hitbox.y, player1.hitbox.width, player1.hitbox.height)
        -- end
    end

    -- Process Player 2 attacks
    if player2.attack then
        -- if not player1.invuln then
        --     player1:detectHit(player2.hitbox.x, player2.hitbox.y, player2.hitbox.width, player2.hitbox.height)
        -- end
    end
end

function fight_scene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawBackground()
    player1:draw()
    player2:draw()
    love.graphics.pop()

    if Debug then
        love.graphics.print("xVel: "..player1.xVel, 20, 100)
        love.graphics.print("yVel: "..player1.yVel, 20, 120)
    end

end

function fight_scene:drawBackground()
    love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40)
    if Debug then
        love.graphics.setColor(0, 0, 0, 1)
        gx, gy = Ground.body:getPosition()
        love.graphics.rectangle("fill", gx-WindowWidth/GlobalScale/2, gy-10, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", gx, gy, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)

end

function BeginContact(a, b, collision)
	player1:BeginContact(a, b, collision)
    player2:BeginContact(a, b, collision)
end

function EndContact(a, b, collision)
	player1:EndContact(a, b, collision)
    player2:EndContact(a, b, collision)
end

function love.joystickpressed(joystick, button)
    -- print(button)
    if joystick:getID() == 1 then
        player1:jump(button)
        if button == 3 then
            player1.attack = true
        end
    else
        player2:jump(button)
        if button == 3 then
            player2.attack = true
        end
    end
end

function love.keypressed(key)
    player1:jump(key)
    player2:jump(key)
    if not player1.joystick then
        if key == "e" then
            player1.attack = true
        end
    end
    if not player2.joystick then
        if key == "kp4" then
            player2.attack = true
        end
    end
end

--[[ function love.keyreleased(key)
    if key == "e" then
        player1.attack = true
    end
    if key == "kp4" then
        player2.attack = true
    end
end ]]

return fight_scene
