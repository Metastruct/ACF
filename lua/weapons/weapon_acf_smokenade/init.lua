
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false







function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		local decibels 	= 90
		local pitch 	= 100
		sound.Play( "weapons/smokegrenade/sg_explode.wav", bomb:GetPos(), decibels, pitch, 1 )
	
		bomb:Detonate()
	end
end



util.AddNetworkString("XCFSGCol")
function SWEP:SecondaryAttack()

	if not self.SmokeColourIdx then 
		self.SmokeColourIdx = 2
	else
		self.SmokeColourIdx = (self.SmokeColourIdx % #self.SmokeColours) + 1
	end
	
	self.BulletData.Colour = self.SmokeColours[self.SmokeColourIdx][2]
	
	net.Start("XCFSGCol")
		net.WriteEntity(self)
		net.WriteInt(self.SmokeColourIdx, 8)
	net.Send(self.Owner)

end