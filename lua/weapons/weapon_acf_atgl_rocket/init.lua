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
	self.BulletData["BlastRadius"]		= 62.993062685473
	self.BulletData["BoomPower"]		= 3.2137624637998
	self.BulletData["Caliber"]			= 8.5
	self.BulletData["CasingMass"]		= 0.67222584406616
	self.BulletData["Cutout"]			= 0.56249868463339
	self.BulletData["Data10"]			= 0
	self.BulletData["Data5"]			= 1769.6700439453
	self.BulletData["Data6"]			= 54.020000457764
	self.BulletData["Data7"]			= 0
	self.BulletData["Data8"]			= 0
	self.BulletData["Data9"]			= 0
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]			= 0.0021126357785632
	self.BulletData["Drift"]			= 5.2807494854827
	self.BulletData["FillerMass"]		= 2.0137624637998
	self.BulletData["FrAera"]			= 56.74515
	self.BulletData["Id"]				= "85mmRT"
	self.BulletData["KETransfert"]		= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]				= 3.585988307866
	self.BulletData["Motor"]			= 14821.437059182
	self.BulletData["MuzzleVel"]		= 65.137869686233
	self.BulletData["PenAera"]			= 30.962743577239
	self.BulletData["ProjLength"]		= 47.740001678467
	self.BulletData["ProjMass"]			= 2.685988307866
	self.BulletData["PropLength"]		= 9.912741441339
	self.BulletData["PropMass"]			= 0.9
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]		= 3459.0135562449
	self.BulletData["ShovePower"]		= 0.1
	self.BulletData["SlugCaliber"]		= 1.8552783742132
	self.BulletData["SlugDragCoef"]		= 0.0020840793410166
	self.BulletData["SlugMV"]			= 1984.7472976276
	self.BulletData["SlugMass"]			= 0.1297163778223
	self.BulletData["SlugPenAera"]		= 2.3287491121616
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]				= "HEAT"
	self.BulletData["InvalidateTraceback"]			= true
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
	
	XCF_CreateBulletSWEP(self.BulletData, self, true)
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end




function SWEP:GrabRocketFromCrate(crate)
	
	local ammotype = crate.RoundId
	local ammotbl = ACF.Weapons.Guns[ammotype]
	
	if not ammotbl then return false end
	if ammotbl.gunclass ~= "RT" or ammotype ~= "85mmRT" then
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


