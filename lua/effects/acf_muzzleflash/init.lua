
   
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
			sound.Play( Sound, pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			sound.Play( Sound, pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			//sound.Play( ACF.Classes["GunClass"][Class]["soundDistance"], pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			//sound.Play( ACF.Classes["GunClass"][Class]["soundNormal"], pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))	

			local Muzzle = Gun:GetAttachment( Attachment or Gun:LookupAttachment( "muzzle" ) ) or {["Pos"] = Gun:GetPos(), ["Ang"] = Gun:GetAngles()}
			local flash = ACF.Weapons.Guns[Id].muzzleflash or ACF.Classes.GunClass[Class].muzzleflash
			if flash and flash ~= "" then
				ParticleEffect( flash, Muzzle.Pos, Muzzle.Ang, Gun )
			end
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