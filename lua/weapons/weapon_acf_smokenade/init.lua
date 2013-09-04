
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	self.BulletData["BoomPower"]	= 0.07806550085885
	self.BulletData["Caliber"]		= 8
	self.BulletData["DragCoef"]		= 0.0012252117505705
	self.BulletData["FillerMass"]	= 0.07726125125885
	self.BulletData["FrAera"]		= 50.2656
	self.BulletData["Id"]			= "8cmB1"
	self.BulletData["KETransfert"]	= 0.1
	self.BulletData["LimitVel"]		= 100
	self.BulletData["MuzzleVel"]	= 20.289680830208
	self.BulletData["PenAera"]		= 27.930598395101
	self.BulletData["ProjLength"]	= 12
	self.BulletData["ProjMass"]		= 4.1026051192044
	self.BulletData["PropLength"]	= 0.01
	self.BulletData["PropMass"]		= 0.0008042496
	self.BulletData["Ricochet"]		= 60
	self.BulletData["RoundVolume"]	= 603.689856
	self.BulletData["ShovePower"]	= 0.1
	self.BulletData["Tracer"]		= 0
	self.BulletData["Type"]			= "SM"
	--self.BulletData["Colour"]		= Color(100, 200, 255)
	
	self:UpdateFakeCrate()
end


function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		local decibels 	= 90
		local pitch 	= 100
		sound.Play( "weapons/smokegrenade/sg_explode.wav", bomb:GetPos(), decibels, pitch, 1 )
	
		bomb:Detonate()
	end
end