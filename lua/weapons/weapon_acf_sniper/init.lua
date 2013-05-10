
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
	self.BulletData["BoomPower"] =		0.032259865276788
	self.BulletData["Caliber"] =		1.45
	self.BulletData["DragCoef"] =		0.0017363824299505
	self.BulletData["FrAera"] =			1.6513035
	self.BulletData["KETransfert"] =	0.1
	self.BulletData["LimitVel"] =		800
	self.BulletData["MaxPen"] =			23.888645834379
	self.BulletData["MaxProjLength"] =	7.289999961853
	self.BulletData["MaxPropLength"] =	12.210000038147
	self.BulletData["MaxTotalLength"] =	19.5
	self.BulletData["MinProjLength"] =	2.175
	self.BulletData["MinPropLength"] =	0.01
	self.BulletData["MuzzleVel"] =		844.01499536877
	self.BulletData["PenAera"] =		1.5316264800639
	self.BulletData["ProjLength"] =		7.289999961853
	self.BulletData["ProjMass"] =		0.095100219370861
	self.BulletData["PropLength"] =		12.210000038147
	self.BulletData["PropMass"] =		0.032259865276788
	self.BulletData["Ricochet"] =		75
	self.BulletData["RoundVolume"] =	32.2
	self.BulletData["ShovePower"] =		0.2
	self.BulletData["Tracer"] =			0
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"14.5mmMG"
	self.BulletData["InvalidateTraceback"]			= true
	
	self:UpdateFakeCrate()
end
