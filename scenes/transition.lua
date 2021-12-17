local peachy = require("3rd/peachy/peachy")

-- The transition interface. A transition must implement
-- the standard love callbacks.

Transition = {}
Transition.__index = Transition

function Transition:load()
    local spritesheet = love.graphics.newImage("assets/ui/transitions.png")
    local asepriteMeta = "assets/ui/transitions.json"
    self.out = peachy.new(asepriteMeta, spritesheet, "out")
    self.inn = peachy.new(asepriteMeta, spritesheet, "in")
    self.bakken = peachy.new(asepriteMeta, spritesheet, "bakken")
end

function Transition:draw()
    self.inn:draw(0, 0)
    -- love.graphics.setColor(1.0, 0.0, 0.0, 1.0)
    -- love.graphics.rectangle("fill", 50, 50, 100, 100)
    -- love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    -- assert(false, "A Transition must implement draw, accepting scaling parameters sx, sy")
end

function Transition:update(dt)
    self.out:update(dt)
    self.inn:update(dt)
    self.bakken:update(dt)
end

return Transition