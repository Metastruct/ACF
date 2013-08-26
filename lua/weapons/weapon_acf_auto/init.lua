
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
	self.BulletData["BoomPower"]			= 0.00895860917952
	self.BulletData["Caliber"]			= 1.27
	self.BulletData["DragCoef"]			= 0.002438964903295
	self.BulletData["FrAera"]			= 1.26677166
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 10.039540453683
	self.BulletData["MaxProjLength"]			= 8.88
	self.BulletData["MaxPropLength"]			= 8.11
	self.BulletData["MaxTotalLength"]			= 15.8
	self.BulletData["MinProjLength"]			= 1.905
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 601.8434644641
	self.BulletData["PenAera"]			= 1.2226258898987
	self.BulletData["ProjLength"]			= 5.19
	self.BulletData["ProjMass"]			= 0.05193890483166
	self.BulletData["ProjVolume"]			= 6.5745449154
	self.BulletData["PropLength"]			= 4.42
	self.BulletData["PropMass"]			= 0.00895860917952
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 12.1736756526
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 2.5
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"
	self.BulletData["InvalidateTraceback"]			= true

	self:UpdateFakeCrate()
end