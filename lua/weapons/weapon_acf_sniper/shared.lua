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
	SWEP.Instructions       = "Reload at 20mm AC Ammo-boxes!"

end

util.PrecacheSound( "Weapon_AWP.Single" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_snip_scout.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_scout.mdl";
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
SWEP.Primary.Sound 			= "acf_extra/tankfx/gnomefather/mortar2.wav"--"Weapon_AWP.Single"

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
SWEP.HasScope = true
SWEP.ZoomInaccuracyMod = 0.01
SWEP.ZoomDecayMod = 2
SWEP.ZoomFOV = 15

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.006 / 1
SWEP.StaminaJumpDrain = 0.1

SWEP.Class = "HMG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false


function SWEP:InitBulletData()
	self.BulletData = {}
	//*
	self.BulletData["BoomPower"]			= 0.0924384384
	self.BulletData["Caliber"]			= 2
	self.BulletData["DragCoef"]			= 0.0013171933244642
	self.BulletData["FrAera"]			= 3.1416
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 37.957052221404
	self.BulletData["MaxProjLength"]			= 9.61
	self.BulletData["MaxPropLength"]			= 18.39
	self.BulletData["MaxTotalLength"]			= 28
	self.BulletData["MinProjLength"]			= 3
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 902.16352395768
	self.BulletData["PenAera"]			= 2.6459294187502
	self.BulletData["ProjLength"]			= 9.61
	self.BulletData["ProjMass"]			= 0.2385071304
	self.BulletData["ProjVolume"]			= 30.190776
	self.BulletData["PropLength"]			= 18.39
	self.BulletData["PropMass"]			= 0.0924384384
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 87.9648
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"20mmAC"
	self.BulletData["InvalidateTraceback"]			= true
	
	if SERVER then
		self.BulletData.CallbackEndFlight = self.CallbackEndFlight
	end
end