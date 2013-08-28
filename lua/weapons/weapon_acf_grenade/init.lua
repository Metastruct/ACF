
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	self.BulletData["BoomPower"]	= 0.49494626772744
	self.BulletData["Caliber"]		= 8
	self.BulletData["DragCoef"]		= 0.0017372329950914
	self.BulletData["FillerMass"]	= 0.49414201812744
	self.BulletData["FrAera"]		= 50.2656
	self.BulletData["Id"]			= "8cmB4"
	self.BulletData["KETransfert"]	= 0.1
	self.BulletData["LimitVel"]		= 100
	self.BulletData["MuzzleVel"]	= 24.160096985541
	self.BulletData["PenAera"]		= 27.930598395101
	self.BulletData["ProjLength"]	= 12
	self.BulletData["ProjMass"]		= 2.8934288113354
	self.BulletData["PropLength"]	= 0.01
	self.BulletData["PropMass"]		= 0.0008042496
	self.BulletData["Ricochet"]		= 60
	self.BulletData["RoundVolume"]	= 603.689856
	self.BulletData["ShovePower"]	= 0.1
	self.BulletData["Tracer"]		= 0
	self.BulletData["Type"]			= "HE"
	
	self:UpdateFakeCrate()
end




local MIN_DONK_DELAY = 0.2
local MIN_DONK_VEL = 50
function SWEP.grenadeDonk(nade)

	local phys = nade:GetPhysicsObject()
	if not phys then return end
	
	local vel = phys:GetVelocity():Length()
	if vel < MIN_DONK_VEL then return end
	
	local curtime = CurTime()
	if not nade.lastDonk or nade.lastDonk < curtime - MIN_DONK_DELAY then	
		local decibels 	= math.Clamp(vel / 3, 30, 70) + math.random()*5
		local pitch 	= math.Clamp(vel / 5, 80, 110) + math.random()*15
		sound.Play( "weapons/smokegrenade/grenade_hit1.wav", nade:GetPos(), decibels, pitch, 1 )
		nade.lastDonk = curtime
	end
end




function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		bomb:Detonate()
	end
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
	self.BulletData.ProjClass = XCF.ProjClasses.Bomb or error("Could not find the Bomb projectile type!")
	
	local flight = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
	local throwmod = math.Clamp((self.PressedDuration or 2) / 2, 0.5, 1.5)
	self.BulletData["Flight"] = flight * throwmod
	
	local bomb = ents.Create("xcf_bomb")
	bomb:SetPos(MuzzlePos2)
	bomb:SetOwner(self.Owner)
	bomb:Spawn()
	bomb:SetModelEasy(self.ThrowModel)
	bomb:SetBulletData(self.BulletData)
	local expfunc = self.grenadeExplode
	timer.Simple(5, function() expfunc(bomb) end)
	
	
	constraint.NoCollide(bomb, self.Owner)
	local phys = bomb:GetPhysicsObject()
	if phys then
		phys:SetVelocityInstantaneous(self.BulletData["Flight"])
		local angvel = self.Owner:LocalToWorld(Vector(400 + math.random()*300, 1000 + math.random()*1000, 40 + math.random()*30)) - self.Owner:GetPos()
		phys:AddAngleVelocity( angvel * throwmod)
		bomb.PhysicsCollide = self.grenadeDonk
	end
	
	
	local owner = self.Owner
	timer.Simple(self.Primary.Delay or 3, function()
			local wep = owner:GetActiveWeapon()
			wep:SendWeaponAnim(ACT_VM_DRAW)
			if owner:GetAmmoCount( self.Primary.Ammo ) <= 0 and wep:GetClass() == "weapon_acf_grenade" then
				self.Weapon:Remove()
				owner:ConCommand("lastinv")
			end
		end)
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end