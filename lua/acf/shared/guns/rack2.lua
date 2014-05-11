

--define the class
ACF_defineGunClass("R2", {
	spread = 3,
	name = "Munition Rack (Dual)",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 2.2,
	sound = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance = " ",
	soundNormal = " ",
	mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(4, -1.5, -1.7),	["scaledir"] = Vector(0, -1, 0)},
		["missile2"] = {["offset"] = Vector(4, 1.5, -1.7),	["scaledir"] = Vector(0, 1, 0)}
	}
} )




local nonsmoke = {SM = true, FL = true}
local nofunallowed = {SM = true, HEAT = true, FL = true}

local rkdesc = "  Rockets give great firepower for light weight, but are less accurate."
local rackdesc = "  Racks and pods allow rapid rocket launches but can be detonated by the enemy. Racks need a refill crate to re-arm!"
local bombdesc = "Bombs have huge power but are heavy and fail if dropped badly."
local R2_MASS = 160




ACF_defineGun("90mmR2", { --id
	name		= "90mm Rack Rocket",
	ent			= "acf_rack",
	desc		= "A light anti-tank missile.  Capable against medium armour.  Pointy end towards enemy, toasty end towards lunch." .. rkdesc .. rackdesc,
	model		= "models/missiles/rack_double.mdl",
	caliber		= 9,
	gunclass	= "R2",
	weight		= R2_MASS,
	magsize		= 2,
	year		= 1960,
	roundclass	= "Rocket",
	round		= 
	{
		id			= "90mmRT",
		model		= "models/missiles/70mmffar.mdl",
		maxlength	= 32*2.54,
		--maxweight	= 2.6,
		casing		= 0.2,	// thickness of missile casing, cm
			// rough calculations from hellfire M120E3 motor
		propweight	= 2,	// motor mass - motor casing
		thrust		= 700*39.37,	// average thrust - kg*in/s^2
		burnrate	= 600,	// cm^3/s at average chamber pressure
		starterpct	= 0.2
	},
	blacklist = nonsmoke
} )




ACF_defineGun("170mmR2", { --id
	name		= "170mm Rack Rocket",
	ent			= "acf_rack",
	desc		= "An unguided multi-purpose rocket, specifically designed to ruin days.  Usually found on attack aircraft." .. rkdesc .. rackdesc,
	model		= "models/missiles/rack_double.mdl",
	gunclass	= "R2",
	caliber		= 17,
	weight		= R2_MASS,
	magsize		= 2,
	year		= 1970,
	roundclass	= "Rocket",
	round		= 
	{
		id			= "170mmRT",
		model		= "models/missiles/micro.mdl",
		maxlength	= 110,
		--maxweight	= 45,
		casing		= 1,	// thickness of missile casing, cm
			// rough calculations from hellfire M120E3 motor
		propweight	= 13,	// motor mass - motor casing
		thrust		= 3500*39.37,	// average thrust - kg*in/s^2
		burnrate	= 3000,	// cm^3/s at average chamber pressure
		starterpct	= 0.2
	},
	blacklist = nonsmoke
} )




-- -- -- -- BOMBS -- -- -- --




ACF_defineGun("20cmB2", { --id
	name		= "20cm Bomb",
	ent			= "acf_rack",
	desc		= "An unguided medium-capacity bomb.  Effective against everything which has wheels, and some things which don't.  Use these in a dogfight for instant man-points." .. bombdesc,
	model		= "models/missiles/rack_double.mdl",
	gunclass	= "R2",
	caliber		= 20,
	weight		= R2_MASS,
	magsize		= 2,
	year		= 1940,
	roundclass	= "Bomb",
	rofmod		= 0.5,
	sound		= "phx/epicmetal_hard.wav",
	round		= 
	{
		id			= "20cmB2",
		model		= "models/missiles/fab250.mdl",
		maxlength	= 35,
		--maxweight	= 250,
		propweight	= 0
	},
	blacklist	= nofunallowed,
	muzzleflash	= ""
} )




ACF_defineGun("12cmB2", { --id
	name		= "12cm Bomb",
	ent			= "acf_rack",
	desc		= "An unguided small-capacity bomb.  Which is large-capacity by usual standards.  Attach to plane, bring pain." .. bombdesc,
	model		= "models/missiles/rack_double.mdl",
	gunclass	= "R2",
	caliber		= 12,
	weight		= R2_MASS,
	magsize		= 2,
	year		= 1940,
	roundclass	= "Bomb",
	rofmod		= 0.5,
	sound		= "phx/epicmetal_hard.wav",
	round		= 
	{
		id			= "12cmB4",
		model		= "models/missiles/micro.mdl",
		maxlength	= 24,
		--maxweight	= 100,
		propweight	= 0
	},
	blacklist	= nonsmoke,
	muzzleflash	= ""
} )




ACF_defineGun("8cmB2", { --id
	name		= "8cm Bomb",
	ent			= "acf_rack",
	desc		= "A tiny, unguided bomb.  Use on fighter planes to deliver regards on an individual basis, or in carpet-bombers to write dirty words upon enemy nations." .. bombdesc,
	model		= "models/missiles/rack_double.mdl",
	gunclass	= "R2",
	caliber		= 8,
	weight		= R2_MASS,
	magsize		= 2,
	year		= 1940,
	roundclass	= "Bomb",
	rofmod		= 0.5,
	sound		= "phx/epicmetal_hard.wav",
	round		= 
	{
		id			= "8cmB4",
		model		= "models/missiles/micro.mdl",
		maxlength	= 16,
		--maxweight	= 50,
		propweight	= 0
	},
	muzzleflash	= ""
} )



