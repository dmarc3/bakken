local peachy = require("3rd/peachy/peachy")

Level = {}
Level.__index = Level

function Level:load()
    -- Create anchor for dock
    Base = {}
    Base.body = love.physics.newBody(World, WindowWidth/GlobalScale/2+1, WindowHeight/GlobalScale*0.625, "static")
    Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.47, 10)
    Base.fixture = love.physics.newFixture(Base.body, Base.shape)
    Base.fixture:setUserData("sensor")
    Base.fixture:setSensor(true)
    -- Create dock
    Dock = {}
    Dock.body = love.physics.newBody(World, WindowWidth/GlobalScale/2+1, WindowHeight/GlobalScale*0.625, "dynamic")
    Dock.x = Dock.body:getX()
    Dock.y = Dock.body:getY()
    Dock.xVel = 0
    Dock.yVel = 0
    Dock.body:setUserData("ground")
    Dock.body:setFixedRotation(true)
    Dock.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.47, 10)
    Dock.fixture = love.physics.newFixture(Dock.body, Dock.shape)
    Dock.fixture:setFriction(Friction)
    Dock.fixture:setUserData("ground")
    Dock.body:setMass(500)
    -- Create anchor for left toy
    Toy1_Base = {}
    Toy1_Base.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.625, "static")
    Toy1_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Toy1_Base.fixture = love.physics.newFixture(Toy1_Base.body, Toy1_Base.shape)
    Toy1_Base.fixture:setUserData("sensor")
    Toy1_Base.fixture:setSensor(true)
    -- Create left toy
    Toy1 = {}
    Toy1.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.625, "dynamic")
    Toy1.x = Toy1.body:getX()
    Toy1.y = Toy1.body:getY()
    Toy1.xVel = 0
    Toy1.yVel = 0
    Toy1.body:setUserData("ground")
    Toy1.body:setFixedRotation(true)
    Toy1.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Toy1.fixture = love.physics.newFixture(Toy1.body, Toy1.shape)
    Toy1.fixture:setFriction(Friction)
    Toy1.fixture:setUserData("ground")
    Toy1.body:setMass(200)
    -- Create anchor for right toy
    Toy2_Base = {}
    Toy2_Base.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.625, "static")
    Toy2_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Toy2_Base.fixture = love.physics.newFixture(Toy2_Base.body, Toy2_Base.shape)
    Toy2_Base.fixture:setUserData("sensor")
    Toy2_Base.fixture:setSensor(true)
    -- Create right toy
    Toy2 = {}
    Toy2.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.625, "dynamic")
    Toy2.x = Toy2.body:getX()
    Toy2.y = Toy2.body:getY()
    Toy2.xVel = 0
    Toy2.yVel = 0
    Toy2.body:setUserData("ground")
    Toy2.body:setFixedRotation(true)
    Toy2.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Toy2.fixture = love.physics.newFixture(Toy2.body, Toy2.shape)
    Toy2.fixture:setFriction(Friction)
    Toy2.fixture:setUserData("ground")
    Toy2.body:setMass(200)
    -- Create distance joints
    Base.joint = love.physics.newDistanceJoint(Base.body, Dock.body, Base.body:getX(), Base.body:getY(), Dock.body:getX(), Dock.body:getY(), false)
    Base.joint:setDampingRatio(0.1)
    Base.joint:setFrequency(2)
    Base.joint:setLength(0)
    Toy1_Base.joint = love.physics.newDistanceJoint(Toy1_Base.body, Toy1.body, Toy1_Base.body:getX(), Toy1_Base.body:getY(), Toy1.body:getX(), Toy1.body:getY(), false)
    Toy1_Base.joint:setDampingRatio(0.1)
    Toy1_Base.joint:setFrequency(2)
    Toy1_Base.joint:setLength(0)
    Toy2_Base.joint = love.physics.newDistanceJoint(Toy2_Base.body, Toy2.body, Toy2_Base.body:getX(), Toy2_Base.body:getY(), Toy2.body:getX(), Toy2.body:getY(), false)
    Toy2_Base.joint:setDampingRatio(0.1)
    Toy2_Base.joint:setFrequency(2)
    Toy2_Base.joint:setLength(0)
    -- Create boundaries
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
    self.x1 = WindowWidth/GlobalScale*0.33
    self.y1 = WindowHeight/GlobalScale*0.1
    -- self.y1 = WindowHeight/GlobalScale*-100
    self.x2 = WindowWidth/GlobalScale*0.7
    self.y2 = WindowHeight/GlobalScale*0.1
    -- self.y2 = WindowHeight/GlobalScale*-100
    self.displacedMass = 0
end

function Level:update(dt)
    Curlew.base:update(dt)
end

function Level:drawForeground()
end

function Level:drawBackground()love.graphics.polygon("fill", Dock.body:getWorldPoints(Dock.shape:getPoints()))
    Curlew.base:draw(0,0)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.polygon("fill", Base.body:getWorldPoints(Base.shape:getPoints()))
        love.graphics.polygon("fill", Dock.body:getWorldPoints(Dock.shape:getPoints()))
        love.graphics.polygon("fill", Toy1_Base.body:getWorldPoints(Toy1_Base.shape:getPoints()))
        love.graphics.polygon("fill", Toy1.body:getWorldPoints(Toy1.shape:getPoints()))
        love.graphics.polygon("fill", Toy2_Base.body:getWorldPoints(Toy2_Base.shape:getPoints()))
        love.graphics.polygon("fill", Toy2.body:getWorldPoints(Toy2.shape:getPoints()))
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Level