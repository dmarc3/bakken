local function hitbox(xDir)
    return {
		0, 0,
		-12*xDir, -17,
		9*xDir, -14,
		20*xDir, 0,
		21*xDir, 13
	}
end

local function hurtbox ()
	return {-2, 14,
			-6, 13,
			-6, 13,
			-6, -12,
			6, -12,
			6, 13,
			2, 14}
end

local sfx_pitch = "1.15"

return {
	xorigin = 11,
	yorigin = 23,
	body_width_pad = 0.3,
	body_height_pad = 0.75,
	x_shift_pad = 0.5,
	idle_duration = 0.6,
	attack_1_duration = 0.5,
	attack_damage = 8,
	jump_duration = 0.5,
	airborne_duration = 0.8,
	land_duration = 0.15,
	damage_duration = 0.5,
	block_start_dur = 0.45,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 11},
		f2 = {x = 11}
	},
	a1 = {
		f1 = {dx = 0, hit = false},
	    f2 = {dx = 0, hit = false},
	    f3 = {dx = 0, hit = false},
	    f4 = {dx = 0, hit = true},
	    f5 = {dx = 0, hit = false},
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
		f1 = {x = 11},
		f2 = {x = 11},
		f3 = {x = 11},
		f4 = {x = 11},
		f5 = {x = 11},
		f6 = {x = 11}
	},
	block_start = {
		f1 = 11,
	    f2 = 11,
		f3 = 11
	},
	block = {f1 = 11},
	block_end = {
		f1 = 11,
		f2 = 11,
		f3 = 11
	},
	sfx = {
		attack_1 = {
			love.audio.newSource(
				"assets/audio/sfx/attack/attack_1_p" .. sfx_pitch .. ".ogg", "static"
			)
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
