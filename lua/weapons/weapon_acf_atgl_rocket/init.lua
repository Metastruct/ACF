AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



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
	
	local filter = self.BulletData["Filter"] or {}
	filter[#filter + 1] = self.Owner
	filter[#filter + 1] = self.Owner:GetVehicle() or nil
	self.BulletData["Filter"] = filter
	
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
	self:DoAmmoStatDisplay()
	
end


