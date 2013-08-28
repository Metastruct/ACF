
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
	self.BulletData["BoomPower"]			= 0.003757751452224
	self.BulletData["Caliber"]			= 0.762
	self.BulletData["DragCoef"]			= 0.0028381676789465
	self.BulletData["FrAera"]			= 0.4560377976
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 9.1893699170626
	self.BulletData["MaxProjLength"]			= 7.85
	self.BulletData["MaxPropLength"]			= 8.54
	self.BulletData["MaxTotalLength"]			= 13
	self.BulletData["MinProjLength"]			= 1.143
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 700.79707131587
	self.BulletData["PenAera"]			= 0.51303939370339
	self.BulletData["ProjLength"]			= 4.46
	self.BulletData["ProjMass"]			= 0.016068035760638
	self.BulletData["ProjVolume"]			= 2.033928577296
	self.BulletData["PropLength"]			= 5.15
	self.BulletData["PropMass"]			= 0.003757751452224
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 4.382523234936
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 2.5
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"7.62mmMG"
	self.BulletData["InvalidateTraceback"]			= true

	self:UpdateFakeCrate()
end



local LOW_AMMO_COL = Color(150, 150, 0)
function SWEP:BeforeFire()
	local clip1 = self:Clip1()
	if clip1 <= 10 then
		self.BulletData["Tracer"] = 2.5
		self.BulletData["Colour"] = LOW_AMMO_COL
	elseif clip1 % 5 == 0 then
		self.BulletData["Tracer"] = 2.5
		self.BulletData["Colour"] = nil
	else
		self.BulletData["Tracer"] = 0
		self.BulletData["Colour"] = nil
	end
end