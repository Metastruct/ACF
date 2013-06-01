AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	//* rpg
	self.BulletData["BlastRadius"]			= 53.542728888373
	self.BulletData["BoomPower"]			= 2.9305305970856
	self.BulletData["Caliber"]			= 8.5
	self.BulletData["CasingMass"]			= 0.29570050752128
	self.BulletData["ConeAng"]			= 60
	self.BulletData["Cutout"]			= 0.35416583847288
	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.0037179919757052
	self.BulletData["Drift"]			= 5.567397921999
	self.BulletData["FillerMass"]			= 1.2305305970856
	self.BulletData["FillerVol"]			= 50000
	self.BulletData["FrAera"]			= 56.74515
	self.BulletData["Id"]			= "85mmRK"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]			= 3.2262311046069
	self.BulletData["Motor"]			= 24406.187110267
	self.BulletData["MuzzleVel"]			= 114
	self.BulletData["PenAera"]			= 30.962743577239
	self.BulletData["ProjLength"]			= 21
	self.BulletData["ProjMass"]			= 1.5262311046069
	self.BulletData["PropLength"]			= 18.724067166974
	self.BulletData["PropMass"]			= 1.7
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 2254.14815
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 1.9165880508742
	self.BulletData["SlugDragCoef"]			= 0.0018928390741967
	self.BulletData["SlugMV"]			= 1057.3584926577
	self.BulletData["SlugMass"]			= 0.1524174729
	self.BulletData["SlugPenAera"]			= 2.4610825543958
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "HEAT"
	self.BulletData["InvalidateTraceback"]			= true
	//*/
	
	/* dumbfire
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
	self:UpdateFakeCrate()
end



function SWEP:FireBullet()

	self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	//printByName(self.BulletData)
	
	/*
	local rocket = ents.Create( "XCF_Missile" )
	rocket:SetPos(MuzzlePos2)
	rocket:SetAngles(MuzzleVecFinal:Angle())
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:SetCrate(self)
	rocket:Launch()
	myrokkit = rocket
	//*/
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Flight"] = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	self.BulletData.ProjClass = XCF.ProjClasses.Rocket or error("Could not find the Rocket projectile type!")
	
	XCF_CreateBulletSWEP(self.BulletData, self)
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end




function SWEP:GrabRocketFromCrate(crate)
	
	local ammotype = crate.RoundId
	local ammotbl = ACF.Weapons.Guns[ammotype]
	
	if not ammotbl then return false end
	if ammotbl.gunclass ~= "RK" or ammotype ~= "85mmRK" then
		self.Owner:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", "You can only reload this weapon with 85mm RPG Rounds!", "NOTIFY_GENERIC" ) )
		return false
	end
	
	local rkdata = {}
	rkdata.Id = crate.RoundId		--Weapon this round loads into, ie 140mmC, 105mmH ...
	rkdata.Type = crate.RoundType		--Type of round, IE AP, HE, HEAT ...
	rkdata.PropLength = crate.RoundPropellant--Lenght of propellant
	rkdata.ProjLength = crate.RoundProjectile--Lenght of the projectile
	rkdata.FillerVol = ( crate.RoundData5 or 0 )
	rkdata.ConeAng = ( crate.RoundData6 or 0 )
	
	rkdata = XCF_GenerateMissileInfo( rkdata, true )
	
	rkdata.Crate = -1
	
	self.BulletData = rkdata
	self:UpdateFakeCrate()
	
	self.Owner:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", "Reloaded the ATGL with ".. rkdata.Id .." ammo!", "NOTIFY_GENERIC" ) )
	
end


