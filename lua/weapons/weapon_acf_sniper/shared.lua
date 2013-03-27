	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Sniper Rifle"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make tiny dudes disappear."
	SWEP.Instructions       = "Reload at 12.7mm MG Ammo-boxes!"

end

util.PrecacheSound( "Weapon_AWP.Single" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_snip_awp.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_awp.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 10
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 1.6
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_AWP.Single"

SWEP.ReloadTime				= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false

SWEP.MinInaccuracy = 1.5
SWEP.MaxInaccuracy = 18
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.06
SWEP.AccuracyDecay = 0.5
SWEP.InaccuracyPerShot = 17
SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 8

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.1
SWEP.ZoomDecayMod = 2
SWEP.ZoomFOV = 25

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.006
SWEP.StaminaJumpDrain = 0.1

SWEP.Class = "HMG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false
