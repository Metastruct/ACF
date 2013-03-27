	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Base"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Why do you have this"
	SWEP.Instructions       = "pls stop"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_snip_sg550.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_SG550.Single"

SWEP.ReloadTime				= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

// misnomer.  the position of the acf muzzleflash.
SWEP.AimOffset = Vector(32, 8, -1)

// use this to chop the scope off your gun
SWEP.ScopeChopPos = Vector(0, 0, 0)
SWEP.ScopeChopAngle = Angle(0, 0, -90)

SWEP.MinInaccuracy = 0.5
SWEP.MaxInaccuracy = 12
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.1
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 7
SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 6

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004
SWEP.StaminaJumpDrain = 0.1

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false



local function biasedapproach(cur, target, incup, incdn)	
	incdn = math.abs( incdn )
	incup = math.abs( incup )

    if (cur < target) then
        return math.Clamp( cur + incdn, cur, target )
    elseif (cur > target) then
        return math.Clamp( cur - incup, target, cur )
    end

    return target	
end



SWEP.LastAim = Vector()
SWEP.LastThink = RealTime()
SWEP.WasCrouched = false
function SWEP:Think()

	if self.ThinkBefore then self:ThinkBefore() end

	
	if CLIENT then
		local zoomed = self:GetNetworkedBool("Zoomed")
		//Msg(zoomed)
		if zoomed != self.Zoomed then
			//print(zoomed, "has changed!!11")
			self.Zoomed = zoomed
			
			if self.Zoomed then
				self.cachedmin = self.cachedmin or self.MinInaccuracy
				self.cacheddecayin = self.cacheddecayin or self.InaccuracyDecay
				self.cacheddecayac = self.cacheddecayac or self.AccuracyDecay
				
				self.MinInaccuracy = self.MinInaccuracy * self.ZoomInaccuracyMod
				self.InaccuracyDecay = self.InaccuracyDecay * self.ZoomDecayMod
				self.AccuracyDecay = self.AccuracyDecay * self.ZoomDecayMod
			else			
				if self.cachedmin then
					self.MinInaccuracy = self.cachedmin
					self.InaccuracyDecay = self.cacheddecayin
					self.AccuracyDecay = self.cacheddecayac
					
					self.cachedmin = nil
					self.cacheddecayin = nil
					self.cacheddecayac = nil
				end
			end
			
		end
	end
	
	
	local timediff = (RealTime() - self.LastThink) * 66
	
	//print(self.Owner:GetVelocity():Length())
	
	local inaccuracydiff = self.MaxInaccuracy - self.MinInaccuracy
	
	//local vel = math.Clamp(math.sqrt(self.Owner:GetVelocity():Length()/400), 0, 1) * inaccuracydiff	// max vel possible is 3500
	local vel = math.Clamp(self.Owner:GetVelocity():Length()/400, 0, 1) * inaccuracydiff	// max vel possible is 3500
	local aim = self.Owner:GetAimVector()
	local diffaim = math.pow((aim - self.LastAim):Length(), 1) * 100
	local crouching = self.Owner:Crouching()
	local decay = self.InaccuracyDecay
	local penalty = 0
	
	//print(self.Owner:KeyDown(IN_SPEED), self.Owner:KeyDown(IN_RUN))
	
	local healthFract = self.Owner:Health() / 100
	self.MaxStamina = math.Clamp(healthFract, 0, 1)
	
	if self.Owner:KeyDown(IN_SPEED) then
		self.Stamina = math.Clamp(self.Stamina - self.StaminaDrain, 0, 1)
	else
		local recover = (crouching and self.StaminaDrain * self.InaccuracyCrouchBonus or self.StaminaDrain) * 0.33
		self.Stamina = math.Clamp(self.Stamina + recover, 0, self.MaxStamina)
	end
	
	decay = decay * self.Stamina
	
	if crouching then
		decay = decay * self.InaccuracyCrouchBonus
	end
	
	if self.WasCrouched != crouching then
		penalty = penalty + self.InaccuracyDuckPenalty
	end
	
	//self.Inaccuracy = math.Clamp(self.Inaccuracy + (vel + diffaim + penalty - decay) * timediff, self.MinInaccuracy, self.MaxInaccuracy)
	local rawinaccuracy = self.MinInaccuracy + (vel + diffaim) * timediff
	local idealinaccuracy = biasedapproach(self.Inaccuracy, rawinaccuracy, decay, self.AccuracyDecay) + penalty
	self.Inaccuracy = math.Clamp(idealinaccuracy, self.MinInaccuracy, self.MaxInaccuracy)
	
	self.LastAim = aim
	self.LastThink = RealTime()
	self.WasCrouched = self.Owner:Crouching()
	
	if self.ThinkAfter then self:ThinkAfter() end
	
end



function SWEP:SetZoom(zoom)

	self.Zoomed = zoom or (not self.Zoomed)
	
	if SERVER then self:SetNetworkedBool("Zoomed", self.Zoomed) end
	
	if self.Zoomed then
		self.cachedmin = self.cachedmin or self.MinInaccuracy
		self.cacheddecayin = self.cacheddecayin or self.InaccuracyDecay
		self.cacheddecayac = self.cacheddecayac or self.AccuracyDecay
		
		self.MinInaccuracy = self.MinInaccuracy * self.ZoomInaccuracyMod
		self.InaccuracyDecay = self.InaccuracyDecay * self.ZoomDecayMod
		self.AccuracyDecay = self.AccuracyDecay * self.ZoomDecayMod
		
		if SERVER then self.Owner:SetFOV(self.ZoomFOV, 0.25) end
	else			
		self.MinInaccuracy = self.cachedmin
		self.InaccuracyDecay = self.cacheddecayin
		self.AccuracyDecay = self.cacheddecayac
		
		self.cachedmin = nil
		self.cacheddecayin = nil
		self.cacheddecayac = nil
		
		if SERVER then self.Owner:SetFOV(0, 0.25) end
	end

end



function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self.Weapon:EmitSound( "Weapon_Pistol.Empty", 100, math.random(90,120) )
		return false
	end
	return true
end



function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.Weapon:TakePrimaryAmmo(1)
		
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		if SERVER then
			self.Weapon:EmitSound( self.Primary.Sound )
			
			self:FireBullet()
			
			local rnda = self.Primary.Recoil * -1 
			local rndb = self.Primary.Recoil * math.random(-1, 1) 
			self.Owner:ViewPunch( Angle( rnda,rndb,rnda/4 ) ) 
		end
		
		self.Inaccuracy = math.Clamp(self.Inaccuracy + self.InaccuracyPerShot, self.MinInaccuracy, self.MaxInaccuracy)
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end



SWEP.Zoomed = false
function SWEP:SecondaryAttack()

	if SERVER and self.HasZoom then
		self:SetZoom()
	end

	return false
	
end



function SWEP:Reload()
	if self.Zoomed then return false end

	if SERVER then
		self.Owner:DoReloadEvent()
	end
	
	local reloaded = self:DefaultReload( ACT_VM_RELOAD )
	
	if reloaded then
		self.Inaccuracy = self.MaxInaccuracy
	end
end



function SWEP.randvec(min, max)
	return Vector(	min.x+math.random()*(max.x-min.x),
					min.y+math.random()*(max.y-min.y),
					min.z+math.random()*(max.z-min.z))
end

// Randomly perturbs a vector within a cone of Degs degrees.
// Gaussian distribution, NOT uniform!
SWEP.cachedvec = Vector()
function SWEP:inaccuracy(vec, degs)
	local rand = self.randvec(vec, self.cachedvec)
	self.cachedvec = rand:Cross(VectorRand()):GetNormalized()
	
	local cos = math.cos(math.rad(degs))

	local phi = 2 * math.pi * math.random()
	local z = cos + ( 1 - cos ) * math.random()
	sint = math.sqrt( 1 - z*z )

	return rand * math.cos(phi) * sint + self.cachedvec * math.sin(phi) * sint + vec * z
end
