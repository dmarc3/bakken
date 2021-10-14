local scene = require "scene"

local peachy = require("3rd/peachy/peachy")
local player1 = require"characters/player1"
local player2 = require"characters/player2"

local fight_scene = scene:new("fight")

Gravity = 500

function fight_scene:load()
    World = love.physics.newWorld(0, 0)
    World:setCallbacks(BeginContact, EndContact)
    Ground = {}
    Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
    Ground.fixture = love.physics.newFixture(Ground.body, Ground.shape)
    player1:load()
    player2:load()
    -- background = {}
    -- background.spritesheet = love.graphics.newImage("assets/levels/curlew.png")
    -- background.asepriteMeta = "assets/levels/curlew.json"
    -- background.animation = peachy.new(background.asepriteMeta, background.spritesheet, "Idle")
end
  

function fight_scene:update(dt, gamestate)
    World:update(dt)
    player1:update(dt)
    player2:update(dt)

    -- Process Player 1 attacks
    if player1.attack then
        if not player2.invuln then
            player2:detectHit(player1.hitbox.x, player1.hitbox.y, player1.hitbox.width, player1.hitbox.height)
        end
    end

    -- Process Player 2 attacks
    if player2.attack then
        if not player1.invuln then
            player1:detectHit(player2.hitbox.x, player2.hitbox.y, player2.hitbox.width, player2.hitbox.height)
        end
    end
end

function fight_scene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawBackground()
    player1:draw()
    player2:draw()
    love.graphics.pop()
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
    print("Begin Contact!")
	player1:beginContact(a, b, collision)
end

function EndContact(a, b, collision)
    print("End Contact!")
	player1:endContact(a, b, collision)
end

function love.keyreleased(key)
    if key == "e" then
        player1.attack = true
    end
    if key == "kp4" then
        player2.attack = true
    end
end

return fight_scene
