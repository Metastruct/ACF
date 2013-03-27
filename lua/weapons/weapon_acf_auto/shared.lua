	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Assault Rifle"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes disappear slowly."
	SWEP.Instructions       = "Reload at 12.7mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_rif_aug.mdl";
SWEP.WorldModel 		= "models/weapons/w_rif_aug.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 2
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.13
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_AUG.Single"

SWEP.ReloadTime				= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 0.5
SWEP.MaxInaccuracy = 7
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.2
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 2.7
SWEP.InaccuracyCrouchBonus = 1.3
SWEP.InaccuracyDuckPenalty = 4

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004
SWEP.StaminaJumpDrain = 0.1

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false