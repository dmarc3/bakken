local peachy = require("3rd/peachy/peachy")

Level = {}
Level.__index = Level

function Level:load()
    -- Create Ground and Walls
    Ground = {}
    Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    Ground.body:setUserData("ground")
    Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
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
    Toys = {}
    Toys.body = love.physics.newBody(World, WindowWidth/GlobalScale*0.765, WindowHeight/GlobalScale*0.68, "static")
    Toys.body:setUserData("obstacle")
    Toys.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.15, WindowHeight/GlobalScale*0.015)
    Toys.fixture = love.physics.newFixture(Toys.body, Toys.shape)
    Toys.fixture:setFriction(Friction)
    Toys.fixture:setUserData("obstacle")
    Roof = {}
    Roof.body = love.physics.newBody(World, WindowWidth/GlobalScale*0.797, WindowHeight/GlobalScale*0.455, "static")
    Roof.body:setUserData("obstacle")
    Roof.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.0975, WindowHeight/GlobalScale*0.11)
    Roof.fixture = love.physics.newFixture(Roof.body, Roof.shape)
    Roof.fixture:setFriction(Friction)
    Roof.fixture:setUserData("obstacle")
    
    -- Define background
    local spritesheet = love.graphics.newImage("assets/levels/backyard.png")
    local asepriteMeta = "assets/levels/backyard.json"
    Backyard = {}
    Backyard.base = peachy.new(asepriteMeta, spritesheet, "idle")
    Backyard.bush = peachy.new(asepriteMeta, spritesheet, "bush")
    Backyard.tree = peachy.new(asepriteMeta, spritesheet, "tree")
    Backyard.foreground = peachy.new(asepriteMeta, spritesheet, "foreground")
    Backyard.toys = peachy.new(asepriteMeta, spritesheet, "toys")
    Backyard.toys_top = peachy.new(asepriteMeta, spritesheet, "toys_top")
    Backyard.toys_top_transparent = peachy.new(asepriteMeta, spritesheet, "toys_top_transparent")
    Backyard.toys_bottom = peachy.new(asepriteMeta, spritesheet, "toys_bottom")
    Backyard.sun = peachy.new(asepriteMeta, spritesheet, "sun")
    Backyard.clouds1 = peachy.new(asepriteMeta, spritesheet, "clouds")
    Backyard.clouds2 = peachy.new(asepriteMeta, spritesheet, "clouds")
    Backyard.bird1 = peachy.new(asepriteMeta, spritesheet, "bird")
    Backyard.bird2 = peachy.new(asepriteMeta, spritesheet, "bird")
    -- Define Constants
    self.cloudx = 0
    self.birdx = 100
    self.sunx = 0
end

function Level:update(dt)
    Backyard.base:update(dt)
    Backyard.bush:update(dt)
    Backyard.tree:update(dt)
    Backyard.foreground:update(dt)
    Backyard.toys:update(dt)
    Backyard.toys_top:update(dt)
    Backyard.toys_top_transparent:update(dt)
    Backyard.toys_bottom:update(dt)
    Backyard.bird1:update(dt)
    Backyard.bird2:update(dt)
    Backyard.clouds1:update(dt)
    Backyard.clouds2:update(dt)
    Backyard.sun:update(dt)
    self.cloudx = self.cloudx - 0.02
    if self.cloudx < -WindowWidth/GlobalScale then
        self.cloudx = self.cloudx + WindowWidth/GlobalScale
    end
    self.birdx = self.birdx - 0.5
    if self.birdx < -2*WindowWidth/GlobalScale then
        self.birdx = self.birdx + 2*WindowWidth/GlobalScale
    end
    self.sunx = self.sunx - 0.001
end

function Level:drawForeground()
    Backyard.toys_bottom:draw(0,0)
    Backyard.toys_top:draw(0,0)
end

function Level:drawBackground()
    Backyard.base:draw(0,0)
    Backyard.bush:draw(0,0)
    Backyard.tree:draw(0,0)
    Backyard.toys:draw(0,0)
    Backyard.sun:draw(self.sunx, 0)
    Backyard.clouds1:draw(self.cloudx,0)
    Backyard.clouds2:draw(self.cloudx+WindowWidth/GlobalScale,0)
    Backyard.bird1:draw(self.birdx, 0)
    Backyard.bird2:draw(self.birdx+2*WindowWidth/GlobalScale, 0)
    Backyard.foreground:draw(0,0)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.polygon("fill", Toys.body:getWorldPoints(Toys.shape:getPoints()))
        love.graphics.polygon("fill", Roof.body:getWorldPoints(Roof.shape:getPoints()))
        gx, gy = Ground.body:getPosition()
        love.graphics.rectangle("fill", gx-WindowWidth/GlobalScale/2, gy-10, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", gx, gy, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Level