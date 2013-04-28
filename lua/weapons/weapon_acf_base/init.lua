
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
	self.BulletData["PenAera"]			=	1.2226258898987
	self.BulletData["MaxPen"]			=	15.517221066929
	self.BulletData["RoundVolume"]		=	16.8227276448
	self.BulletData["KETransfert"]		=	0.1
	self.BulletData["ProjMass"]			=	0.04143103391196
	self.BulletData["Tracer"]			=	2.5
	self.BulletData["Ricochet"]			=	75
	self.BulletData["ShovePower"]		=	0.2
	self.BulletData["FrAera"]			=	1.26677166
	self.BulletData["Caliber"]			=	1.27
	self.BulletData["MinPropLength"]	=	0.01
	self.BulletData["MaxProjLength"]	=	4.16
	self.BulletData["ProjLength"]		=	4.14
	self.BulletData["PropLength"]		=	9.14
	self.BulletData["PropMass"]			=	0.01852526875584
	self.BulletData["MaxPropLength"]	=	9.16
	self.BulletData["MuzzleVel"]		=	969.01169895961
	self.BulletData["LimitVel"]			=	800
	self.BulletData["MaxTotalLength"]	=	15.8
	self.BulletData["ProjVolume"]		=	5.2444346724
	self.BulletData["BoomPower"]		=	0.01852526875584
	self.BulletData["DragCoef"]			=	0.0030575429584786
	self.BulletData["MinProjLength"]	=	1.905
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"

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
	
	if realcrate then
		self:SetColor(realcrate:GetColor())
	end
	
	self.BulletData["Crate"] = self:EntIndex()
end



function SWEP:OnRemove()
end



function SWEP:FireBullet()

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Flight"] = MuzzleVecFinal * self.BulletData["MuzzleVel"] * 39.37 + self.Owner:GetVelocity()
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	XCF_CreateBulletSWEP(self.BulletData, self)
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	//debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 10000, 60, Color(200, 200, 255, 255),  true)
	
end



function SWEP:MuzzleEffect()
	
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData["PropMass"] or 1 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1 )	--Encoding the ammo type into a table index
	util.Effect( "XCF_SWEPMuzzleFlash", Effect, true, true )

end
