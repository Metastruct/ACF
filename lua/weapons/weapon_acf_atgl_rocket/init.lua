AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	/* rpg
	self.BulletData["BlastRadius"]		= 164.53173881845
	self.BulletData["BoomPower"]		= 47.83654034402
	self.BulletData["Caliber"]			= 17
	self.BulletData["CasingMass"]		= 9.0974532297589
	self.BulletData["Cutout"]			= 4.2294422836372
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]			= 0.00049301889893239
	self.BulletData["Drift"]			= 13.252999329603
	self.BulletData["FillerMass"]		= 36.94147154402
	self.BulletData["FrAera"]			= 226.9806
	self.BulletData["Id"]				= "170mmRK"
	self.BulletData["KETransfert"]		= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]				= 56.933993573779
	self.BulletData["Motor"]			= 84.308155790614
	self.BulletData["MuzzleVel"]		= 520.72248960355
	self.BulletData["PenAera"]			= 100.5982506735
	self.BulletData["ProjLength"]		= 130
	self.BulletData["ProjMass"]			= 46.038924773779
	self.BulletData["PropLength"]		= 30
	self.BulletData["PropMass"]			= 10.8950688
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]		= 36316.896
	self.BulletData["ShovePower"]		= 0.1
	self.BulletData["SlugCaliber"]		= 3.8331761017484
	self.BulletData["SlugDragCoef"]		= 0.00094641953709837
	self.BulletData["SlugMV"]			= 2776.4155155407
	self.BulletData["SlugMass"]			= 1.2193397832
	self.BulletData["SlugPenAera"]		= 7.9960808097539
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]				= "HEAT"
	//*/
	
	//* dumbfire
	self.BulletData["BlastRadius"]			= 155.65293089663
	self.BulletData["BoomPower"]			= 42.120393621566
	self.BulletData["Caliber"]			= 17
	self.BulletData["CasingMass"]			= 7.6978450405652
	self.BulletData["ConeAng"]			= 60
	self.BulletData["Cutout"]			= 2.7237608306624
	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.00058315034670604
	self.BulletData["Drift"]			= 1.4167910854076
	self.BulletData["FillerMass"]			= 31.225324821566
	self.BulletData["FillerVol"]			= 50000
	self.BulletData["FrAera"]			= 226.9806
	self.BulletData["Id"]			= "170mmRK"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]			= 49.818238662132
	self.BulletData["Motor"]			= 2370.8184627125
	self.BulletData["MuzzleVel"]			= 393.7
	self.BulletData["PenAera"]			= 100.5982506735
	self.BulletData["ProjLength"]			= 110
	self.BulletData["ProjMass"]			= 38.923169862132
	self.BulletData["PropLength"]			= 30
	self.BulletData["PropMass"]			= 10.8950688
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 31777.284
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 3.8331761017484
	self.BulletData["SlugDragCoef"]			= 0.00094641953709837
	self.BulletData["SlugMV"]			= 2455.7784689146
	self.BulletData["SlugMass"]			= 1.2193397832
	self.BulletData["SlugPenAera"]			= 7.9960808097539
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "HEAT"
	//*/
	
	self.BulletData["Crate"] = -1
	
	/*
	
	//*/
	
	self:UpdateFakeCrate()
end



function SWEP:FireBullet()

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	/*
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Flight"] = MuzzleVecFinal * 100// + self.Owner:GetVelocity()
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	XCF_CreateDumbMissile(self.BulletData, true)
	//XCF_CreateBulletSWEP(self.BulletData, self)
	//*/
	local rocket = ents.Create( "XCF_Missile" )
	rocket:SetPos(MuzzlePos2)
	rocket:SetAngles(MuzzleVecFinal:Angle())
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:SetCrate(self)
	//rocket:Launch()
	myrokkit = rocket
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end