
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self:InitBulletData()
	self:UpdateFakeCrate()
end


function SWEP:UpdateFakeCrate(realcrate)
	self:SetNetworkedInt( "Caliber",		self.BulletData.Caliber or 10 )
	self:SetNetworkedInt( "ProjMass",		self.BulletData.ProjMass or 10 )
	self:SetNetworkedInt( "FillerMass",		self.BulletData.FillerMass or 0 )
	self:SetNetworkedInt( "DragCoef",		self.BulletData.DragCoef or 1 )
	self:SetNetworkedString( "AmmoType",	self.BulletData.Type or "AP" )
	self:SetNetworkedInt( "Tracer",  		self.BulletData.Tracer or 0)
	self:SetNetworkedVector( "Accel",		Vector(0,0,-600))
	self:SetNetworkedString( "Sound",		self.Primary.Sound)
	
	if realcrate then
		self:SetColor(realcrate:GetColor())
	end
	
	self.BulletData["Crate"] = self:EntIndex()
end



function SWEP:OnRemove()
end



local nosplode = {AP = true, HP = true}
local nopen = {HE = true, SM = true}
function SWEP:DoAmmoStatDisplay()
	local bType = self.BulletData.Type
	local sendInfo = string.format( "%smm %s ammo: %im/s speed",
									tostring(self.BulletData.Caliber * 10),
									bType,
									self.BulletData.MuzzleVel
								  )
	
	if not nopen[bType] then
		local maxpen = self.BulletData.MaxPen or (ACF_Kinetic(
														(self.BulletData.SlugMV or self.BulletData.MuzzleVel)*39.37,
														(self.BulletData.SlugMass or self.BulletData.ProjMass),
														self.BulletData.SlugMV and 999999 or self.BulletData.LimitVel or 900
													  ).Penetration / (self.BulletData.SlugPenAera or self.BulletData.PenAera) * ACF.KEtoRHA
												 )
	
		sendInfo = sendInfo .. string.format( 	", %.1fmm pen",
												maxpen
											)
	end

	if not nosplode[bType] then
		sendInfo = sendInfo .. string.format( 	", %.1fm blast",
												(self.BulletData.BlastRadius or (((self.BulletData.FillerMass or 0) / 2) ^ 0.33 * 5 * 10 )) * 0.2
											)
	end
	
	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end




function SWEP:Deploy()
	self:DoAmmoStatDisplay()
end




function SWEP:FireBullet()

	self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()	
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Flight"] = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	if self.BeforeFire then
		self:BeforeFire()
	end
	
	XCF_CreateBulletSWEP(self.BulletData, self, true)
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	self.Owner:LagCompensation( false )
	
end



local FlashID = "XCF_SWEPMuzzle"
util.AddNetworkString(FlashID)
function SWEP:MuzzleEffect( MuzzlePos, MuzzleDir )
	
	net.Start(FlashID)
		net.WriteEntity(self)
		net.WriteFloat(self.BulletData["PropMass"] or 1)
		net.WriteInt(ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1, 8)
	net.SendPVS(MuzzlePos)
	net.SendPAS(MuzzlePos)
	/*
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData["PropMass"] or 1 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1 )	--Encoding the ammo type into a table index
	util.Effect( "XCF_SWEPMuzzleFlash", Effect, true, true )
	//*/
end
