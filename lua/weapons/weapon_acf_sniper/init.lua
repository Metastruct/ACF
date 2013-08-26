
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
	
	self:UpdateFakeCrate()
end
