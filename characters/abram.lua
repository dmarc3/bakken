local function hitbox(xDir)
	return {
	    -6*xDir, 0,
	    -4*xDir, -15,
	    0, -16,
		12*xDir, -13,
		17*xDir, -6,
	    20*xDir, 0,
		20*xDir, 9,
	    16*xDir, 13
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

return {
	xorigin = 27,
	yorigin = 23,
	body_width_pad = 0.3333333333,
	body_height_pad = 0.5897,
	x_shift_pad = 0.585,
	idle_duration = 0.8,
	attack_1_duration = 0.9,
	jump_duration = 0.5,
	airborne_duration = 0.8,
	land_duration = 0.5,
	damage_duration = 0.5,
	block_start_dur = 0.375,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 27},
		f2 = {x = 27}
	},
	a1 = {
		f1 = {dx = 0,hit = false},
	    f2 = {dx = 0,hit = false},
	    f3 = {dx = 0,hit = false},
	    f4 = {dx = 0,hit = false},
	    f5 = {dx = 0,hit = false},
	    f6 = {dx = 0,hit = true},
	    f7 = {dx = 0,hit = false},
	    f8 = {dx = 0,hit = false},
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
		f1 = {x = 27},
		f2 = {x = 27},
		f3 = {x = 27},
		f4 = {x = 27},
		f5 = {x = 27},
		f6 = {x = 27}
	},
	block_start = {
		f1 = 27,
		f2 = 27,
		f3 = 27
	},
	block = {f1 = 12},
	block_end = {
		f1 = 27,
		f2 = 27,
		f3 = 27
	},
	sfx_pitch  =  "1"
}