local peachy = require("3rd/peachy/peachy")

-- The transition interface. A transition must implement
-- the standard love callbacks.

Transition_Out = {}
Transition_Out.__index = Transition_Out

function Transition_Out:load()
    local spritesheet = love.graphics.newImage("assets/ui/transition_out.png")
    local asepriteMeta = "assets/ui/transition_out.json"
    self.transition = {}
    self.transition.out = peachy.new(asepriteMeta, spritesheet, "out")
    local spritesheet = love.graphics.newImage("assets/ui/bakken.png")
    local asepriteMeta = "assets/ui/bakken.json"
    self.transition.bakken = peachy.new(asepriteMeta, spritesheet, "bakken")
    self.transition_out = true
    self.transition_timer = 0.0
    self.transition_duration = 1.80
    self.bakken_duration = self.transition_duration - 0.3
end

function Transition_Out:draw()
    if self.transition_out then
        self.transition.out:draw(0, 0)
        if self.transition_timer < self.bakken_duration then
            self.transition.bakken:draw(WindowWidth/GlobalScale*0.05, WindowHeight/GlobalScale*0.9, 0, 0.5, 0.5)
        end
    end
end

function Transition_Out:update(dt)
    if self.transition_timer > self.transition_duration then
        self.transition_out = false
    end
    self.transition.out:update(dt)
    self.transition.bakken:update(dt)
end

return Transition_Out