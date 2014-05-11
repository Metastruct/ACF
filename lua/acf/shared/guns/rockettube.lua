
--define the class
ACF_defineGunClass("RT", {
	spread = 3,
	name = "Rocket Tube",
	desc = "Rocket Tubes are heavy barrels which launch rockets from ammo crates and protect the rocket from shots.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 1.8,
	sound = "acf_extra/airfx/rpg_fire.wav",
	soundDistance = " ",
	soundNormal = " "
} )



nonsmoke = {SM = true, FL = true}

local rkdesc = "  Rockets give great firepower for light weight, but are less accurate."



ACF_defineGun("40mmRT", { --id
	name		= "40mm Tube Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Now in single-tube form!" .. rkdesc,
	model		= "models/mortar/mortar_60mm.mdl",
	caliber		= 4,
	gunclass	= "RT",
	weight		= 800,
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




ACF_defineGun("70mmRT", { --id
	name		= "70mm Tube Rocket",
	desc		= "A small, unguided rocket.  Useful against light vehicles and infantry.  Lubed and tubed." .. rkdesc,
	model		= "models/mortar/mortar_60mm.mdl",
	caliber		= 7,
	gunclass	= "RT",
	weight		= 1600,
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




ACF_defineGun("85mmRT", { --id
	name		= "85mm Tube Rocket",
	desc		= "A small, unguided propelled grenade.  Useful against light vehicles and blackhawks.  Made in Russia.  Fits in tube." .. rkdesc,
	model		= "models/mortar/mortar_80mm.mdl",
	caliber		= 8.5,
	gunclass	= "RT",
	weight		= 2500,
	year		= 1960,
	roundclass	= "Rocket",
	round		= 
	{
		id			= "85mmRT",
		model		= "models/missiles/70mmffar.mdl",
		maxlength	= 24*2.54,
		--maxweight	= 2.6,
		casing		= 0.2,	// thickness of missile casing, cm
			// rough calculations from hellfire M120E3 motor
		propweight	= 1.2,	// motor mass - motor casing
		thrust		= 1350*39.37,	// average thrust - kg*in/s^2
		burnrate	= 1000,	// cm^3/s at average chamber pressure
		starterpct	= 0.25
	},
	blacklist = nonsmoke
} )




ACF_defineGun("90mmRT", { --id
	name		= "90mm Tube Rocket",
	desc		= "A small, unguided propelled grenade.  Useful against light vehicles and blackhawks.  Made in Russia.  Fits in tube." .. rkdesc,
	model		= "models/mortar/mortar_80mm.mdl",
	caliber		= 9,
	gunclass	= "RT",
	weight		= 3500,
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




ACF_defineGun("170mmRT", { --id
	name		= "170mm Tube Rocket",
	desc		= "An unguided multi-purpose rocket, specifically designed to ruin days.  Someone put a tube around it so it doesn't get shot up.  How thoughtful!" .. rkdesc,
	model		= "models/mortar/mortar_200mm.mdl",
	gunclass 	= "RT",
	caliber		= 17,
	weight		= 8000,
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
