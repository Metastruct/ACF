
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
	self.BulletData["BoomPower"]			= 0.020998006340302
	self.BulletData["Caliber"]			= 1.27
	self.BulletData["DragCoef"]			= 0.0023268800946611
	self.BulletData["FrAera"]			= 1.26677166
	self.BulletData["Id"]			= "12.7mmMG"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MuzzleVel"]			= 899.98757024143
	self.BulletData["PenAera"]			= 1.2226258898987
	self.BulletData["ProjLength"]			= 5.4400000572205
	self.BulletData["ProjMass"]			= 0.054440779432794
	self.BulletData["PropLength"]			= 10.359999656677
	self.BulletData["PropMass"]			= 0.020998006340302
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 20.014991865574
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "AP"
	self.BulletData["InvalidateTraceback"]			= true

	self:UpdateFakeCrate()
end
