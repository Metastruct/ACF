
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	
	if not IsValid(Gun) then error("Received a muzzleflash for an invalid gun!") return end
	
	local Sound = Gun:GetNWString( "Sound" )
	local Propellant = data:GetScale()
	local ReloadTime = data:GetMagnitude()
	
	local Class = Gun:GetNWString( "Class" )
	local guntable = ACF.Classes["GunClass"][Class]
	if not guntable then error("Couldn't find the gun's class for a muzzleflash! (" .. Class .. ")") return end
	
	--local Id = Gun:GetNWString( "Id" ) or error("Couldn't find the gun's ID while making a muzzleflash!")
	local RoundType = ACF.IdRounds[data:GetSurfaceProp()]
		
	if Gun:IsValid() then
		if Propellant > 0 then
			local pos = Gun:GetPos()
			local SoundPressure = (Propellant*1000)^0.5
			sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,127), 100) --wiki documents level tops out at 180, but seems to fall off past 127
			if not ((Class == "MG") or (Class == "RAC")) then
				sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,127), 100)
				if (SoundPressure > 127) then
					sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure-127,1,127), 100)
				end
			end
			--sound.Play( ACF.Classes["GunClass"][Class]["soundDistance"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			--sound.Play( ACF.Classes["GunClass"][Class]["soundNormal"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			
			local Muzzle = Gun:GetAttachment( Gun:LookupAttachment( "muzzle" ) ) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
			ParticleEffect( guntable["muzzleflash"], Muzzle.Pos, Muzzle.Ang, Gun )
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