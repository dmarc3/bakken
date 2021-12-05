local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

Level = {}
Level.__index = Level

function Level:load(player1, player2, canvas)
    self.name = "bakke_backyard"
    self.canvas = canvas
    -- Create self.Ground and Walls
    self.Ground = {}
    self.Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    self.Ground.body:setUserData("ground")
    self.Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
    self.Ground.fixture = love.physics.newFixture(self.Ground.body, self.Ground.shape)
    self.Ground.fixture:setFriction(Friction)
    self.Ground.fixture:setUserData("ground")
    self.Ground.y = WindowHeight/GlobalScale + 10
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
    self.Backyard = {}
    self.Backyard.base = peachy.new(asepriteMeta, spritesheet, "idle")
    self.Backyard.bush = peachy.new(asepriteMeta, spritesheet, "bush")
    self.Backyard.tree = peachy.new(asepriteMeta, spritesheet, "tree")
    self.Backyard.foreground = peachy.new(asepriteMeta, spritesheet, "foreground")
    self.Backyard.toys = peachy.new(asepriteMeta, spritesheet, "toys")
    self.Backyard.toys_top = peachy.new(asepriteMeta, spritesheet, "toys_top")
    self.Backyard.toys_top_transparent = peachy.new(asepriteMeta, spritesheet, "toys_top_transparent")
    self.Backyard.toys_bottom = peachy.new(asepriteMeta, spritesheet, "toys_bottom")
    self.Backyard.sun = peachy.new(asepriteMeta, spritesheet, "sun")
    self.Backyard.clouds1 = peachy.new(asepriteMeta, spritesheet, "clouds")
    self.Backyard.clouds2 = peachy.new(asepriteMeta, spritesheet, "clouds")
    self.Backyard.bird1 = peachy.new(asepriteMeta, spritesheet, "bird")
    self.Backyard.bird2 = peachy.new(asepriteMeta, spritesheet, "bird")
    -- Define Constants
    self.x1 = WindowWidth/GlobalScale*0.2
    self.y1 = WindowHeight/GlobalScale*0.8
    self.x2 = WindowWidth/GlobalScale*0.8
    self.y2 = WindowHeight/GlobalScale*0.8
    self.cloudx = 0
    self.birdx = 100
    self.sunx = 0
    -- Load players
    self.player1 = player:new(1, player1, Level.x1, Level.y1)
    self.player1:load()
    self.player2 = player:new(2, player2, Level.x2, Level.y2)
    self.player2:load()
end

function Level:update(dt)
    self.Backyard.base:update(dt)
    self.Backyard.bush:update(dt)
    self.Backyard.tree:update(dt)
    self.Backyard.foreground:update(dt)
    self.Backyard.toys:update(dt)
    self.Backyard.toys_top:update(dt)
    self.Backyard.toys_top_transparent:update(dt)
    self.Backyard.toys_bottom:update(dt)
    self.Backyard.bird1:update(dt)
    self.Backyard.bird2:update(dt)
    self.Backyard.clouds1:update(dt)
    self.Backyard.clouds2:update(dt)
    self.Backyard.sun:update(dt)
    self.cloudx = self.cloudx - 0.02
    if self.cloudx < -WindowWidth/GlobalScale then
        self.cloudx = self.cloudx + WindowWidth/GlobalScale
    end
    self.birdx = self.birdx - 0.5
    if self.birdx < -2*WindowWidth/GlobalScale then
        self.birdx = self.birdx + 2*WindowWidth/GlobalScale
    end
    self.sunx = self.sunx - 0.001
    self.player1:update(dt)
    self.player2:update(dt)
end

function Level:draw(x, y, sx, sy, option)
    -- Activate Canvas
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    -- Draw background to have shader applied to it
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawBackground()
    if option then
        self.player1:draw()
        self.player2:draw()
    end
    self:drawForeground()
    love.graphics.pop()
    -- Draw Player Health Bars
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self.player1:drawHealthBar()
    self.player2:drawHealthBar()
    love.graphics.pop()
    -- Draw Canvas
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, x, y)
end

function Level:drawForeground()
    self.Backyard.toys_bottom:draw(0,0)
    self.Backyard.toys_top:draw(0,0)
end

function Level:drawBackground()
    self.Backyard.base:draw(0,0)
    self.Backyard.bush:draw(0,0)
    self.Backyard.tree:draw(0,0)
    self.Backyard.toys:draw(0,0)
    self.Backyard.sun:draw(self.sunx, 0)
    self.Backyard.clouds1:draw(self.cloudx,0)
    self.Backyard.clouds2:draw(self.cloudx+WindowWidth/GlobalScale,0)
    self.Backyard.bird1:draw(self.birdx, 0)
    self.Backyard.bird2:draw(self.birdx+2*WindowWidth/GlobalScale, 0)
    self.Backyard.foreground:draw(0,0)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.polygon("fill", Toys.body:getWorldPoints(Toys.shape:getPoints()))
        love.graphics.polygon("fill", Roof.body:getWorldPoints(Roof.shape:getPoints()))
        gx, gy = self.Ground.body:getPosition()
        love.graphics.rectangle("fill", gx-WindowWidth/GlobalScale/2, gy-10, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", gx, gy, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Level:resetFighters(dt, id)
    local dx = 1.0
    local x1 = Level.player1.x0
    local x2 = Level.player2.x0
    if Level.player2.dead then
        x1 = 0.5*WindowWidth/GlobalScale
        x2 = Level.player2.x
    end
    if Level.player1.dead then
        x1 = Level.player1.x
        x2 = 0.5*WindowWidth/GlobalScale
    end
    if id == 1 then
        -- Reset player1
        Level.player1.physics.fixture:setMask(2)
        if Level.player1.x > x1 then
            Level.player1.physics.body:setLinearVelocity(-Level.player1.maxSpeed, 0)
            Level.player1.xVel = -Level.player1.maxSpeed
            Level.player1.xDir = -1.0
        else
            Level.player1.physics.body:setLinearVelocity(Level.player1.maxSpeed, 0)
            Level.player1.xVel = Level.player1.maxSpeed
            Level.player1.xDir = 1.0
        end
        Level.player1.xoverride = true
        if math.abs(Level.player1.x - x1) < dx then
            Level.player1.physics.body:setPosition(x1, Level.player1.y0)
            Level.player1.physics.body:setLinearVelocity(0, 0)
            Level.player1.xVel = 0
            Level.player1.xDir = 1.0
            Level.player1.xoverride = false
        end
    else
        -- Reset player2
        Level.player2.physics.fixture:setMask(2)
        if Level.player2.x > x2 then
            Level.player2.physics.body:setLinearVelocity(-Level.player2.maxSpeed, 0)
            Level.player2.xVel = -Level.player2.maxSpeed
            Level.player2.xDir = -1.0
        elseif Level.player2.x < x2 then
            Level.player2.physics.body:setLinearVelocity(Level.player2.maxSpeed, 0)
            Level.player2.xVel = Level.player2.maxSpeed
            Level.player2.xDir = 1.0
        end
        Level.player2.xoverride = true
        if math.abs(Level.player2.x - x2) < dx then
            Level.player2.physics.body:setPosition(x2, Level.player2.y0)
            Level.player2.physics.body:setLinearVelocity(0, 0)
            Level.player2.xVel = 0
            Level.player2.xDir = -1.0
            Level.player2.xoverride = false
        end
    end
    -- Switch boolean
    if math.abs(Level.player1.x - x1) < dx and math.abs(Level.player2.x - x2) < dx then
        Level.player1.knocked_out = false
        Level.player1.xVel = 0
        Level.player1.xDir = 1.0
        Level.player1.physics.fixture:setMask()
        Level.player2.knocked_out = false
        Level.player2.xVel = 0
        Level.player2.xDir = -1.0
        Level.player2.physics.fixture:setMask()
        if Level.player2.dead then
            print("Player 1 is victorious!")
            Level.player1.victory = true
        elseif Level.player1.dead then
            print("Player 2 is victorious!")
            Level.player2.victory = true
        end
    end
end

return Level