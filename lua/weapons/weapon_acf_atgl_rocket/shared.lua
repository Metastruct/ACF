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

SWEP.IronSightsPos = Vector(-5, 5, -3)
SWEP.ZoomPos = Vector(-5, 5, -3)
SWEP.IronSightsAng = Angle(0, 0, 0)

SWEP.Class = "C"
SWEP.FlashClass = "AC"
SWEP.Launcher = true



function SWEP:InitBulletData()
	
	self.BulletData = {}
	//* rpg
	
	self.BulletData["Accel"]		= Vector(0.000000, 0.000000, -600.000000)
	self.BulletData["BlastRadius"]		= 62.729522705078
	self.BulletData["BoomFillerMass"]		= 0.66278034448624
	self.BulletData["BoomPower"]		= 3.1883409023285
	self.BulletData["Caliber"]		= 8.5
	self.BulletData["CasingMass"]		= 0.67222583293915
	self.BulletData["Colour"]		= Color(255, 255, 255)
	self.BulletData["Cutout"]		= 0.56249868869781
	self.BulletData["Data10"]		= 0
	self.BulletData["Data5"]		= 1747.3299560547
	self.BulletData["Data6"]		= 58
	self.BulletData["Data7"]		= 0
	self.BulletData["Data8"]		= 0
	self.BulletData["Data9"]		= 0
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]		= 0.0021328218281269
	self.BulletData["Drift"]		= 5.2995676994324
	self.BulletData["FillerMass"]		= 1.9883409738541
	self.BulletData["Flight"]		= Vector(0.000000, 0.000000, 0.000000)
	self.BulletData["FrAera"]		= 56.745151519775
	self.BulletData["Id"]		= "85mmRT"
	self.BulletData["KETransfert"]		= 0.10000000149012
	self.BulletData["LimitVel"]		= 100
	self.BulletData["Mass"]		= 3.5605669021606
	self.BulletData["Motor"]		= 14927.2578125
	self.BulletData["MuzzleVel"]		= 65.566795349121
	self.BulletData["NotFirstPen"]		= false
	self.BulletData["PenAera"]		= 30.962743759155
	self.BulletData["Pos"]		= Vector(0.000000, 0.000000, 0.000000)
	self.BulletData["ProjLength"]		= 47.740001678467
	self.BulletData["ProjMass"]		= 2.6605668067932
	self.BulletData["PropLength"]		= 9.9127416610718
	self.BulletData["PropMass"]		= 0.89999997615814
	self.BulletData["Ricochet"]		= 60
	self.BulletData["RoundVolume"]		= 3459.013671875
	self.BulletData["ShovePower"]		= 0.10000000149012
	self.BulletData["SlugCaliber"]		= 1.8940789699554
	self.BulletData["SlugDragCoef"]		= 0.001959259621799
	self.BulletData["SlugMV"]		= 1896.4078369141
	self.BulletData["SlugMass"]		= 0.14381197094917
	self.BulletData["SlugPenAera"]		= 2.4121482372284
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]		= 0
	self.BulletData["Type"]		= "HEAT"

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

