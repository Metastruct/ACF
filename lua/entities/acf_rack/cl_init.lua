-- cl_init.lua

include ("shared.lua")

ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()	
    Wire_Render(self)
	
	local Ammo = math.max(self:GetNetworkedBeamInt("Ammo"), 0)
	if not self.munitionVis and self.gunType then return end
	local attach, angpos, attachname, mountpoint, class, classtable, visEnt
	//print("ammo", Ammo)
	local modelcount = ACF.Weapons.Guns[self.gunType].magsize or 1
	for i=modelcount, modelcount-Ammo+1, -1 do
		attachname = "missile" .. i
		attach = self:LookupAttachment(attachname)
		if attach ~= 0 then
			angpos = self:GetAttachment(attach)
			class = ACF.Weapons.Guns[self.gunType].gunclass
			classtable = ACF.Classes.GunClass[class]
			mountpoint = classtable.mountpoints[attachname] or {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0, 0, -1)}
			angpos.Pos = angpos.Pos + self:LocalToWorld(mountpoint.offset) - self:GetPos()
			//angpos.Pos = angpos.Pos + (self:LocalToWorld(mountpoint.scaledir) - self:GetPos()) * ACF.Weapons.Guns[self.gunType].caliber / 2.54
			
			visEnt = self.munitionVis[i]
			if IsValid(visEnt) then
				visEnt:SetNoDraw(false)
				visEnt:SetPos(angpos.Pos)
				visEnt:SetAngles(angpos.Ang)
				//print("drawing", class, "at", angpos.Pos)
				visEnt:DrawModel()
				visEnt:SetNoDraw(true)
			end
		end
	end
end

function ENT:DoNormalDraw()
	local e = self
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 256) then
		if(self:GetOverlayText() ~= "") then
			AddWorldTip(e:EntIndex(),self:GetOverlayText(),0.5,e:GetPos(),e)
		end
	end
end


function ENT:Think()
	local gunType = self:GetNetworkedBeamString("GunType")
	if gunType and gunType ~= self.gunType then
		local guntbl = ACF.Weapons.Guns[gunType] or {round = {}}
		local visModel = guntbl.round.rackmdl or guntbl.round.model or "models/munitions/round_100mm_shot.mdl"
		//print(visModel)
		if self.munitionVis then
			for i, mdl in pairs(self.munitionVis) do
				mdl:Remove()
			end
		end
		
		local modelcount = ACF.Weapons.Guns[gunType].magsize or 1
		self.munitionVis = {}
		for i=1, modelcount do
			local visEnt = ents.CreateClientProp(visModel)
			visEnt:SetModel(visModel)
			visEnt:Spawn()
			visEnt:SetNoDraw(true)
			visEnt:SetParent(self)
			self.munitionVis[i] = visEnt
		end
		
		self.gunType = gunType
	end
end

function ENT:Initialize()
	self.munitionVis = nil
	self.gunType = ""
end

function ENT:Animate( Class, ReloadTime, LoadOnly )

end
