


--define the class
ACF_defineGunClass("R7", {
	spread = 5,
	name = "FFAR Pod (7-shot)",
	desc = "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 0.6,
	sound = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance = " ",
	soundNormal = " ",
	mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile5"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile6"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)},
		["missile7"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,0)}
	}
} )




nonsmoke = {SM = true, FL = true}

local rkdesc = "  Rockets give great firepower for light weight, but are less accurate."
local rackdesc = "  Racks and pods allow rapid rocket launches but can be detonated by the enemy. Racks need a refill crate to re-arm!"
local R7_MASS = 200




ACF_defineGun("40mmR7", { --id
	ent			= "acf_rack",
	name		= "40mm Pod Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Folding fins allow the rocket to be stored in this inaccurate, rapid-fire pod." .. rkdesc .. rackdesc,
	model		= "models/missiles/launcher7_40mm.mdl",
	caliber		= 4,
	gunclass	= "R7",
	weight		= R7_MASS,
	magsize		= 7,
	year		= 1960,
	roundclass	= "Rocket",
	round		= 
	{
		id			= "40mmRT",
		model		= "models/missiles/ffar_40mm.mdl",
		rackmdl		= "models/missiles/ffar_40mm_closed.mdl",
		maxlength	= 32,
		--maxweight	= 3,
		casing		= 0.2,	// thickness of missile casing, cm
			// rough calculations from hellfire M120E3 motor
		propweight	= 1,	// motor mass - motor casing
		thrust		= 300*39.37,	// average thrust - kg*in/s^2
		burnrate	= 450,	// cm^3/s at average chamber pressure
		starterpct	= 0.15
	}
} )




ACF_defineGun("70mmR7", { --id
	ent			= "acf_rack",
	name		= "70mm Pod Rocket",
	desc		= "A small, unguided rocket.  Useful against light vehicles and infantry.  Folding fins allow the rocket to be stored in this inaccurate, rapid-fire pod." .. rkdesc .. rackdesc,
	model		= "models/missiles/launcher7_70mm.mdl",
	caliber		= 7,
	gunclass	= "R7",
	weight		= R7_MASS*1.75,
	magsize		= 7,
	year		= 1960,
	rofmod		= 0.75,
	roundclass	= "Rocket",
	round		= 
	{
		id			= "70mmRT",
		model		= "models/missiles/ffar_70mm.mdl",
		rackmdl		= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 26*1.75,
		--maxweight	= 3*1.75,
		casing		= 0.2,	// thickness of missile casing, cm
			// rough calculations from hellfire M120E3 motor
		propweight	= 1.75,	// motor mass - motor casing
		thrust		= 400*39.37,	// average thrust - kg*in/s^2
		burnrate	= 450,	// cm^3/s at average chamber pressure
		starterpct	= 0.15
	},
	blacklist = nonsmoke
} )



