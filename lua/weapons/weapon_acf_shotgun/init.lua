
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
	self.BulletData["BoomPower"]		=		0.00636426081984
	self.BulletData["Caliber"]			=		1.27
	self.BulletData["DragCoef"]			=		0.0049253804856425
	self.BulletData["FrAera"]			=		1.26677166
	self.BulletData["KETransfert"]		=		0.1
	self.BulletData["LimitVel"]			=		800
	self.BulletData["MaxPen"]			=		6.4296214695794
	self.BulletData["MaxProjLength"]	=		12.66
	self.BulletData["MaxPropLength"]	=		13.23
	self.BulletData["MaxTotalLength"]	=		15.8
	self.BulletData["MinProjLength"]	=		1.905
	self.BulletData["MinPropLength"]	=		0.01
	self.BulletData["MuzzleVel"]		=		350.86568981831
	self.BulletData["PenAera"]			=		1.2226258898987
	self.BulletData["ProjLength"]		=		2.57
	self.BulletData["ProjMass"]			=		0.02571926501298
	self.BulletData["ProjVolume"]		=		3.2556031662
	self.BulletData["PropLength"]		=		0.05
	self.BulletData["PropMass"]			=		0.0010
	self.BulletData["Ricochet"]			=		75
	self.BulletData["RoundVolume"]		=		7.2332661786
	self.BulletData["ShovePower"]		=		0.2
	self.BulletData["Tracer"]			=		0
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"
	self.BulletData["InvalidateTraceback"]			= true

	self:UpdateFakeCrate()
end




function SWEP:FireBullet()

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	for i=1, 8 do
		self.BulletData["Flight"] = self:inaccuracy(MuzzleVecFinal, self.ShotSpread) * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
			
		XCF_CreateBulletSWEP(self.BulletData, self)
	end
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	//debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 10000, 60, Color(200, 200, 255, 255),  true)
	
end