local function hitbox(xDir)
	return {
		0, 0,
	    -12*xDir, 0,
	    -10*xDir, -8,
	    0, -10,
		12*xDir, -6,
	    16*xDir, 0,
		16*xDir, 9,
	    12*xDir, 13
	}
end

local function hurtbox()
	return {
		-2, 12,
		-6, 11,
		-6, -11,
		6, -11,
		6, 11,
		2, 12
	}
end


local sfx_pitch  =  "1"

return {
	xorigin = 15,
	yorigin = 25,
	body_width_pad = 0.3333333333,
	body_height_pad = 0.5897,
	x_shift_pad = 0.585,
	idle_duration = 0.6,
	attack_1_duration = 0.525,
	attack_damage = 9,
	jump_duration = 0.5,
	airborne_duration = 0.8,
	land_duration = 0.15,
	damage_duration = 0.5,
	block_start_dur = 0.40,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 15},
		f2 = {x = 15}
	},
	a1 = {
		f1 = {dx = 0,hit = false},
	    f2 = {dx = 0,hit = false},
	    f3 = {dx = 0,hit = false},
	    f4 = {dx = 0,hit = true},
	    f5 = {dx = 0,hit = false},
	    f6 = {dx = 0,hit = true},
	    f7 = {dx = 0,hit = false},
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
		f1 = {x = 16},
		f2 = {x = 16},
		f3 = {x = 16},
		f4 = {x = 16},
		f5 = {x = 16},
		f6 = {x = 16}
	},
	block_start = {
		f1 = 12,
		f2 = 12,
		f3 = 12
	},
	block = {f1 = 12},
	block_end = {
		f1 = 12,
		f2 = 12,
		f3 = 12
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