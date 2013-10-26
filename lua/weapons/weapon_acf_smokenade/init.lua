
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