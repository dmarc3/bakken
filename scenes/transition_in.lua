local peachy = require("3rd/peachy/peachy")

-- The transition interface. A transition must implement
-- the standard love callbacks.

Transition_In = {}
Transition_In.__index = Transition_In

function Transition_In:load(next_scene)
    local spritesheet = love.graphics.newImage("assets/ui/transition_in.png")
    local asepriteMeta = "assets/ui/transition_in.json"
    self.transition = {}
    self.transition.inn = peachy.new(asepriteMeta, spritesheet, "in")
    local spritesheet = love.graphics.newImage("assets/ui/bakken.png")
    local asepriteMeta = "assets/ui/bakken.json"
    self.transition.bakken = peachy.new(asepriteMeta, spritesheet, "bakken")
    self.transition_in = false
    self.transition_timer = 0.0
    self.transition_duration = 1.74
    self.bakken_duration = 0.3
    self.next_scene = next_scene
end

function Transition_In:draw()
    self.transition.inn:draw(0, 0)
    if self.transition_timer > self.bakken_duration then
        self.transition.bakken:draw(WindowWidth/GlobalScale*0.05, WindowHeight/GlobalScale*0.9, 0, 0.5, 0.5)
    end
end

function Transition_In:update(dt, gameState, music)
    self.transition.inn:update(dt)
    self.transition.bakken:update(dt)
    if self.transition_timer > self.transition_duration then
        if music ~= nil then
            if music:isPlaying() then
                music:stop()
            end
        end
        print("loading from transition_in")
        gameState[self.next_scene](gameState)
        gameState.current:load(gameState)
    end
end

return Transition_In