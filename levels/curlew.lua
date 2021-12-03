local peachy = require("3rd/peachy/peachy")
local player = require"characters/player"

Level = {}
Level.__index = Level

function Level:load(player1, player2, canvas)
    self.name = "curlew"
    self.canvas = canvas
    self.canvas2 = love.graphics.newCanvas(WindowWidth, WindowHeight)
    -- Dock dimensions
    self.Dock = {}
    self.Dock.x = {121, 71, 89, 153, 170}
    self.Dock.y = {136, 136, 136, 136, 136}
    self.Dock.w = {41, 13, 22, 22, 13}
    self.Dock.h = {10, 10, 10, 10, 10}
    self.Dock.m = {1000, 300, 640, 640, 300}
    -- Load shader
    local water_effect = love.filesystem.read("levels/water_shader.glsl")
    self.eff = love.graphics.newShader(water_effect)
    self.delta = 0
    -- Create Dock
    self.Base = {}
    for i = 1, #self.Dock.x do
        -- Create dock anchor
        self.Base[i] = {}
        self.Base[i].body = love.physics.newBody(World, self.Dock.x[i], self.Dock.y[i], "static")
        self.Base[i].shape = love.physics.newRectangleShape(self.Dock.w[i], self.Dock.h[i])
        self.Base[i].fixture = love.physics.newFixture(self.Base[i].body, self.Base[i].shape)
        self.Base[i].fixture:setUserData("sensor")
        self.Base[i].fixture:setSensor(true)
        -- Create dock
        self.Dock[i] = {}
        self.Dock[i].body = love.physics.newBody(World, self.Dock.x[i], self.Dock.y[i], "dynamic")
        self.Dock[i].x = self.Dock[i].body:getX()
        self.Dock[i].y = self.Dock[i].body:getY()
        self.Dock[i].body:setUserData("ground")
        self.Dock[i].body:setFixedRotation(true)
        self.Dock[i].shape = love.physics.newRectangleShape(self.Dock.w[i], self.Dock.h[i])
        self.Dock[i].fixture = love.physics.newFixture(self.Dock[i].body, self.Dock[i].shape)
        --Dock[i].fixture:setFriction(Friction)
        self.Dock[i].fixture:setUserData("ground")
        self.Dock[i].body:setMass(self.Dock.m[i])
        -- Create distance joints
        self.Base[i].joint = love.physics.newDistanceJoint(self.Base[i].body, self.Dock[i].body, self.Base[i].body:getX(), self.Base[i].body:getY(), self.Dock[i].body:getX(), self.Dock[i].body:getY(), false)
        self.Base[i].joint:setDampingRatio(0.1)
        self.Base[i].joint:setFrequency(5)
        self.Base[i].joint:setLength(0)
    end
    -- Create anchor for left toy
    self.Floaty1_Base = {}
    self.Floaty1_Base.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.8, "static")
    self.Floaty1_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    self.Floaty1_Base.fixture = love.physics.newFixture(self.Floaty1_Base.body, self.Floaty1_Base.shape)
    self.Floaty1_Base.fixture:setUserData("sensor")
    self.Floaty1_Base.fixture:setSensor(true)
    -- Create left toy
    self.Floaty1 = {}
    self.Floaty1.body = love.physics.newBody(World, 34, WindowHeight/GlobalScale*0.8, "dynamic")
    self.Floaty1.x = self.Floaty1.body:getX()
    self.Floaty1.y = self.Floaty1.body:getY()
    self.Floaty1.body:setUserData("ground")
    self.Floaty1.body:setFixedRotation(true)
    self.Floaty1.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    self.Floaty1.fixture = love.physics.newFixture(self.Floaty1.body, self.Floaty1.shape)
    self.Floaty1.fixture:setFriction(Friction)
    self.Floaty1.fixture:setUserData("ground")
    self.Floaty1.body:setMass(500)
    -- Create anchor for right toy
    self.Floaty2_Base = {}
    self.Floaty2_Base.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.8, "static")
    self.Floaty2_Base.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    self.Floaty2_Base.fixture = love.physics.newFixture(self.Floaty2_Base.body, self.Floaty2_Base.shape)
    self.Floaty2_Base.fixture:setUserData("sensor")
    self.Floaty2_Base.fixture:setSensor(true)
    -- Create right toy
    self.Floaty2 = {}
    self.Floaty2.body = love.physics.newBody(World, 215, WindowHeight/GlobalScale*0.8, "dynamic")
    self.Floaty2.x = self.Floaty2.body:getX()
    self.Floaty2.y = self.Floaty2.body:getY()
    self.Floaty2.body:setUserData("ground")
    self.Floaty2.body:setFixedRotation(true)
    self.Floaty2.shape = love.physics.newRectangleShape(WindowWidth/GlobalScale*0.14, 10)
    self.Floaty2.fixture = love.physics.newFixture(self.Floaty2.body, self.Floaty2.shape)
    self.Floaty2.fixture:setFriction(Friction)
    self.Floaty2.fixture:setUserData("ground")
    self.Floaty2.body:setMass(500)
    self.Floaty2_arm = {}
    self.Floaty2_arm.body = love.physics.newBody(World, 234, WindowHeight/GlobalScale*0.725, "dynamic")
    self.Floaty2_arm.shape = love.physics.newRectangleShape(4, 15)
    self.Floaty2_arm.fixture = love.physics.newFixture(self.Floaty2_arm.body, self.Floaty2_arm.shape)
    self.Floaty2_arm.body:setUserData("ground")
    self.Floaty2_arm.body:setFixedRotation(true)
    self.Floaty2_arm.fixture:setUserData("ground")
    self.Floaty2_arm.body:setMass(500)
    
    self.Floaty1_Base.joint = love.physics.newDistanceJoint(self.Floaty1_Base.body, self.Floaty1.body, self.Floaty1_Base.body:getX(), self.Floaty1_Base.body:getY(), self.Floaty1.body:getX(), self.Floaty1.body:getY(), false)
    self.Floaty1_Base.joint:setDampingRatio(0.1)
    self.Floaty1_Base.joint:setFrequency(2)
    self.Floaty1_Base.joint:setLength(0)
    self.Floaty2_Base.joint = love.physics.newDistanceJoint(self.Floaty2_Base.body, self.Floaty2.body, self.Floaty2_Base.body:getX(), self.Floaty2_Base.body:getY(), self.Floaty2.body:getX(), self.Floaty2.body:getY(), false)
    self.Floaty2_Base.joint:setDampingRatio(0.1)
    self.Floaty2_Base.joint:setFrequency(2)
    self.Floaty2_Base.joint:setLength(0)
    self.Floaty2.joint = love.physics.newWeldJoint(self.Floaty2.body, self.Floaty2_arm.body, self.Floaty2_arm.body:getX()-2, self.Floaty2_arm.body:getY()-15/2, false)
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
    Curlew.Water = peachy.new(asepriteMeta, spritesheet, "water")
    Curlew.Background = peachy.new(asepriteMeta, spritesheet, "background")
    Curlew.Dock = {}
    Curlew.Dock[1] = peachy.new(asepriteMeta, spritesheet, "dock1")
    Curlew.Dock[2] = peachy.new(asepriteMeta, spritesheet, "dock2")
    Curlew.Dock[3] = peachy.new(asepriteMeta, spritesheet, "dock3")
    Curlew.Dock[4] = peachy.new(asepriteMeta, spritesheet, "dock4")
    Curlew.Dock[5] = peachy.new(asepriteMeta, spritesheet, "dock5")
    Curlew.Floaty1 = peachy.new(asepriteMeta, spritesheet, "floaty1")
    Curlew.Floaty2 = peachy.new(asepriteMeta, spritesheet, "floaty2")
    Curlew.Floaty2_front = peachy.new(asepriteMeta, spritesheet, "floaty2_front")
    self.normal_map = love.graphics.newImage("assets/levels/normal_map.png")
    self.normal_map:setWrap("repeat")
    -- Define Constants
    self.x1 = WindowWidth/GlobalScale*0.33
    self.y1 = WindowHeight/GlobalScale*0.1
    -- self.y1 = WindowHeight/GlobalScale*-100
    self.x2 = WindowWidth/GlobalScale*0.7
    self.y2 = WindowHeight/GlobalScale*0.1
    -- self.y2 = WindowHeight/GlobalScale*-100
    self.displacedMass = 0

    -- Load players
    self.player1 = player:new(1, player1, Level.x1, Level.y1)
    self.player1:load()
    self.player2 = player:new(2, player2, Level.x2, Level.y2)
    self.player2:load()
end

function Level:update(dt)
    Curlew.Water:update(dt)
    Curlew.Floaty1:update(dt)
    Curlew.Floaty2:update(dt)
    Curlew.Dock[1]:update(dt)
    self.player1:update(dt)
    self.player2:update(dt)
    self.eff:send("image2", self.canvas2)
    self.eff:send("normal_map", self.normal_map)
    self.delta = self.delta - dt*0.03
    if self.delta < -1.0 then
        self.delta = 0.0
    end
    self.eff:send("d", self.delta)
    self.eff:send("dock2_y", self.Dock[2].body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("dock3_y", self.Dock[3].body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("dock4_y", self.Dock[4].body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("dock5_y", self.Dock[5].body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("float1_y", self.Floaty1.body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("float1_x", self.Floaty1.body:getX()/(WindowWidth/GlobalScale))
    self.eff:send("float2_y", self.Floaty2.body:getY()/(WindowHeight/GlobalScale))
    self.eff:send("float2_x", self.Floaty2.body:getX()/(WindowWidth/GlobalScale))
end

function Level:draw(x, y, sx, sy, option)
    -- Activate Canvas
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    -- Draw background to have shader applied to it
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawShadedBackground()
    if option then
        self.player1:draw()
        self.player2:draw()
    end
    self:drawForeground()
    if not option then
        self:drawBackground()
    end
    love.graphics.pop()
    -- Draw Canvas
    love.graphics.setCanvas()
    love.graphics.setCanvas(self.canvas2)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawWater()
    love.graphics.pop()
    love.graphics.setCanvas()
    self.canvas2:newImageData():encode("png", "canvas2.png")
    if option then
        love.graphics.setShader(self.eff)
    end
    love.graphics.draw(self.canvas, x, y)
    -- Remove shader and draw background water
    love.graphics.setShader()
    if option then
        love.graphics.push()
        love.graphics.scale(sx, sy)
        self:drawBackground()
        self.player1:draw()
        self.player2:draw()
        self:drawForeground()
        love.graphics.pop()
    end
end

function Level:drawForeground()
    Curlew.Floaty2_front:draw(self.Floaty2.body:getX(),self.Floaty2.body:getY()-5, 0, 1, 1, 214, 128)
end

function Level:drawWater()
    Curlew.Water:draw()
end

function Level:drawShadedBackground()
    Curlew.Water:draw(0,0)
    for i = 2, 5 do
        Curlew.Dock[i]:draw(self.Dock[i].body:getX(), self.Dock[i].body:getY(), self.Dock[i].body:getAngle(), 1, 1, self.Dock.x[i], self.Dock.y[i])
    end
    Curlew.Dock[1]:draw(self.Dock[1].body:getX(), self.Dock[1].body:getY(), 0, 1, 1, self.Dock.x[1], self.Dock.y[1])
    Curlew.Floaty1:draw(self.Floaty1.body:getX(),self.Floaty1.body:getY()-5, 0, 1, 1, 34, 128)
    Curlew.Floaty2:draw(self.Floaty2.body:getX(),self.Floaty2.body:getY()-5, 0, 1, 1, 214, 128)
    if Debug then
        --[[ love.graphics.setBackgroundColor(0.25, 0.25, 0.25)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 40, WindowWidth/GlobalScale, 40) ]]
        love.graphics.setColor(0, 0, 0, 0.5)
        --love.graphics.polygon("fill", Base[1].body:getWorldPoints(Base[1].shape:getPoints()))
        love.graphics.polygon("fill", self.Dock[1].body:getWorldPoints(self.Dock[1].shape:getPoints()))
        love.graphics.polygon("fill", self.Dock[2].body:getWorldPoints(self.Dock[2].shape:getPoints()))
        love.graphics.polygon("fill", self.Dock[3].body:getWorldPoints(self.Dock[3].shape:getPoints()))
        love.graphics.polygon("fill", self.Dock[4].body:getWorldPoints(self.Dock[4].shape:getPoints()))
        love.graphics.polygon("fill", self.Dock[5].body:getWorldPoints(self.Dock[5].shape:getPoints()))
        love.graphics.polygon("fill", self.Floaty1_Base.body:getWorldPoints(self.Floaty1_Base.shape:getPoints()))
        love.graphics.polygon("fill", self.Floaty1.body:getWorldPoints(self.Floaty1.shape:getPoints()))
        love.graphics.polygon("fill", self.Floaty2_Base.body:getWorldPoints(self.Floaty2_Base.shape:getPoints()))
        love.graphics.polygon("fill", self.Floaty2.body:getWorldPoints(self.Floaty2.shape:getPoints()))
        love.graphics.polygon("fill", self.Floaty2_arm.body:getWorldPoints(self.Floaty2_arm.shape:getPoints()))
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Level:drawBackground()
    Curlew.Background:draw(0, 0)
    for i = 2, 5 do
        Curlew.Dock[i]:draw(self.Dock[i].body:getX(), self.Dock[i].body:getY(), self.Dock[i].body:getAngle(), 1, 1, self.Dock.x[i], self.Dock.y[i])
    end
    Curlew.Dock[1]:draw(self.Dock[1].body:getX(), self.Dock[1].body:getY(), 0, 1, 1, self.Dock.x[1], self.Dock.y[1])
    Curlew.Floaty1:draw(self.Floaty1.body:getX(),self.Floaty1.body:getY()-5, 0, 1, 1, 34, 128)
    Curlew.Floaty2:draw(self.Floaty2.body:getX(),self.Floaty2.body:getY()-5, 0, 1, 1, 214, 128)
    love.graphics.setColor(1, 1, 1, 1)
end

return Level