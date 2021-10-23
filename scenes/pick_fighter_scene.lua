local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local pickFighterScene = scene:new("pickFigherScene")

function pickFighterScene:load()
    self.time_delay = 5
    self.chars = {"drew", "lilah", "sam"}
    self.chars_spacing = {12, 21, 9}
    self.animations = {}
    for _, char in pairs(self.chars) do
        local spritesheet = love.graphics.newImage("assets/Characters/"..char..".png")
        local asepriteMeta = "assets/Characters/"..char..".json"
        self.animations[char] = {idle = peachy.new(asepriteMeta, spritesheet, "idle")}
    end
    local spritesheet = love.graphics.newImage("assets/ui/character_box.png")
    local asepriteMeta = "assets/ui/character_box.json"
    self.animations.not_hovering = peachy.new(asepriteMeta, spritesheet, "not_hovering")
    self.animations.player1 = peachy.new(asepriteMeta, spritesheet, "player1")
    self.animations.player2 = peachy.new(asepriteMeta, spritesheet, "player2")
    self.animations.selection = peachy.new(asepriteMeta, spritesheet, "selection")
    local spritesheet = love.graphics.newImage("assets/ui/stage.png")
    local asepriteMeta = "assets/ui/stage.json"
    self.animations.stage = peachy.new(asepriteMeta, spritesheet, "stage")
    self.animations.lighting = peachy.new(asepriteMeta, spritesheet, "lighting")
    self.selection = false
    self.selection_timer = 0
    self.player1 = 1
    self.player2 = 2
    self.move = false
    self.move_timer = 0
    -- Process controller
    local joystickcount = love.joystick.getJoystickCount( )
    if joystickcount == 2 then
        local joysticks = love.joystick.getJoysticks()
        self.joystick1 = joysticks[1]
        self.joystick2 = joysticks[2]
    else
        self.joystick1 = nil
        self.joystick2 = nil
    end
end

function pickFighterScene:update(dt, gameState)
    self.time_delay = self.time_delay - dt
    self:updateCharacters(dt)

    if next(KeysPressed) ~= nil and self.time_delay < 0 then
        gameState:setFightScene()
    end
    if next(ButtonsPressed[1]) ~= nil and self.time_delay < 0 then
        gameState:setFightScene()
    end
end

function pickFighterScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self:drawBackground()
    self:drawStage(1)
    self:drawCharacters()
    self:drawStage(2)
    love.graphics.pop()
end

function pickFighterScene:drawBackground()
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

function pickFighterScene:drawCharacters()
    local x0 = 40
    local y0 = 30
    local spacing = 50
    local scale = 1
    for i, char in pairs(self.chars) do
        self.animations[char].idle:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.chars_spacing[i], self.animations[char].idle:getHeight()/2)
        if i == self.player1 then
            self.animations.player1:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player1:getWidth()/2, self.animations.player1:getHeight()/2)
            if self.selection and self.selection_timer < 0.4 then
                self.animations.selection:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.selection:getWidth()/2, self.animations.selection:getHeight()/2)
            elseif self.selection_timer > 0.4 then
                self.selection = false
                self.selection_timer = 0
            end
        elseif i == self.player2 then
            self.animations.player2:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player2:getWidth()/2, self.animations.player2:getHeight()/2)
        else
            self.animations.not_hovering:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.not_hovering:getWidth()/2, self.animations.not_hovering:getHeight()/2)
        end
        
        self:selectCharacter()
        if Debug then
            love.graphics.rectangle("fill", x0+(i-1)*spacing, y0, 1, 1)
        end
    end
    -- Draw Selected Characters
    local xchar = 70
    local ychar = 110
    local scale = 2
    self.animations[self.chars[self.player1]].idle:draw(xchar, ychar, 0, scale, scale,self.chars_spacing[self.player1], self.animations[self.chars[self.player1]].idle:getHeight()/2)
    self.animations[self.chars[self.player2]].idle:draw(WindowWidth/GlobalScale-xchar, ychar, 0, scale, scale, self.chars_spacing[self.player2], self.animations[self.chars[self.player2]].idle:getHeight()/2)
end

function pickFighterScene:drawStage(option)
    local x0 = 70
    local y0 = 110
    local scale = 2
    if option == 1 then
        self.animations.stage:draw(x0, y0, 0, scale, scale, 22, self.animations.stage:getHeight()/2)
        self.animations.stage:draw(WindowWidth/GlobalScale-x0, y0, 0, scale, scale, 22, self.animations.stage:getHeight()/2)
    else
        self.animations.lighting:draw(x0, y0, 0, scale, scale, 22, self.animations.stage:getHeight()/2)
        self.animations.lighting:draw(WindowWidth/GlobalScale-x0, y0, 0, scale, scale, 22, self.animations.stage:getHeight()/2)
    end
end

function pickFighterScene:updateCharacters(dt)
    for i, char in pairs(self.chars) do
        self.animations[char].idle:update(dt)
    end
    self.animations.not_hovering:update(dt)
    self.animations.player1:update(dt)
    self.animations.player2:update(dt)
    self.animations.selection:update(dt)
    if AxisMoved[1]["leftx"] ~= nil and AxisMoved[1]["leftx"] > 0 and not self.move then
        self.player1 = self.player1 + 1
        if self.player1 == self.player2 then
            self.player1 = self.player1 + 1
        elseif self.player1 > #self.chars then
            self.player1 = self.player1 - 1
        end
        self.move = true
        self.move_timer = 0
    elseif AxisMoved[1]["leftx"] ~= nil and AxisMoved[1]["leftx"] < 0 and not self.move then
        self.player1 = self.player1 - 1
        if self.player1 == self.player2 then
            self.player1 = self.player1 - 1
        elseif self.player2 < 1 then
            self.player1 = self.player1 + 1
        end
        self.move = true
        self.move_timer = 0
    end
    if AxisMoved[2]["leftx"] ~= nil and AxisMoved[2]["leftx"] > 0 and not self.move then
        self.player2 = self.player2 + 1
        if self.player2 == self.player1 then
            self.player2 = self.player2 + 1
        end
        self.move = true
        self.move_timer = 0
    elseif AxisMoved[2]["leftx"] ~= nil and AxisMoved[2]["leftx"] < 0 and not self.move then
        self.player2 = self.player2 - 1
        if self.player2 == self.player1 then
            self.player2 = self.player2 - 1
        end
        self.move = true
        self.move_timer = 0
    end
    if self.move then
        self.move_timer = self.move_timer + dt
        if self.move_timer > 0.3 then
            self.move_timer = 0
            self.move = false
        end
    end
    if self.selection then
        self.selection_timer = self.selection_timer + dt
    end
end

function pickFighterScene:selectCharacter()
    if ButtonsPressed[1]["a"] == true then
        self.selection = true
        self.animations.selection:setFrame(1)
        self.animations.selection:play()
    end
end

return pickFighterScene