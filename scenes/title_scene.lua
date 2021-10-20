local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local titleScene = scene:new("titleScene")

function titleScene:load()
    self.BG_SpriteSheet = love.graphics.newImage("assets/ui/title_screen.png")
    self.BG_SpriteSheetMeta = "assets/ui/title_screen.json"
    self.BG_animation = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "Idle")
    self.PB_SpriteSheet = love.graphics.newImage("assets/ui/press_button.png")
    self.PB_SpriteSheetMeta = "assets/ui/press_button.json"
    self.PB_animation = peachy.new(self.PB_SpriteSheetMeta, self.PB_SpriteSheet, "Idle")
end

function titleScene:update(dt, gameState)
    self.BG_animation:update(dt)
    self.PB_animation:update(dt)

    if next(KeysPressed) ~= nil then
        gameState:setFightScene()
    end
    if next(ButtonsPressed[1]) ~= nil then
        gameState:setFightScene()
    end
end

function titleScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self.BG_animation:draw()
    self.PB_animation:draw(WindowWidth/GlobalScale/2, WindowHeight/GlobalScale*0.8, 0, 1, 1, self.PB_animation:getWidth()/2, self.PB_animation:getHeight()/2)
    love.graphics.pop()
end

return titleScene