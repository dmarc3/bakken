local peachy = require"3rd/peachy/peachy"
local scene = require"scene"

local titleScene = scene:new("titleScene")

function titleScene:load()
    print("Loading titleScene")
    love.graphics.clear()
    self.BG_SpriteSheet = love.graphics.newImage("assets/ui/title_screen.png")
    self.BG_SpriteSheetMeta = "assets/ui/title_screen.json"
    self.title = {}
    self.title.image = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "Idle")
    self.title.x = -WindowWidth/GlobalScale
    self.lightning = {}
    self.lightning.image = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "lightning")
    self.lightning.image:pause()
    self.lightning.timer = 0.0
    self.lightning.duration = 1.0
    self.lightning.alpha = 1.0
    self.lightning.delay = 4.35
    self.lightning.trigger = false
    self.flash = false
    self.phrase = {}
    self.phrase[1] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "draw")
    self.phrase[2] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "your")
    self.phrase[3] = peachy.new(self.BG_SpriteSheetMeta, self.BG_SpriteSheet, "weapon")
    self.phrase.delay = {1.1, 2.1, 3.1, 4.3}
    self.start_timer = false
    self.timer = 0.0
    self.interact = false
    self.PB_SpriteSheet = love.graphics.newImage("assets/ui/press_button.png")
    self.PB_SpriteSheetMeta = "assets/ui/press_button.json"
    self.press_button = peachy.new(self.PB_SpriteSheetMeta, self.PB_SpriteSheet, "Idle")
    local chars = {"drew", "lilah", "sam", "miller", "lilah", "abram"}
    local x = {WindowWidth/GlobalScale*0.1, WindowWidth/GlobalScale*0.25, WindowWidth/GlobalScale*0.4, WindowWidth/GlobalScale*0.55, WindowWidth/GlobalScale*0.75, WindowWidth/GlobalScale*0.9}
    self:loadChars(chars, x)
    self.music = love.audio.newSource("assets/audio/music/title.ogg", "static")
    self.sfx_start = love.audio.newSource("assets/audio/sfx/ui/accept_all.ogg", "static")
    self:loadCredits()
    Transition_In = require"scenes/transition_in"
    Transition_In:load("setPickFighterScene")
end

function titleScene:loadCredits()
    self.credit_delay = 8.0
    self.credit_timer = 0.0
    self.credits_x = 0.2
    self.credits_y = 0.35
    self.credits_ascend = true
    self.credits = {}
    local spritesheet = love.graphics.newImage("assets/ui/credits.png")
    local asepriteMeta = "assets/ui/credits.json"
    self.credits.marcus = {}
    self.credits.marcus.image = peachy.new(asepriteMeta, spritesheet, "marcus")
    self.credits.marcus.alpha = 0.0
    self.credits.erik = {}
    self.credits.erik.image = peachy.new(asepriteMeta, spritesheet, "erik")
    self.credits.erik.alpha = 0.0
    self.credits.rusty = {}
    self.credits.rusty.image = peachy.new(asepriteMeta, spritesheet, "rusty")
    self.credits.rusty.alpha = 0.0
    self.credits.madeleine = {}
    self.credits.madeleine.image = peachy.new(asepriteMeta, spritesheet, "madeleine")
    self.credits.madeleine.alpha = 0.0
    self.credits.katherine = {}
    self.credits.katherine.image = peachy.new(asepriteMeta, spritesheet, "katherine")
    self.credits.katherine.alpha = 0.0
    self.credits.made = {}
    self.credits.made.image = peachy.new(asepriteMeta, spritesheet, "made")
    self.credits.made.alpha = 0.0
    self.love_logo = love.graphics.newImage("assets/ui/Love-logo.png")
end

function titleScene:loadChars(chars, x)
    -- Load Characters
    self.chars = {}
    for i, char in ipairs(chars) do
        self.chars[i] = {}
        self.chars[i].name = char
        self.chars[i].spritesheet = love.graphics.newImage("assets/characters/"..self.chars[i].name..".png")
        self.chars[i].asepriteMeta = "assets/characters/"..self.chars[i].name..".json"
        -- sheathed = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "sheathed"),
        self.chars[i].animation = {
            idle = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "idle"),
            walk = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "walk_forward"),
            jump = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "jump"),
            airborne = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "airborne"),
            land = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "land"),
            hit = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "hit"),
            block = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "block"),
            block_start = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "block start"),
            block_end = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "block end"),
            a1 = peachy.new(self.chars[i].asepriteMeta, self.chars[i].spritesheet, "attack 1"),
        }
        self.chars[i].x = x[i]
        self.chars[i].y = WindowHeight/GlobalScale*0.8
        self.chars[i].xShift = 0
        self.chars[i].xDir = 1
        self.chars[i].animationName = "idle"
        self.chars[i].charsheet = require("characters/"..self.chars[i].name)
        self.chars[i].xorigin = self.chars[i].charsheet.xorigin
        self.chars[i].yorigin = self.chars[i].charsheet.yorigin
        self.chars[i].block_start_dur = self.chars[i].charsheet.block_start_dur
        self.chars[i].block_end_dur = self.chars[i].charsheet.block_end_dur
        self.chars[i].body_width_pad = self.chars[i].charsheet.body_width_pad
        self.chars[i].body_height_pad = self.chars[i].charsheet.body_height_pad
        self.chars[i].x_shift_pad = self.chars[i].charsheet.x_shift_pad
        self.chars[i].idle_duration = self.chars[i].charsheet.idle_duration
        self.chars[i].attack_i_duration = self.chars[i].charsheet.attack_1_duration
        self.chars[i].jump_duration = self.chars[i].charsheet.jump_duration
        self.chars[i].airborne_duration = self.chars[i].charsheet.airborne_duration
        self.chars[i].land_duration = self.chars[i].charsheet.land_duration
        self.chars[i].damage_duration = self.chars[i].charsheet.damage_duration
        self.chars[i].idle = self.chars[i].charsheet.idle
        self.chars[i].a1 = self.chars[i].charsheet.a1
        self.chars[i].walk = self.chars[i].charsheet.walk
        self.chars[i].block_start = self.chars[i].charsheet.block_start
        self.chars[i].block = self.chars[i].charsheet.block
        self.chars[i].block_end = self.chars[i].charsheet.block_end
    end
end

function titleScene:update(dt, gameState)
    self:updateCredits(dt)
    if self.title.x == 0 and not self.music:isPlaying() and self.credit_timer >= self.credit_delay then
        self.music:play()
    end
    if not self.interact then
        ResetInputs()
    end
    self:updateTitle(dt)
    self:updateLightning(dt)
    self:updateChars(dt)
    for i = 1, 3 do
        self.phrase[i]:update(dt)
    end
    if self.timer > self.phrase.delay[4] then
      self.press_button:update(dt)
    end

    if next(KeysPressed) ~= nil then
        self.sfx_start:play()
        Transition_In.transition_in = true
    end
    if next(ButtonsPressed[1]) ~= nil then
        self.sfx_start:play()
        Transition_In.transition_in = true
    end
    self:incrementTimers(dt)
    if Transition_In.transition_in then
        Transition_In:update(dt, gameState, self.music)
    end
end

function titleScene:updateCredits(dt)
    local dt_delay = 1.0
    local dt_appear = self.credit_delay - dt_delay
    local rate = 1.0
    -- Phase credits in
    if self.credits_ascend then
        if self.credits.made.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
        elseif self.credits.marcus.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
        elseif self.credits.erik.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha + rate*dt
        elseif self.credits.rusty.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha + rate*dt
            self.credits.rusty.alpha = self.credits.rusty.alpha + rate*dt
        elseif self.credits.madeleine.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha + rate*dt
            self.credits.rusty.alpha = self.credits.rusty.alpha + rate*dt
            self.credits.madeleine.alpha = self.credits.madeleine.alpha + rate*dt
        elseif self.credits.katherine.alpha < 0.5 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha + rate*dt
            self.credits.rusty.alpha = self.credits.rusty.alpha + rate*dt
            self.credits.madeleine.alpha = self.credits.madeleine.alpha + rate*dt
            self.credits.katherine.alpha = self.credits.katherine.alpha + rate*dt
        elseif self.credits.katherine.alpha < 1.0 then
            self.credits.made.alpha = self.credits.made.alpha + rate*dt
            self.credits.marcus.alpha = self.credits.marcus.alpha + rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha + rate*dt
            self.credits.rusty.alpha = self.credits.rusty.alpha + rate*dt
            self.credits.madeleine.alpha = self.credits.madeleine.alpha + rate*dt
            self.credits.katherine.alpha = self.credits.katherine.alpha + rate*dt
        end
        -- Cap alpha at 1.0
        if self.credits.made.alpha > 1.0 then self.credits.made.alpha = 1.0 end
        if self.credits.marcus.alpha > 1.0 then self.credits.marcus.alpha = 1.0 end
        if self.credits.erik.alpha > 1.0 then self.credits.erik.alpha = 1.0 end
        if self.credits.rusty.alpha > 1.0 then self.credits.rusty.alpha = 1.0 end
        if self.credits.madeleine.alpha > 1.0 then self.credits.madeleine.alpha = 1.0 end
        if self.credits.katherine.alpha > 1.0 then self.credits.katherine.alpha = 1.0 end
        local logic = self.credits.made.alpha == 1.0 
        logic = logic and self.credits.marcus.alpha == 1.0 
        logic = logic and self.credits.erik.alpha == 1.0
        logic = logic and self.credits.rusty.alpha == 1.0
        logic = logic and self.credits.madeleine.alpha == 1.0
        logic = logic and self.credits.katherine.alpha == 1.0
        if logic then
            self.credits_ascend = false
        end
    end
    
    -- Phase credits out
    if not self.credits_ascend then
        if self.credit_timer > dt_appear then
            self.credits.marcus.alpha = self.credits.marcus.alpha - rate*dt
            self.credits.erik.alpha = self.credits.erik.alpha - rate*dt
            self.credits.rusty.alpha = self.credits.rusty.alpha - rate*dt
            self.credits.madeleine.alpha = self.credits.madeleine.alpha - rate*dt
            self.credits.katherine.alpha = self.credits.katherine.alpha - rate*dt
            self.credits.made.alpha = self.credits.made.alpha - rate*dt
        end
    end

    self.credits.marcus.image:update(dt)
    self.credits.erik.image:update(dt)
    self.credits.rusty.image:update(dt)
    self.credits.madeleine.image:update(dt)
    self.credits.katherine.image:update(dt)
end

function titleScene:updateChars(dt)
    for i = 1, #self.chars do
        self.chars[i].animation[self.chars[i].animationName]:update(dt)    
    end
end

function titleScene:updateTitle(dt)
    self.title.image:update(dt)
    if self.credit_timer >= self.credit_delay then
        if self.title.x < 0 then
            self.title.x = self.title.x + 5
        else
            self.start_timer = true
        end
    end
end

function titleScene:updateLightning(dt)
    if self.lightning.trigger then
        local old_frame = self.lightning.image:getFrame()
        self.lightning.image:update(dt)
        local new_frame = self.lightning.image:getFrame()
        if new_frame < old_frame then
            self.lightning.image:setFrame(4)
        end
        if self.lightning.timer < 0.2 then
            self.lightning.alpha = 1.0
        else
            self.lightning.alpha = 1.0 - 1.2*(self.lightning.timer / self.lightning.duration)
        end
    end
end

function titleScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.05, 1.0)
    self:drawCredits()
    self:drawLightning()
    self.title.image:draw(self.title.x, -WindowHeight/GlobalScale*0.1)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale*0.8, WindowWidth/GlobalScale, WindowHeight/GlobalScale)
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, 3 do
        if self.timer > self.phrase.delay[i] then
            self.phrase[i]:draw(0.0, -WindowHeight/GlobalScale*0.1)
        end
    end
    if self.interact then
        self.press_button:draw(WindowWidth/GlobalScale/2, WindowHeight/GlobalScale*0.6, 0, 1, 1, self.press_button:getWidth()/2, self.press_button:getHeight()/2)
    end
    self:drawChars()
    if self.flash then
        self:drawFlash()
    end
    if Transition_In.transition_in then
        Transition_In:draw()
    end
    love.graphics.pop()
end

function titleScene:drawCredits()
    local dx = 0.037
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.made.alpha)
    self.credits.made.image:draw(WindowWidth/GlobalScale*(self.credits_x-0.15), WindowHeight/GlobalScale*(self.credits_y-5*dx), 0, 0.75, 0.75)
    love.graphics.draw(self.love_logo, WindowWidth/GlobalScale*(self.credits_x+0.153), WindowHeight/GlobalScale*(self.credits_y-6*dx), 0, 0.1, 0.1)
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.marcus.alpha)
    self.credits.marcus.image:draw(WindowWidth/GlobalScale*self.credits_x, WindowHeight/GlobalScale*self.credits_y, 0, 0.3, 0.3)
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.erik.alpha)
    self.credits.erik.image:draw(WindowWidth/GlobalScale*self.credits_x, WindowHeight/GlobalScale*(self.credits_y+dx), 0, 0.3, 0.3)
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.rusty.alpha)
    self.credits.rusty.image:draw(WindowWidth/GlobalScale*self.credits_x, WindowHeight/GlobalScale*(self.credits_y+2*dx), 0, 0.3, 0.3)
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.madeleine.alpha)
    self.credits.madeleine.image:draw(WindowWidth/GlobalScale*self.credits_x, WindowHeight/GlobalScale*(self.credits_y+3*dx), 0, 0.3, 0.3)
    love.graphics.setColor(1.0, 1.0, 1.0, self.credits.katherine.alpha)
    self.credits.katherine.image:draw(WindowWidth/GlobalScale*self.credits_x, WindowHeight/GlobalScale*(self.credits_y+4*dx), 0, 0.3, 0.3)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

function titleScene:drawChars()
    local counter = 1
    for i = 1, #self.chars do
        if self.timer > self.phrase.delay[counter] then
            self.chars[i].animation[self.chars[i].animationName]:draw(self.chars[i].x,
                                                                    self.chars[i].y,
                                                                    0,
                                                                    2*math.fmod(i,2)-1,
                                                                    1,
                                                                    self.chars[i].xorigin,
                                                                    self.chars[i].animation[self.chars[i].animationName]:getHeight()-self.chars[i].yorigin)
        end
        if math.fmod(i, 2) ~= 1 then
            counter = counter + 1
        end
    end
end

function titleScene:drawLightning()
    if self.lightning.trigger then
        love.graphics.setColor(1.0, 1.0, 1.0, self.lightning.alpha)
        self.lightning.image:draw(0, 0)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end
end

function titleScene:drawFlash()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, WindowWidth/GlobalScale, WindowHeight/GlobalScale)
end

function titleScene:incrementTimers(dt)
    self.credit_timer = self.credit_timer + dt
    local previous_trigger = self.lightning.trigger
    if self.start_timer then
        self.timer = self.timer + dt
    end
    if self.lightning.trigger or self.lightning.timer > 0.0 then
        self.lightning.timer = self.lightning.timer + dt
    end
    if self.timer > self.phrase.delay[4] then
        if self.lightning.timer == 0.0 then
            self.lightning.trigger = true
            self.lightning.image:setFrame(1)
            self.lightning.image:play()
        elseif self.lightning.timer > self.lightning.delay then
            self.lightning.timer = 0.0
            self.lightning.trigger = true
            self.lightning.image:setFrame(1)
            self.lightning.image:play()
        elseif self.lightning.timer > self.lightning.duration then
            self.lightning.trigger = false
        end
        self.interact = true
        for i = 1, #self.chars do
            self.chars[i].animationName = "a1"
        end
    end
    local new_trigger = self.lightning.trigger
    if not previous_trigger and new_trigger then
        self.flash = true
    else
        self.flash = false
    end
    if Transition_In.transition_in then
        Transition_In.transition_timer = Transition_In.transition_timer + dt
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