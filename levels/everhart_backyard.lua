local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

Level = {}
Level.__index = Level

function Level:load(player1, player2, canvas)
    self.name = "everhart_backyard"
    self.canvas = canvas
    -- Create self.Ground and self.Walls
    self.Ground = {}
    self.Ground.body = love.physics.newBody(World, WindowWidth/GlobalScale/2, WindowHeight/GlobalScale-10, "static")
    self.Ground.body:setUserData("ground")
    self.Ground.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale, 20)
    self.Ground.fixture = love.physics.newFixture(self.Ground.body, self.Ground.shape)
    self.Ground.fixture:setFriction(Friction)
    self.Ground.fixture:setUserData("ground")
    self.Ground.y = WindowHeight/GlobalScale + 10
    self.Walls = {}
    self.Walls.left = {}
    self.Walls.left.body = love.physics.newBody(World, -10, WindowHeight/GlobalScale/2, "static")
    self.Walls.left.body:setUserData("wall")
    self.Walls.left.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    self.Walls.left.fixture = love.physics.newFixture(self.Walls.left.body, self.Walls.left.shape)
    self.Walls.left.fixture:setUserData("wall")
    self.Walls.right = {}
    self.Walls.right.body = love.physics.newBody(World, WindowWidth/GlobalScale+10, WindowHeight/GlobalScale/2, "static")
    self.Walls.right.body:setUserData("wall")
    self.Walls.right.shape = love.physics.newRectangleShape(20, WindowHeight/GlobalScale)
    self.Walls.right.fixture = love.physics.newFixture(self.Walls.right.body, self.Walls.right.shape)
    self.Walls.right.fixture:setUserData("wall")
    
    -- Define background
    local spritesheet = love.graphics.newImage("assets/levels/everhart_backyard.png")
    local asepriteMeta = "assets/levels/everhart_backyard.json"
    self.Backyard = {}
    self.Backyard.base = peachy.new(asepriteMeta, spritesheet, "idle")
    -- Define Lee grilling
    self.Lee = {}
    self.Lee.burger_in = peachy.new(asepriteMeta, spritesheet, "burger_in")
    self.Lee.burger_flip = peachy.new(asepriteMeta, spritesheet, "burger_flip")
    self.Lee.burger_out = peachy.new(asepriteMeta, spritesheet, "burger_out")
    self.Lee.beer = peachy.new(asepriteMeta, spritesheet, "beer")
    self.lee_state = 1
    self.lee_states = {"beer", "burger_in", "burger_flip", "burger_out"}
    self.lee_accumulator = 0.0
    self.dur = 10.0
    self.duration = math.random()*self.dur+self.dur
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
    print(self.lee_states[self.lee_state].." @ frame "..self.Lee[self.lee_states[self.lee_state]]:getFrame())
    self.Backyard.base:update(dt)
    self:setLeeState(dt)
    self.Lee[self.lee_states[self.lee_state]]:update(dt)
    self.player1:update(dt)
    self.player2:update(dt)
end

function Level:incrementTimers(dt)
    self.lee_accumulator = self.lee_accumulator + dt
    if self.lee_accumulator > self.duration then
        self.lee_accumulator = 0.0
        self.lee_state = self.lee_state + 1
        if self.lee_state > 4 then
            self.lee_state = 1
        end
    end
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
    -- Draw Canvas
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, x, y)
end

function Level:drawForeground()
end

function Level:setLeeState(dt)
    local current_state = self.lee_state
    
    self:incrementTimers(dt)

    if self.lee_state == 2 or self.lee_state == 4 then
        self.duration = 0.2
    else
        self.duration = math.random()*self.dur
    end

    -- Reset starting frame to 1 if state has changed
    if current_state ~= self.lee_state then
        -- print("Changing from "..current_state.." to "..self.lee_states[self.lee_state])
        self.Lee[self.lee_states[self.lee_state]]:setFrame(1)
    end
end

function Level:drawBackground()
    self.Backyard.base:draw(0,0)
    if self.lee_states[self.lee_state] == "beer" then
        self.Lee.beer:draw(0,0)
    elseif self.lee_states[self.lee_state] == "burger_in" then
        self.Lee.burger_in:draw(0,0)
    elseif self.lee_states[self.lee_state] == "burger_out" then
        self.Lee.burger_out:draw(0,0)
    elseif self.lee_states[self.lee_state] == "burger_flip" then
        self.Lee.burger_flip:draw(0,0)
    end
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