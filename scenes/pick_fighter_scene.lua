local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local pickFighterScene = scene:new("pickFigherScene")

P1 = "drew"
P2 = "lilah"

function pickFighterScene:load()
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
    self.animations.player1_selected = peachy.new(asepriteMeta, spritesheet, "player1_selected")
    self.animations.player2 = peachy.new(asepriteMeta, spritesheet, "player2")
    self.animations.player2_selected = peachy.new(asepriteMeta, spritesheet, "player2_selected")
    self.animations.selection = peachy.new(asepriteMeta, spritesheet, "selection")
    self.animations.selection:pause()
    local spritesheet = love.graphics.newImage("assets/ui/stage.png")
    local asepriteMeta = "assets/ui/stage.json"
    self.animations.stage = peachy.new(asepriteMeta, spritesheet, "stage")
    self.animations.lighting = peachy.new(asepriteMeta, spritesheet, "lighting")
    self.selected1 = false
    self.selected2 = false
    self.selection1 = false
    self.selection2 = false
    self.selection1_timer = 0
    self.selection2_timer = 0
    self.player1 = 1
    self.player2 = 2
    self.move = false
    self.move_timer = 0
    self.delay = true
    self.delay_timer = 0
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
    -- Reset Inputs on load
    ResetInputs()
end

function pickFighterScene:update(dt, gameState)
    -- print(tostring(self.selected1)..' and '..tostring(self.selected2))
    self:processDelay()
    self:incrementTimers(dt)
    self:updateCharacters(dt)
    if KeysPressed["enter"] == true then
        gameState.player1 = self.chars[self.player1]
        gameState.player2 = self.chars[self.player2]
        gameState:setFightScene()
    end
    if ButtonsPressed[1]["start"] == true then
        gameState.player1 = self.chars[self.player1]
        gameState.player2 = self.chars[self.player2]
        gameState:setFightScene()
    end
end

function pickFighterScene:draw(sx, sy)
    self:processDelay()
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
        love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale-20, WindowWidth/GlobalScale, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill",  WindowHeight/GlobalScale-20, WindowWidth/GlobalScale, 1, 1)
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
            if self.selected1 then
                self.animations.player1_selected:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player1_selected:getWidth()/2, self.animations.player1_selected:getHeight()/2)
            else
                self.animations.player1:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player1:getWidth()/2, self.animations.player1:getHeight()/2)
            end
            if self.selection1 and self.selection1_timer < 0.4 then
                self.animations.selection:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.selection:getWidth()/2, self.animations.selection:getHeight()/2)
            elseif self.selection1_timer > 0.4 then
                self.selection1 = false
                self.selection1_timer = 0
            end
        elseif i == self.player2 then
            if self.selected2 then
                self.animations.player2_selected:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player2_selected:getWidth()/2, self.animations.player2_selected:getHeight()/2)
            else
                self.animations.player2:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.player2:getWidth()/2, self.animations.player2:getHeight()/2)
            end
            if self.selection2 and self.selection2_timer < 0.4 then
                self.animations.selection:draw(x0+(i-1)*spacing, y0, 0, scale, scale, self.animations.selection:getWidth()/2, self.animations.selection:getHeight()/2)
            elseif self.selection2_timer > 0.4 then
                self.selection2 = false
                self.selection2_timer = 0
            end
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
    self.animations[self.chars[self.player2]].idle:draw(WindowWidth/GlobalScale-xchar, ychar, 0, -scale, scale, self.chars_spacing[self.player2], self.animations[self.chars[self.player2]].idle:getHeight()/2)
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
    if not self.selected1 then
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
    end
    if not self.selected2 then
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
    end
    if self.move then
        self.move_timer = self.move_timer + dt
        if self.move_timer > 0.3 then
            self.move_timer = 0
            self.move = false
        end
    end
    if self.selection1 then
        self.selection1_timer = self.selection1_timer + dt
    end
    if self.selection2 then
        self.selection2_timer = self.selection2_timer + dt
    end
end

function pickFighterScene:selectCharacter()
    if ButtonsPressed[1]["a"] == true then
        self.selection1 = true
        self.selected1 = true
        self.animations.selection:setFrame(1)
        self.animations.selection:play()
    end
    if ButtonsPressed[2]["a"] == true then
        self.selection2 = true
        self.selected2 = true
        self.animations.selection:setFrame(1)
        self.animations.selection:play()
    end
    if ButtonsPressed[1]["b"] == true then
        self.selected1 = false
    end
    if ButtonsPressed[2]["b"] == true then
        self.selected2 = false
    end
end

function pickFighterScene:incrementTimers(dt)
    self.delay_timer = self.delay_timer + dt
    if self.delay_timer > 0.25 then
        self.delay = false
    end
end

function pickFighterScene:processDelay()
    if self.delay then
        self.selected1 = false
        self.selected2 = false
        ResetInputs()
    end
end

function ResetInputs()
    KeysPressed = {}
    ButtonsPressed = {}
    ButtonsPressed[1] = {}
    ButtonsPressed[2] = {}
    AxisMoved = {}
    AxisMoved[1] = {}
    AxisMoved[2] = {}
end

return pickFighterScene