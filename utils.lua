-- miscellaneous utility functions

local function clamp(x, min, max)
    -- ensure x is greater than or equal to min and less than or equal to max
    return x < min and min or x > max and max or x
end

local function floor(x, min)
    -- ensure x is greater than or equal to min
    return x < min and min or x
end

local function ceil(x, max)
    -- ensure x is less than or equal to max
    return x > max and max or x
end

local function snplay(source)
    -- "stop and play"
    -- check if audio is playing, if so, stop it and play from start
    -- useful for sound effects that happen quickly and repeatedly
    -- source from love.audio.newSource
    if source:isPlaying() then
        source:stop()
        source:play()
    else
        source:play()
    end
end

local function pplay(source)
    -- "polite play"
    -- only play clip if the clip in question isn't already playing
    -- useful for music, and other clips that should always finish
    if not source:isPlaying() then
        source:play()
    end
end

return {
    clamp = clamp,
    ceil = ceil,
    floor = floor,
    snplay = snplay,
    pplay = pplay,
}