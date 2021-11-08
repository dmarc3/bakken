local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local titleScene = scene:new("titleScene")

function titleScene:load()
    love.graphics.clear()
    self.BG_SpriteSheet = love.graphics.newImage("assets/ui/title_screen.png")
    self.BG_SpriteSheetMeta = "assets/ui/title_screen.json"
    self.title = {}
    self.title.image = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "Idle")
    self.title.x = -WindowWidth/GlobalScale
    self.phrase = {}
    self.phrase[1] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "draw")
    self.phrase[2] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "your")
    self.phrase[3] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "weapon")
    self.phrase.delay = {}
    self.phrase.delay[1] = 0.5
    self.phrase.delay[2] = 1.0
    self.phrase.delay[3] = 1.5
    self.start_timer = false
    self.timer = 0.0
    self.interact = false
    self.PB_SpriteSheet = love.graphics.newImage("assets/ui/press_button.png")
    self.PB_SpriteSheetMeta = "assets/ui/press_button.json"
    self.press_button = peachy.new(self.PB_SpriteSheetMeta, self.PB_SpriteSheet, "Idle")
end

function titleScene:update(dt, gameState)
    if not self.interact then
        ResetInputs()
    end
    self:updateTitle(dt)
    for i = 1, 3 do
        self.phrase[i]:update(dt)
    end
    self.press_button:update(dt)

    if next(KeysPressed) ~= nil then
        gameState:setPickFighterScene()
    end
    if next(ButtonsPressed[1]) ~= nil then
        gameState:setPickFighterScene()
    end
    self:incrementTimers(dt)
end

function titleScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0, 1.0)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 50, WindowWidth/GlobalScale, 50)
    love.graphics.setColor(1, 1, 1, 1)
    self.title.image:draw(self.title.x, 0)
    for i = 1, 3 do
        if self.timer > self.phrase.delay[i] then
            self.phrase[i]:draw()
        end
    end
    if self.timer > self.phrase.delay[3] + 0.5 then
        self.press_button:draw(WindowWidth/GlobalScale/2, WindowHeight/GlobalScale*0.8, 0, 1, 1, self.press_button:getWidth()/2, self.press_button:getHeight()/2)
        self.interact = true
    end
    love.graphics.pop()
end

function titleScene:updateTitle(dt)
    self.title.image:update(dt)
    if self.title.x < 0 then
        self.title.x = self.title.x + 5
    else
        self.start_timer = true
    end
end

function titleScene:incrementTimers(dt)
    if self.start_timer then
        self.timer = self.timer + dt
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

return titleScene