local function hitbox(xDir)
	return {0, 0,
	        -8*xDir, -18,
	        8*xDir, -14,
	        21*xDir, -4,
	        21*xDir, 0,
	        17*xDir, 5,
	        8*xDir, 10,
	        -8*xDir, 13}
end

local function hurtbox()
	return {-2, 12,
			-6, 11,
			-6, -11,
			6, -11,
			6, 11,
			2, 12}
end

return {
	xorigin = 12,
	body_width_pad = 0.25,
	body_height_pad = 0.38,
	x_shift_pad = 0.585,
	idle_duration = 0.6,
	attack_1_duration = 1.16,
	jump_duration = 0.5,
	airborne_duration = 0.8,
	land_duration = 0.15,
	damage_duration = 0.5,
	block_start_dur = 0.40,
	block_end_dur = 0.45,
	idle = {
		f1 = {x = 12},
		f2 = {x = 12},
		f3 = {x = 12},
		f4 = {x = 12}
	},
	a1 = {
		f1 = {dx = 0,hit = false},
	    f2 = {dx = 4,hit = false},
	    f3 = {dx = 0,hit = false},
	    f4 = {dx = 0,hit = false},
	    f5 = {dx = 6,hit = true},
	    f6 = {dx = 0,hit = false},
	    f7 = {dx = -9,hit = false},
	    f8 = {dx = 0,hit = false},
	    f9 = {dx = -1,hit = false},
		hitbox = {
			vertices = hitbox(1),
			body = nil,
			shape = nil,
			fixture = nil
		},
		hurtbox = {
			vertices = hurtbox()
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
	sfx_pitch  =  "1"
}