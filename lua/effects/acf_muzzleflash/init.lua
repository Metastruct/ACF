
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	local Sound = Gun:GetNWString( "Sound" )
	local Propellant = data:GetScale()
	local ReloadTime = data:GetMagnitude()
	
	local Class = Gun:GetNWString( "Class" ) or error("Couldn't find the gun's class while making a muzzleflash!")
	local Id = Gun:GetNWString( "Id" ) or error("Couldn't find the gun's ID while making a muzzleflash!")
	local RoundType = ACF.IdRounds[data:GetSurfaceProp()]
		
	if Gun:IsValid() then
		if Propellant > 0 then
			local pos = Gun:GetPos()
			local SoundPressure = (Propellant*1000)^0.5
			sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			if not ((Class == "MG") or (Class == "RAC")) then
				sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			end
			--sound.Play( ACF.Classes["GunClass"][Class]["soundDistance"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			--sound.Play( ACF.Classes["GunClass"][Class]["soundNormal"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			
			local Muzzle = Gun:GetAttachment( Gun:LookupAttachment( "muzzle" ) ) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
			ParticleEffect( ACF.Classes["GunClass"][Class]["muzzleflash"], Muzzle.Pos, Muzzle.Ang, Gun )
			Gun:Animate( Class, ReloadTime, false )
		else
			Gun:Animate( Class, ReloadTime, true )
		end
	end
	
 end 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end