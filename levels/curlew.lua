local peachy = require("3rd/peachy/peachy")

Level = {}
Level.__index = Level

function Level:load()
    -- Dock dimensions
    self.Dock = {}
    self.Dock.x = {121, 71, 89, 153, 170}
    self.Dock.y = {136, 136, 136, 136, 136}
    self.Dock.w = {41, 13, 22, 22, 13}
    self.Dock.h = {10, 10, 10, 10, 10}
    self.Dock.m = {1000, 300, 640, 640, 300}
    -- Create Dock
    Base = {}
    Dock = {}
    for i = 1, #self.Dock.x do
        -- Create dock anchor
        Base[i] = {}
        Base[i].body = love.physics.newBody(World, self.Dock.x[i], self.Dock.y[i], "static")
        Base[i].shape = love.physics.newRectangleShape(self.Dock.w[i], self.Dock.h[i])
        Base[i].fixture = love.physics.newFixture(Base[i].body, Base[i].shape)
        Base[i].fixture:setUserData("sensor")
        Base[i].fixture:setSensor(true)
        -- Create dock
        Dock[i] = {}
        Dock[i].body = love.physics.newBody(World, self.Dock.x[i], self.Dock.y[i], "dynamic")
        Dock[i].x = Dock[i].body:getX()
        Dock[i].y = Dock[i].body:getY()
        Dock[i].body:setUserData("ground")
        Dock[i].body:setFixedRotation(true)
        Dock[i].shape = love.physics.newRectangleShape(self.Dock.w[i], self.Dock.h[i])
        Dock[i].fixture = love.physics.newFixture(Dock[i].body, Dock[i].shape)
        --Dock[i].fixture:setFriction(Friction)
        Dock[i].fixture:setUserData("ground")
        Dock[i].body:setMass(self.Dock.m[i])
        -- Create distance joints
        Base[i].joint = love.physics.newDistanceJoint(Base[i].body, Dock[i].body, Base[i].body:getX(), Base[i].body:getY(), Dock[i].body:getX(), Dock[i].body:getY(), false)
        Base[i].joint:setDampingRatio(0.1)
        Base[i].joint:setFrequency(5)
        Base[i].joint:setLength(0)
    end
    -- Create anchor for left toy
    Floaty1_Base = {}
    Floaty1_Base.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.8, "static")
    Floaty1_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Floaty1_Base.fixture = love.physics.newFixture(Floaty1_Base.body, Floaty1_Base.shape)
    Floaty1_Base.fixture:setUserData("sensor")
    Floaty1_Base.fixture:setSensor(true)
    -- Create left toy
    Floaty1 = {}
    Floaty1.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.8, "dynamic")
    Floaty1.x = Floaty1.body:getX()
    Floaty1.y = Floaty1.body:getY()
    Floaty1.body:setUserData("ground")
    Floaty1.body:setFixedRotation(true)
    Floaty1.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Floaty1.fixture = love.physics.newFixture(Floaty1.body, Floaty1.shape)
    Floaty1.fixture:setFriction(Friction)
    Floaty1.fixture:setUserData("ground")
    Floaty1.body:setMass(500)
    -- Create anchor for right toy
    Floaty2_Base = {}
    Floaty2_Base.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.8, "static")
    Floaty2_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Floaty2_Base.fixture = love.physics.newFixture(Floaty2_Base.body, Floaty2_Base.shape)
    Floaty2_Base.fixture:setUserData("sensor")
    Floaty2_Base.fixture:setSensor(true)
    -- Create right toy
    Floaty2 = {}
    Floaty2.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.8, "dynamic")
    Floaty2.x = Floaty2.body:getX()
    Floaty2.y = Floaty2.body:getY()
    Floaty2.body:setUserData("ground")
    Floaty2.body:setFixedRotation(true)
    Floaty2.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    Floaty2.fixture = love.physics.newFixture(Floaty2.body, Floaty2.shape)
    Floaty2.fixture:setFriction(Friction)
    Floaty2.fixture:setUserData("ground")
    Floaty2.body:setMass(500)
    Floaty2_arm = {}
    Floaty2_arm.body = love.physics.newBody(World, 234, WindowHeight/GlobalScale*0.725, "dynamic")
    Floaty2_arm.shape = love.physics.newRectangleShape(4, 15)
    Floaty2_arm.fixture = love.physics.newFixture(Floaty2_arm.body, Floaty2_arm.shape)
    Floaty2_arm.body:setUserData("ground")
    Floaty2_arm.body:setFixedRotation(true)
    Floaty2_arm.fixture:setUserData("ground")
    Floaty2_arm.body:setMass(500)
    
    Floaty1_Base.joint = love.physics.newDistanceJoint(Floaty1_Base.body, Floaty1.body, Floaty1_Base.body:getX(), Floaty1_Base.body:getY(), Floaty1.body:getX(), Floaty1.body:getY(), false)
    Floaty1_Base.joint:setDampingRatio(0.1)
    Floaty1_Base.joint:setFrequency(2)
    Floaty1_Base.joint:setLength(0)
    Floaty2_Base.joint = love.physics.newDistanceJoint(Floaty2_Base.body, Floaty2.body, Floaty2_Base.body:getX(), Floaty2_Base.body:getY(), Floaty2.body:getX(), Floaty2.body:getY(), false)
    Floaty2_Base.joint:setDampingRatio(0.1)
    Floaty2_Base.joint:setFrequency(2)
    Floaty2_Base.joint:setLength(0)
    Floaty2.joint = love.physics.newWeldJoint(Floaty2.body, Floaty2_arm.body, Floaty2_arm.body:getX()-2, Floaty2_arm.body:getY()-15/2, false)
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
    Curlew.Dock = {}
    Curlew.Dock[1] = peachy.new(asepriteMeta, spritesheet, "dock1")
    Curlew.Dock[2] = peachy.new(asepriteMeta, spritesheet, "dock2")
    Curlew.Dock[3] = peachy.new(asepriteMeta, spritesheet, "dock3")
    Curlew.Dock[4] = peachy.new(asepriteMeta, spritesheet, "dock4")
    Curlew.Dock[5] = peachy.new(asepriteMeta, spritesheet, "dock5")
    Curlew.floaty1 = peachy.new(asepriteMeta, spritesheet, "floaty1")
    Curlew.floaty2 = peachy.new(asepriteMeta, spritesheet, "floaty2")
    Curlew.floaty2_front = peachy.new(asepriteMeta, spritesheet, "floaty2_front")
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
    Curlew.floaty1:update(dt)
    Curlew.floaty2:update(dt)
    Curlew.Dock[1]:update(dt)
end

function Level:drawForeground()
    Curlew.floaty2_front:draw(Floaty2.body:getX(),Floaty2.body:getY()-5, 0, 1, 1, 214, 128)
end

function Level:drawBackground()love.graphics.polygon("fill", Dock[1].body:getWorldPoints(Dock[1].shape:getPoints()))
    Curlew.base:draw(0,0)
    for i = 2, 5 do
        Curlew.Dock[i]:draw(Dock[i].body:getX(), Dock[i].body:getY(), Dock[i].body:getAngle(), 1, 1, self.Dock.x[i], self.Dock.y[i])
    end
    Curlew.Dock[1]:draw(Dock[1].body:getX(), Dock[1].body:getY(), 0, 1, 1, self.Dock.x[1], self.Dock.y[1])
    Curlew.floaty1:draw(Floaty1.body:getX(),Floaty1.body:getY()-5, 0, 1, 1, 34, 128)
    Curlew.floaty2:draw(Floaty2.body:getX(),Floaty2.body:getY()-5, 0, 1, 1, 214, 128)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        --love.graphics.polygon("fill", Base[1].body:getWorldPoints(Base[1].shape:getPoints()))
        love.graphics.polygon("fill", Dock[1].body:getWorldPoints(Dock[1].shape:getPoints()))
        love.graphics.polygon("fill", Dock[2].body:getWorldPoints(Dock[2].shape:getPoints()))
        love.graphics.polygon("fill", Dock[3].body:getWorldPoints(Dock[3].shape:getPoints()))
        love.graphics.polygon("fill", Dock[4].body:getWorldPoints(Dock[4].shape:getPoints()))
        love.graphics.polygon("fill", Dock[5].body:getWorldPoints(Dock[5].shape:getPoints()))
        love.graphics.polygon("fill", Floaty1_Base.body:getWorldPoints(Floaty1_Base.shape:getPoints()))
        love.graphics.polygon("fill", Floaty1.body:getWorldPoints(Floaty1.shape:getPoints()))
        love.graphics.polygon("fill", Floaty2_Base.body:getWorldPoints(Floaty2_Base.shape:getPoints()))
        love.graphics.polygon("fill", Floaty2.body:getWorldPoints(Floaty2.shape:getPoints()))
        love.graphics.polygon("fill", Floaty2_arm.body:getWorldPoints(Floaty2_arm.shape:getPoints()))
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Level