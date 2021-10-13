local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local titleScene = scene:new("titleScene")

function titleScene:load()
    self.SpriteSheet = love.graphics.newImage("assets/ui/title_screen.png")
    self.SpriteSheetMeta = "assets/ui/title_screen.json"
    self.animation = peachy.new(self.SpriteSheetMeta, self.SpriteSheet, "Idle")
    self.startInstructions = {
        text = "Press [enter] to start!",
    }
end

function titleScene:update(dt, gameState)
    self.animation:update(dt)

    if love.keyboard.isDown("return") then
        gameState:setFightScene()
    end
end

function titleScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    self.animation:draw()
    love.graphics.pop()
end

return titleScene