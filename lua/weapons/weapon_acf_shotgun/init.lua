
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
	self.BulletData["BoomPower"]			= 0.00054724535712
	self.BulletData["Caliber"]			= 0.762
	self.BulletData["DragCoef"]			= 0.0024820055068243
	self.BulletData["FrAera"]			= 0.4560377976
	self.BulletData["Id"]			= "7.62mmMG"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MuzzleVel"]			= 250.09306022354
	self.BulletData["PenAera"]			= 0.51303939370339
	self.BulletData["ProjLength"]			= 5.0999999046326
	self.BulletData["ProjMass"]			= 0.018373762521724
	self.BulletData["PropLength"]			= 0.75
	self.BulletData["PropMass"]			= 0.00054724535712
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 2.6678210724688
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "AP"
	self.BulletData["InvalidateTraceback"]			= true
	
	self:UpdateFakeCrate()
end




function SWEP:FireBullet()

	self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()	
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	local plyvel = self.Owner:GetVelocity()
	for i=1, 8 do
		self.BulletData["Flight"] = self:inaccuracy(MuzzleVecFinal, self.ShotSpread) * self.BulletData["MuzzleVel"] * 39.37 + plyvel
			
		XCF_CreateBulletSWEP(self.BulletData, self)
	end
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	self.Owner:LagCompensation( false )
	
	//debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 10000, 60, Color(200, 200, 255, 255),  true)
	
end