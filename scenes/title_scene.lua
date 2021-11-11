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
    self:loadChars("drew", "lilah")

end

function titleScene:loadChars(p1, p2)
    -- Load Character 1
    self.chars = {}
    self.chars[1] = {}
    self.chars[1].name = p1
    self.chars[1].spritesheet = love.graphics.newImage("assets/Characters/"..self.chars[1].name..".png")
    self.chars[1].asepriteMeta = "assets/Characters/"..self.chars[1].name..".json"
    self.chars[1].animation = {
        sheathed = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "sheathed"),
        idle = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "idle"),
        walk = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "walk forward"),
        jump = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "jump"),
        airborne = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "airborne"),
        land = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "land"),
        hit = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "hit"),
        block = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "block"),
        block_start = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "block start"),
        block_end = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "block end"),
        a1 = peachy.new(self.chars[1].asepriteMeta, self.chars[1].spritesheet, "attack 1"),
    }
    self.chars[1].x = WindowWidth/GlobalScale*0.1
    self.chars[1].y = WindowHeight/GlobalScale*0.8
    self.chars[1].xShift = 0
    self.chars[1].xDir = 1
    self.chars[1].animationName = "sheathed"
    require("characters/"..self.chars[1].name)
    self.chars[1].xorigin = xorigin
    self.chars[1].block_start_dur = block_start_dur
    self.chars[1].block_end_dur = block_end_dur
    self.chars[1].body_width_pad = body_width_pad
    self.chars[1].body_height_pad = body_height_pad
    self.chars[1].x_shift_pad = x_shift_pad
    self.chars[1].idle_duration = idle_duration
    self.chars[1].attack_1_duration = attack_1_duration
    self.chars[1].jump_duration = jump_duration
    self.chars[1].airborne_duration = airborne_duration
    self.chars[1].land_duration = land_duration
    self.chars[1].damage_duration = damage_duration
    self.chars[1].idle = idle
    self.chars[1].a1 = a1
    self.chars[1].walk = walk
    self.chars[1].block_start = block_start
    self.chars[1].block = block
    self.chars[1].block_end = block_end
    -- Load Character 2
    self.chars[2] = {}
    self.chars[2].name = p2
    self.chars[2].spritesheet = love.graphics.newImage("assets/Characters/"..self.chars[2].name..".png")
    self.chars[2].asepriteMeta = "assets/Characters/"..self.chars[2].name..".json"
    self.chars[2].animation = {
        idle = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "idle"),
        walk = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "walk forward"),
        jump = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "jump"),
        airborne = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "airborne"),
        land = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "land"),
        hit = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "hit"),
        block = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "block"),
        block_start = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "block start"),
        block_end = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "block end"),
        a1 = peachy.new(self.chars[2].asepriteMeta, self.chars[2].spritesheet, "attack 1"),
    }
    self.chars[2].x = WindowWidth/GlobalScale*0.2
    self.chars[2].y = WindowHeight/GlobalScale*0.8
    self.chars[2].xShift = 0
    self.chars[2].xDir = -1
    self.chars[2].animationName = "idle"
    require("characters/"..self.chars[2].name)
    self.chars[2].xorigin = xorigin
    self.chars[2].block_start_dur = block_start_dur
    self.chars[2].block_end_dur = block_end_dur
    self.chars[2].body_width_pad = body_width_pad
    self.chars[2].body_height_pad = body_height_pad
    self.chars[2].x_shift_pad = x_shift_pad
    self.chars[2].idle_duration = idle_duration
    self.chars[2].attack_1_duration = attack_1_duration
    self.chars[2].jump_duration = jump_duration
    self.chars[2].airborne_duration = airborne_duration
    self.chars[2].land_duration = land_duration
    self.chars[2].damage_duration = damage_duration
    self.chars[2].idle = idle
    self.chars[2].a1 = a1
    self.chars[2].walk = walk
    self.chars[2].block_start = block_start
    self.chars[2].block = block
    self.chars[2].block_end = block_end
end

function titleScene:update(dt, gameState)
    if not self.interact then
        ResetInputs()
    end
    self:updateTitle(dt)
    self:updateChars(dt)
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

function titleScene:updateChars(dt)
    self.chars[1].animation[self.chars[1].animationName]:update(dt)
    self.chars[2].animation[self.chars[2].animationName]:update(dt)
end

function titleScene:draw(sx, sy)
    love.graphics.push()
    love.graphics.scale(sx, sy)
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0, 1.0)
    self.title.image:draw(self.title.x, 0)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 0, WindowHeight/GlobalScale - 50, WindowWidth/GlobalScale, 50)
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, 3 do
        if self.timer > self.phrase.delay[i] then
            self.phrase[i]:draw()
        end
    end
    if self.timer > self.phrase.delay[3] + 0.5 then
        self.press_button:draw(WindowWidth/GlobalScale/2, WindowHeight/GlobalScale*0.8, 0, 1, 1, self.press_button:getWidth()/2, self.press_button:getHeight()/2)
        self.interact = true
    end
    self:drawChars()
    love.graphics.pop()
end

function titleScene:drawChars()
    self.chars[1].animation[self.chars[1].animationName]:draw(self.chars[1].x,
                                                              self.chars[1].y,
                                                              0,
                                                              self.chars[1].xDir,
                                                              1,
                                                              self.chars[1].xorigin,
                                                              self.chars[1].animation[self.chars[1].animationName]:getHeight()/2)
    self.chars[2].animation[self.chars[2].animationName]:draw(self.chars[2].x,
                                                              self.chars[2].y,
                                                              0,
                                                              self.chars[2].xDir,
                                                              1,
                                                              self.chars[2].xorigin,
                                                              self.chars[2].animation[self.chars[2].animationName]:getHeight()/2)
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