local peachy = require("3rd/peachy/peachy")

Level = {}
Level.__index = Level

function Level:load()
    -- Create Ground and Walls
    Ground = {}
    Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-30, "static")
    Ground.body:setUserData("ground")
    Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 60)
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
    
    -- Define background
    local spritesheet = love.graphics.newImage("assets/levels/curlew.png")
    local asepriteMeta = "assets/levels/curlew.json"
    Curlew = {}
    Curlew.base = peachy.new(asepriteMeta, spritesheet, "idle")
    -- Define Constants
    self.x1 = WindowWidth/GlobalScale*0.2
    self.y1 = WindowHeight/GlobalScale*0.8
    self.x2 = WindowWidth/GlobalScale*0.8
    self.y2 = WindowHeight/GlobalScale*0.8
end

function Level:update(dt)
    Curlew.base:update(dt)
end

function Level:drawForeground()
end

function Level:drawBackground()
    Curlew.base:draw(0,0)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        gx, gy = Ground.body:getPosition()
        love.graphics.rectangle("fill", gx-WindowWidth/GlobalScale/2, gy-10, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", gx, gy, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Level