	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Machine Gun"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make lots of dudes disappear."
	SWEP.Instructions       = "Reload at 7.62mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_mach_m249para.mdl";
SWEP.WorldModel 		= "models/weapons/w_mach_m249para.mdl";
SWEP.ViewModelFlip		= false

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 1.5
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_M249.Single"

SWEP.ReloadTime				= 8

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 0.9
SWEP.MaxInaccuracy = 15
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.12
SWEP.AccuracyDecay = 0.5
SWEP.InaccuracyPerShot = 2
SWEP.InaccuracyCrouchBonus = 2.3
SWEP.InaccuracyDuckPenalty = 10

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.014
SWEP.StaminaJumpDrain = 0.2

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.6
SWEP.ZoomDecayMod = 1
SWEP.ZoomFOV = 65

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false