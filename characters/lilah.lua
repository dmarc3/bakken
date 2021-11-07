function lilahHitbox(xDir)
    return {0, 0,
            13*xDir, -14,
            18*xDir, -6,
	        18*xDir, 0,
	        12*xDir, 7,
            8*xDir, 10}
end

function lilahHurtbox()
	return {-2, 14,
			-6, 13,
			-6, 13,
			-6, -12,
			6, -12,
			6, 13,
			2, 14}
		end

xorigin=21
body_width_pad=0.3
body_height_pad=0.75
x_shift_pad=0.5
idle_duration=0.6
attack_1_duration=0.9
jump_duration=0.5
airborne_duration=0.8
land_duration=0.15
damage_duration=0.5
block_start_dur=0.45
block_end_dur=0.45

idle={f1={x=21},
	  f2={x=21},
	  f3={x=21},
	  f4={x=21}}
a1={f1={dx=0,hit=false},
    f2={dx=-2,hit=false},
    f3={dx=0,hit=false},
    f4={dx=4,hit=true},
    f5={dx=0,hit=false},
    f6={dx=-2,hit=false},
	hitbox={vertices=lilahHitbox(1),
			body=nil,
			shape=nil,
			fixture=nil}}
walk={f1={x=21},
	  f2={x=21},
	  f3={x=21},
	  f4={x=21},
	  f5={x=21},
	  f6={x=21}}
block_start={f1=21,
		     f2=21,
			 f3=21}
block={f1=21}
block_end={f1=21,
		   f2=21,
		   f3=21}


