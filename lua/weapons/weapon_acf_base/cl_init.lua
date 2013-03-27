include('shared.lua')

SWEP.DrawAmmo			= true
SWEP.DrawWeaponInfoBox	= true
SWEP.BounceWeaponIcon   = true
SWEP.SwayScale			= 2.0					-- The scale of the viewmodel sway
SWEP.BobScale			= 2.0					-- The scale of the viewmodel bob
SWEP.IsACF				= true


/*
local function discoverMuzzle(self)
	local vm = self.Owner:GetViewModel()
	if not (vm and IsValid(vm)) then return end
	
	local atts = vm:GetAttachments()
	PrintTable(atts)
	
	for k, v in pairs(atts) do
		if v.name == "muzzle" then
			return v.id
		end
	end
	
	return 1
end
//*/


function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.defaultFOV = self.Owner:GetFOV()
	//self.Zoomed = false
	/*
	self.VMInstance = self.Owner:GetViewModel()
	if not (self.VMInstance and IsValid(self.VMInstance)) then 
		self.VMInstance = nil
		self.Muzzle = nil
		return
	end
	
	self.VMInstance:SetNoDraw(true)
	
	self.Muzzle = self.WeaponBone and self.VMInstance:LookupBone(self.WeaponBone) or -1
	//*/
end



function SWEP:AdjustMouseSensitivity()
	if self.HasZoom and self.Zoomed then 
		return self.ZoomFOV / self.defaultFOV
	end
	
	return 1
end



function SWEP:DrawScope()
	if not self.Zoomed then return end
	
	local scrw = ScrW()
	local scrw2 = ScrW() / 2
	local scrh = ScrH()
	local scrh2 = ScrH() / 2

	surface.SetDrawColor(0, 0, 0, 255) 

	local rectsides = ((scrw - scrh) / 2) * 0.7

	surface.SetDrawColor(0, 0, 0, 255) 
	
	local baselen = rectsides + scrw * 0.18
	local basewide = scrh * 0.01
	local basewide2 = basewide * 2
	local centersep = scrh * 0.02
	surface.DrawRect(0, scrh2 - basewide, baselen, basewide2)
	surface.DrawRect(scrw - baselen, scrh2 - basewide, baselen, basewide2)
	surface.DrawRect(scrw2 - basewide, scrh - (baselen - rectsides*1.5), basewide2, (baselen - rectsides*1.5))
	
	surface.DrawLine(0, scrh2, scrw2 - centersep, scrh2)
	surface.DrawLine(scrw2 + centersep, scrh2, scrw, scrh2)
	surface.DrawLine(scrw2, scrh, scrw2, scrh2 + centersep)
	
	surface.DrawCircle(scrw2, scrh2, 2, Color(0,0,0))
	
	surface.SetMaterial(Material("gmod/scope"))
	surface.DrawTexturedRect(rectsides, 0, scrw - rectsides * 2, scrh)
	
	surface.DrawRect(0, 0, rectsides + 2, scrh)
	surface.DrawRect(scrw - rectsides - 2, 0, rectsides + 4, scrh)
	
	return false
end



/**
local function DrawHUD()
	local self = LocalPlayer():GetActiveWeapon()
	if not (IsValid(self) and self.IsACF) then return end
	
	scrpos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
	
	//surface.DrawCircle(scrpos.x, scrpos.y, ScrW() / 2 * self.Inaccuracy / LocalPlayer():GetFOV() , Color(0, 255, 0) )
	surface.DrawCircle(scrpos.x, scrpos.y, ScrW() / 2 * self.Inaccuracy / LocalPlayer():GetFOV() , HSVToColor( self.Stamina * 120, 1, 1 ) )
end
hook.Add("HUDPaint", "XCF_BaseSWEP_DrawHUD", DrawHUD)
//*/


/*
local function FinishScopeChop(self2)

	local self = self2 or LocalPlayer():GetActiveWeapon()
	if not (IsValid(self) and self.IsACF) then return end
	if !(self.ScopeChopPos and self.ScopeChopPlane and self.ScopeChopping) then return end
	
	render.PopCustomClipPlane()
	render.EnableClipping( false )
	
	self.ScopeChopping = false

end
//hook.Add("PostDrawViewModel", "XCF_BaseSWEP_PostDrawViewModel", FinishScopeChop)



local function SetupScopeChop(self2)
	
	local self = self2 or LocalPlayer():GetActiveWeapon()
	if not (IsValid(self) and self.IsACF) then return end
	if !(self.Muzzle and self.ScopeChopPos and self.ScopeChopAngle) then return end
	
	//self.VMInstance:SetNoDraw(false)
	
	local muzzle = self.VMInstance:GetBoneMatrix(self.Muzzle)
	
	local pos, ang
	if muzzle then
		pos, ang = muzzle:GetTranslation(), muzzle:GetAngles()
	end
			
	if self.ViewModelFlip then
		ang.r = -ang.r
	end
	
	local vpos = self.ScopeChopPos
	local vangle = self.ScopeChopAngle
	
	local drawpos = pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z
	ang:RotateAroundAxis(ang:Up(), vangle.y)
	ang:RotateAroundAxis(ang:Right(), vangle.p)
	ang:RotateAroundAxis(ang:Forward(), vangle.r)
	
	//local origin, norm = self.ScopeChopPos, self.ScopeChopPlane
	local origin, norm = drawpos, ang:Forward()
	//local origin, norm = LocalToWorld(pos, ang, muzzle:GetTranslation(), muzzle:GetAngles())
	//local norm = norm:Forward()
	//origin, norm = LocalToWorld(self.ScopeChopPos, self.ScopeChopPlane:Angle(), self.Muzzle.Pos, self.Muzzle.Ang)
	
	if (origin and norm) then
		render.EnableClipping( true )			
		render.PushCustomClipPlane( norm, norm:Dot( origin ) )
	
		self.ScopeChopping = true
	end

	//self.VMInstance:DrawModel()
	
	//FinishScopeChop(self)
	
	//self.VMInstance:SetNoDraw(true)
	
end
//hook.Add("PreDrawViewModel", "XCF_BaseSWEP_PreDrawViewModel", SetupScopeChop)
//*/



function SWEP:DrawHUD()

	//if not self.Owner:Alive() then return end

	local drawcircle = true
	
	if self.DrawScope and self.Zoomed then
		drawcircle = self:DrawScope()
	end
	
	if drawcircle then
		local scrpos = self.Owner:GetEyeTrace().HitPos:ToScreen()
		surface.DrawCircle(scrpos.x, scrpos.y, ScrW() / 2 * self.Inaccuracy / self.Owner:GetFOV() , HSVToColor( self.Stamina * 120, 1, 1 ) )
	end
	
	//SetupScopeChop(self)

end


/*
function SWEP:Reload()
	self:SetZoom(false)
end
//*/



SWEP.LastWobble = Vector()
SWEP.WobbleTo = Vector()
SWEP.LastWobblePoll = CurTime()
local wobbleinfluence = 0.99
local wobblepoll = math.Rand(0.4, 0.7)
function SWEP:GetViewModelPosition( pos, ang )

	if not CLIENT then return end	// idk.

	if self.LastWobblePoll < CurTime() - wobblepoll then
		self.WobbleTo = self:inaccuracy(Vector(1, 0, 0), self.Inaccuracy)
		self.LastWobblePoll = CurTime()
		wobblepoll = math.Rand(0.4, 0.7)
	end
	
	local trace = LocalPlayer():GetEyeTrace()
	
	//local aim = self.Owner:GetAimVector()
	local aim = (trace.HitPos - trace.StartPos):GetNormalized()
	local wobble = self.LastWobble
	wobble = self.WobbleTo * (1 - wobbleinfluence) + wobble * wobbleinfluence
	self.LastWobble = wobble
	local pos2, aim2 = LocalToWorld(pos, wobble:Angle(), pos, ang)//(aim + wobble):GetNormalized()
	return pos, aim2
end