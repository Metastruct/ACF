
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	//*

self.BulletData["BoomPower"]			= 0.0047557539540155
self.BulletData["Caliber"]			= 1.45

self.BulletData["DragCoef"]			= 0.0027221994813961

self.BulletData["FrAera"]			= 1.6513035
self.BulletData["Id"]			= "14.5mmMG"
self.BulletData["KETransfert"]			= 0.1
self.BulletData["LimitVel"]			= 800
self.BulletData["MuzzleVel"]			= 405.75684870795
self.BulletData["PenAera"]			= 1.5316264800639

self.BulletData["ProjLength"]			= 4.6500000953674
self.BulletData["ProjMass"]			= 0.060660635316597
self.BulletData["PropLength"]			= 1.7999999523163
self.BulletData["PropMass"]			= 0.0047557539540155
self.BulletData["Ricochet"]			= 75
self.BulletData["RoundVolume"]			= 10.65090765374
self.BulletData["ShovePower"]			= 0.2
self.BulletData["Tracer"]			= 0
self.BulletData["Type"]			= "AP"
	self.BulletData["InvalidateTraceback"]			= true

	self:UpdateFakeCrate()
end