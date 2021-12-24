local function hitbox(xDir)
	return {
		9*xDir, 0,
        14*xDir, 4,
        20*xDir, 6,
	       xDir, 0,
        23*xDir, -4,
        20*xDir, -8,
        13*xDir, -7,
        9*xDir, -4
	}
end

local function hurtbox()
	return {-2, 14,
			-6, 13,
			-6, 13,
			-6, -12,
			6, -12,
			6, 13,
			2, 14}
end

local sfx_pitch = "1.25"

return {
	xorigin = 21,
	yorigin = 31,
	body_width_pad = 0.375,
	body_height_pad = 0.45,
	x_shift_pad = 0.5,
	idle_duration = 0.6,
	attack_1_duration = 1.16,
	jump_duration = 0.4,
	airborne_duration = 0.8,
	land_duration = 0.2,
	damage_duration = 0.5,
	block_start_dur = 0.40,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 21},
		f2 = {x = 21},
		f3 = {x = 21},
		f4 = {x = 21}
	},
	a1 = {
		f1 = {dx = 0,hit = false},
	    f2 = {dx = -1,hit = false},
	    f3 = {dx = 0,hit = false},
	    f4 = {dx = 0,hit = false},
	    f5 = {dx = 0,hit = true},
	    f6 = {dx = 0,hit = false},
	    f7 = {dx = 1,hit = false},
		hitbox = {
			vertices = hitbox,
			body = nil,
			shape = nil,
			fixture = nil
		},
		hurtbox = {
			vertices = hurtbox
		}
	},
	walk = {
		f1 = {x = 21},
		f2 = {x = 21},
		f3 = {x = 21},
		f4 = {x = 21},
		f5 = {x = 21},
		f6 = {x = 21}
	},
	block_start = {
		f1 = 21,
		f2 = 21,
		f3 = 21
	},
	block = {f1 = 21},
	block_end = {
		f1 = 21,
		f2 = 21,
		f3 = 21
	},
	sfx = {
		attack_1 = {
			love.audio.newSource(
				"assets/audio/sfx/attack/attack_1_p" .. sfx_pitch .. ".ogg", "static"
			),
			love.audio.newSource(
				"assets/audio/sfx/attack/yowl.ogg", "static"
			),
		},
        block = love.audio.newSource(
            "assets/audio/sfx/block/block_p" .. sfx_pitch .. ".ogg", "static"
        ),
        single_jump = love.audio.newSource(
            "assets/audio/sfx/jump/single_jump_p" .. sfx_pitch .. ".ogg", "static"
        ),
        double_jump = love.audio.newSource(
            "assets/audio/sfx/jump/double_jump_p" .. sfx_pitch .. ".ogg", "static"
        ),
        kneel = love.audio.newSource(
            "assets/audio/sfx/kneel/kneel_breath_p" .. sfx_pitch .. ".ogg", "static"
        ),
        knockout = love.audio.newSource(
            "assets/audio/sfx/knockout/knockout_p" .. sfx_pitch .. ".ogg", "static"
        )
	}
}
