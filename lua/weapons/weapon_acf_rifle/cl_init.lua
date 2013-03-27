include('shared.lua')

SWEP.DrawAmmo			= true
SWEP.DrawWeaponInfoBox	= true
SWEP.BounceWeaponIcon   = true
SWEP.SwayScale			= 2.0					-- The scale of the viewmodel sway
SWEP.BobScale			= 2.0					-- The scale of the viewmodel bob

function SWEP:DrawScope()
	// no scope.
	return true
end