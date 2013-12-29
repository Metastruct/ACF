	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "rpg"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Anti-Tank GL"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make tanks disappear."
	SWEP.Instructions       = "Reload at 50mm Cannon Ammo-boxes!"
	//SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/potato_launcher.vtf")

end



SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_RPG.mdl";
SWEP.WorldModel 		= "models/weapons/w_rocket_launcher.mdl";

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 20
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"
SWEP.Primary.Sound 			= "acf_extra/tankfx/gnomefather/2pdr2.wav"

util.PrecacheSound( SWEP.Primary.Sound )

SWEP.ReloadTime				= 8

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false

SWEP.MinInaccuracy = 0.7
SWEP.MaxInaccuracy = 10
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.1
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 7
SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 4

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.15

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.5
SWEP.ZoomDecayMod = 1.2
SWEP.ZoomFOV = 40

SWEP.Class = "C"
SWEP.FlashClass = "AC"
SWEP.Launcher = true



function SWEP:InitBulletData()
	
	self.BulletData = {}
	//* rpg
	self.BulletData["BlastRadius"]		= 62.993062685473
	self.BulletData["BoomPower"]		= 3.2137624637998
	self.BulletData["Caliber"]			= 8.5
	self.BulletData["CasingMass"]		= 0.67222584406616
	self.BulletData["Cutout"]			= 0.56249868463339
	self.BulletData["Data10"]			= 0
	self.BulletData["Data5"]			= 1769.6700439453
	self.BulletData["Data6"]			= 54.020000457764
	self.BulletData["Data7"]			= 0
	self.BulletData["Data8"]			= 0
	self.BulletData["Data9"]			= 0
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]			= 0.0021126357785632
	self.BulletData["Drift"]			= 5.2807494854827
	self.BulletData["FillerMass"]		= 2.0137624637998
	self.BulletData["FrAera"]			= 56.74515
	self.BulletData["Id"]				= "85mmRT"
	self.BulletData["KETransfert"]		= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]				= 3.585988307866
	self.BulletData["Motor"]			= 14821.437059182
	self.BulletData["MuzzleVel"]		= 65.137869686233
	self.BulletData["PenAera"]			= 30.962743577239
	self.BulletData["ProjLength"]		= 47.740001678467
	self.BulletData["ProjMass"]			= 2.685988307866
	self.BulletData["PropLength"]		= 9.912741441339
	self.BulletData["PropMass"]			= 0.9
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]		= 3459.0135562449
	self.BulletData["ShovePower"]		= 0.1
	self.BulletData["SlugCaliber"]		= 1.8552783742132
	self.BulletData["SlugDragCoef"]		= 0.0020840793410166
	self.BulletData["SlugMV"]			= 1984.7472976276
	self.BulletData["SlugMass"]			= 0.1297163778223
	self.BulletData["SlugPenAera"]		= 2.3287491121616
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]				= "HEAT"
	self.BulletData["InvalidateTraceback"]			= true
	//*/
end



function SWEP:Reload()
	if self.Zoomed then return false end

	local reloaded = self:DefaultReload( ACT_VM_RELOAD )
	
	if SERVER then
		
		local crate = self.Owner:GetEyeTrace().Entity
		if reloaded and IsValid(crate) and crate:GetClass() == "acf_ammo" and self.Owner:GetPos():Distance(crate:GetPos()) < 200 then
			self:GrabRocketFromCrate(crate)
		end
		
		if reloaded then
			self.Weapon:SetNetworkedBool( "reloading", true )
			timer.Simple(self.ReloadTime, function() self.Weapon:SetNetworkedBool( "reloading", false ) end)
		end
	
		self.Owner:DoReloadEvent()
	end
	
	if reloaded then
		self.Inaccuracy = self.MaxInaccuracy
	end
end

