
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
	self.BulletData["BoomPower"] =		0.029961250704
	self.BulletData["Caliber"] =		1.45
	self.BulletData["DragCoef"] =		0.0022364360155656
	self.BulletData["FrAera"] =			1.6513035
	self.BulletData["KETransfert"] =	0.1
	self.BulletData["LimitVel"] =		800
	self.BulletData["MaxPen"] =			20.877186001597
	self.BulletData["MaxProjLength"] =	5.66
	self.BulletData["MaxPropLength"] =	11.34
	self.BulletData["MaxTotalLength"] =	19.5
	self.BulletData["MinProjLength"] =	2.175
	self.BulletData["MinPropLength"] =	0.01
	self.BulletData["MuzzleVel"] =		923.11201725189
	self.BulletData["PenAera"] =		1.5316264800639
	self.BulletData["ProjLength"] =		5.66
	self.BulletData["ProjMass"] =		0.073836384699
	self.BulletData["ProjVolume"] =		9.34637781
	self.BulletData["PropLength"] =		11.34
	self.BulletData["PropMass"] =		0.029961250704
	self.BulletData["Ricochet"] =		75
	self.BulletData["RoundVolume"] =	28.0721595
	self.BulletData["ShovePower"] =		0.2
	self.BulletData["Tracer"] =			2.5
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"

	self:UpdateFakeCrate()
end
