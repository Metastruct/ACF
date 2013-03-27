
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	local Propellant = data:GetScale() or 1
	local ReloadTime = data:GetMagnitude() or 1
	local Class = Gun.Class
	local FlashClass = Gun.FlashClass
	local RoundType = ACF.IdRounds[data:GetSurfaceProp()] or "AP"
		
	if not ACF.Classes.GunClass[Class] then 
		Class = "C"
	end
		
	//print("muzzle", Gun, Propellant, ReloadTime, Class, RoundType)
		
	if Gun:IsValid() then
		if Propellant > 0 then
		
			local SoundPressure = (Propellant*1000)^0.5
			
			sound.Play( ACF.Classes["GunClass"][Class]["sound"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			sound.Play( ACF.Classes["GunClass"][Class]["sound"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			sound.Play( ACF.Classes["GunClass"][Class]["soundDistance"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			sound.Play( ACF.Classes["GunClass"][Class]["soundNormal"], Gun:GetPos() , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			
			Muzzle =
			{
				["Pos"] = Gun.Owner:GetShootPos(),
				["Ang"] = Gun.Owner:EyeAngles()
			}
			
			local muzzoffset = (Muzzle.Ang:Forward() * Gun.AimOffset.x) + (Muzzle.Ang:Right() * Gun.AimOffset.y) + (Muzzle.Ang:Up() * Gun.AimOffset.z)
			
			Muzzle.Pos = Muzzle.Pos + muzzoffset
			
			local flash = ACF.Classes["GunClass"][FlashClass]["muzzleflash"]
			
			ParticleEffect( flash, Muzzle.Pos, Muzzle.Ang, Gun )
			
			if Gun.Launcher then
				local muzzoffset = (Muzzle.Ang:Forward() * -Gun.AimOffset.x) + (Muzzle.Ang:Right() * Gun.AimOffset.y) + (Muzzle.Ang:Up() * Gun.AimOffset.z)
			
				Muzzle.Pos = Gun.Owner:GetShootPos() + muzzoffset
				Muzzle.Ang = (-Muzzle.Ang:Forward()):Angle()
				ParticleEffect( flash, Muzzle.Pos, Muzzle.Ang, Gun )
			end
			
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