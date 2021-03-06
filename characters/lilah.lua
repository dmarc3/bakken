local function hitbox(xDir)
    return {
		0, 0,
		13*xDir, -14,
		18*xDir, -6,
		18*xDir, 0,
		12*xDir, 7,
		8*xDir, 10
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
	xorigin = 21,
	yorigin = 18,
	body_width_pad = 0.3,
	body_height_pad = 0.75,
	x_shift_pad = 0.5,
	idle_duration = 0.6,
	attack_1_duration = 0.45,
	attack_damage = 7,
	jump_duration = 0.5,
	airborne_duration = 0.8,
	land_duration = 0.15,
	damage_duration = 0.5,
	block_start_dur = 0.45,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 21},
		f2 = {x = 21},
		f3 = {x = 21},
		f4 = {x = 21}
	},
	a1 = {
		f1 = {dx = 0, hit = false},
	    f2 = {dx = -2, hit = false},
	    f3 = {dx = 0, hit = false},
	    f4 = {dx = 4, hit = true},
	    f5 = {dx = 0, hit = false},
	    f6 = {dx = -2, hit = false},
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
