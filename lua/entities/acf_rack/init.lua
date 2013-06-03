-- init.lua

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')

function ENT:Initialize()
	self.ReloadTime = 1
	self.Ready = true
	self.Firing = nil
	self.NextFire = 0
	self.LastSend = 0
	self.Owner = self
	
	self.IsMaster = true
	self.CurAmmo = 1
	self.Sequence = 1
	
	self.BulletData = {}
		self.BulletData["Type"] = "Empty"
		self.BulletData["PropMass"] = 0
		self.BulletData["ProjMass"] = 0
	
	self.Inaccuracy 	= 1
	
	self.Inputs = Wire_CreateInputs( self, { "Fire" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self, 	{ "Ready",	"Entity",	"Shots Left",	"Fire Rate",	"Muzzle Weight",	"Muzzle Velocity" },
														{ "NORMAL",	"ENTITY",	"NORMAL",		"NORMAL",		"NORMAL",			"NORMAL" } )
	Wire_TriggerOutput(self, "Entity", self)
	self.WireDebugName = "ACF Rack"
end




function ENT:Link( Target )

	-- Don't link if it's not an ammo crate
	if not IsValid( Target ) or Target:GetClass() ~= "acf_ammo" then
		return false, "Racks can only be linked to ammo crates!"
	end
	
	-- Don't link if it's a refill crate
	if Target.BulletData["RoundType"] == "Refill" then
		return false, "Refill crates cannot be linked!"
	end
	
	if self.Id ~= Target.BulletData.Id then
		return false, "This rack doesn't hold that ammo type!"
	end
	
	MakeACF_Rack(self.Owner, self:GetPos(), self:GetAngles(), Target.BulletData.Id, self, Target.BulletData)
	
	self.ReloadTime = ( ( Target.BulletData["RoundVolume"] / 500 ) ^ 0.60 ) * self.RoFmod * self.PGRoFmod
	self.RateOfFire = 60 / self.ReloadTime
	Wire_TriggerOutput( self, "Fire Rate", self.RateOfFire )
	Wire_TriggerOutput( self, "Muzzle Weight", math.floor( Target.BulletData["ProjMass"] * 1000 ) )
	Wire_TriggerOutput( self, "Muzzle Velocity", math.floor( Target.BulletData["MuzzleVel"] * ACF.VelScale ) )

	return true, "This rack now loads that ammo!"
	
end




function ENT:Unlink( Target )

	return false, "Racks do not support permanent ammo-links!"
	
end




local WireTable = { "gmod_wire_adv_pod", "gmod_wire_pod", "gmod_wire_keyboard", "gmod_wire_joystick", "gmod_wire_joystick_multi" }

function ENT:GetUser( inp )
	if inp:GetClass() == "gmod_wire_adv_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_keyboard" then
		if inp.ply then
			return inp.ply 
		end
	elseif inp:GetClass() == "gmod_wire_joystick" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_joystick_multi" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_expression2" then
		if inp.Inputs["Fire"] then
			return self:GetUser(inp.Inputs["Fire"].Src) 
		elseif inp.Inputs["Shoot"] then
			return self:GetUser(inp.Inputs["Shoot"].Src) 
		elseif inp.Inputs then
			for _,v in pairs(inp.Inputs) do
				if table.HasValue(WireTable, v.Src:GetClass()) then
					return self:GetUser(v.Src) 
				end
			end
		end
	end
	return inp.Owner or inp:GetOwner()
	
end




function ENT:TriggerInput( iname , value )
	
	if ( iname == "Fire" and value > 0 and ACF.GunfireEnabled ) then
		if self.NextFire < CurTime() then
			self.User = self:GetUser(self.Inputs["Fire"].Src)
			if not IsValid(self.User) then self.User = self.Owner end
			self:FireMissile()
			self:Think()
		end
		self.Firing = true
	elseif ( iname == "Fire" and value <= 0 ) then
		self.Firing = false
	end		
end




function RetDist( enta, entb )
	if not ((enta and enta:IsValid()) or (entb and entb:IsValid())) then return 0 end
	return enta:GetPos():Distance(entb:GetPos())
end




function ENT:Think()

	local Time = CurTime()
	if self.LastSend+1 <= Time then
		if( self.MagSize ) then
			Wire_TriggerOutput(self, "Shots Left", self.MagSize - self.CurrentShot)
		else
			Wire_TriggerOutput(self, "Shots Left", 1)
		end
		
		self:SetNetworkedBeamString("GunType",self.Id)
		self:SetNetworkedBeamInt("Ammo",Ammo)
		self:SetNetworkedBeamString("Type",self.BulletData["Type"])
		self:SetNetworkedBeamInt("Mass",self.BulletData["ProjMass"]*100)
		self:SetNetworkedBeamInt("Propellant",self.BulletData["PropMass"]*1000)
		self:SetNetworkedBeamInt("FireRate",self.RateOfFire)
		
		self.LastSend = Time
	
	end
	
	if self.NextFire <= Time and self.CurrentShot >= 0 and self.CurrentShot < self.MagSize then
		self.Ready = true
		Wire_TriggerOutput(self, "Ready", 1)
		if self.Firing then
			self:FireMissile()
		end
	end

	self:NextThink(Time)
	return true
	
end




function ENT:LoadAmmo( AddTime, Reload )
		
	if self.CurrentShot == 0 then return false end
		
	self.CurrentShot = math.Clamp(self.CurrentShot - 1, 0, self.MagSize)
	
	self.NextFire = CurTime() + self.ReloadTime
	if AddTime then
		self.NextFire = CurTime() + self.ReloadTime + AddTime
	end
	
	self:OnLoaded()
	
	self:Think()
	return true	
	
end




function ENT:OnLoaded()
	
end




function MakeACF_Rack (Owner, Pos, Angle, Id, UpdateRack, UpdateBullet)

	if not Owner:CheckLimit("_acf_gun") then return false end
	
	local Rack = UpdateRack or ents.Create("acf_rack")
	local List = list.Get("ACFEnts")
	local Classes = list.Get("ACFClasses")
	if not Rack:IsValid() then return false end
	Rack:SetAngles(Angle)
	Rack:SetPos(Pos)
	if not UpdateRack then 
		Rack:Spawn()
		Owner:AddCount("_acf_gun", Rack)
		Owner:AddCleanup( "acfmenu", Rack )
	end
	
	Rack:SetPlayer(Owner)
	Rack.Owner = Owner
	Rack.Id = Id
	Rack.Caliber	= List["Guns"][Id]["caliber"]
	Rack.Model = List["Guns"][Id]["model"]
	Rack.Mass = List["Guns"][Id]["weight"]
	Rack.Class = List["Guns"][Id]["gunclass"]
	-- Custom BS for karbine. Per Rack ROF.
	Rack.PGRoFmod = 1
	if(List["Guns"][Id]["rofmod"]) then
		Rack.PGRoFmod = math.max(0, List["Guns"][Id]["rofmod"])
	end
	-- Custom BS for karbine. Magazine Size, Mag reload Time
	Rack.CurrentShot = 0
	Rack.MagSize = 1
	if(List["Guns"][Id]["magsize"]) then
		Rack.MagSize = math.max(Rack.MagSize, List["Guns"][Id]["magsize"])
	end
	Rack.MagReload = 0
	if(List["Guns"][Id]["magreload"]) then
		Rack.MagReload = math.max(Rack.MagReload, List["Guns"][Id]["magreload"])
	end
	-- self.CurrentShot, self.MagSize, self.MagReload
	
	Rack:SetNWString( "Class" , Rack.Class )
	Rack:SetNWString( "ID" , Rack.Id )
	Rack.Muzzleflash = Classes["GunClass"][Rack.Class]["muzzleflash"]
	Rack.RoFmod = Classes["GunClass"][Rack.Class]["rofmod"]
	Rack.Sound = Classes["GunClass"][Rack.Class]["sound"]
	Rack:SetNWString( "Sound", Rack.Sound )
	Rack.Inaccuracy = Classes["GunClass"][Rack.Class]["spread"]
	
	if not UpdateRack or Rack.Model ~= Rack:GetModel() then
		Rack:SetModel( Rack.Model )	
	
		Rack:PhysicsInit( SOLID_VPHYSICS )      	
		Rack:SetMoveType( MOVETYPE_VPHYSICS )     	
		Rack:SetSolid( SOLID_VPHYSICS )
	end
	
	local Attach, Muzzle = Rack:GetNextLaunchMuzzle()
	Rack.Muzzle = Rack:WorldToLocal(Muzzle.Pos)
	
	local phys = Rack:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass( Rack.Mass ) 
	end 
	
	if UpdateBullet then
		Rack.BulletData = table.Copy(UpdateBullet)
	end
	
	return Rack
	
end

list.Set( "ACFCvars", "acf_rack" , {"id"} )
duplicator.RegisterEntityClass("acf_rack", MakeACF_Rack, "Pos", "Angle", "Id")




function ENT:GetNextLaunchMuzzle()
	local shot = self.CurrentShot + 1
	
	local trymissile = "missile" .. shot
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetAttachment(attach) end
	
	trymissile = "missile1"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetAttachment(attach) end
	
	trymissile = "muzzle"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetAttachment(attach) end
	
	return 0, {self:GetPos(), self:GetAngles()}
end




function ENT:FireMissile()

	local CanDo = hook.Run("ACF_FireShell", self, self.BulletData )
	if CanDo == false then return end
	
	if self.Ready and self:GetPhysicsObject():GetMass() >= self.Mass and not self:GetParent():IsValid() then
	
		Blacklist = {}
		if not ACF.AmmoBlacklist[self.BulletData["Type"]] then
			Blacklist = {}
		else
			Blacklist = ACF.AmmoBlacklist[self.BulletData["Type"]]	
		end
		
		if ( ACF.RoundTypes[self.BulletData["Type"]] and !table.HasValue( Blacklist, self.Class ) ) then		--Check if the roundtype loaded actually exists
		
			local attach, muzzle = self:GetNextLaunchMuzzle()
			//PrintTable(muzzle)
			local MuzzlePos = muzzle.Pos
			local MuzzleVec = muzzle.Ang:Forward()
			local Inaccuracy = VectorRand() / 360 * self.Inaccuracy
			
			//print("\n\n\nfiredata\n\n\n")
			//PrintTable(self.BulletData)
			
			self.BulletData["Pos"] = MuzzlePos
			self.BulletData["Flight"] = (MuzzleVec+Inaccuracy):GetNormalized() * self.BulletData["MuzzleVel"] * 39.37 + self:GetVelocity()
			self.BulletData["Owner"] = self.User
			self.BulletData["Gun"] = self
			self.BulletData["Filter"] = {self}
			local CreateShell = ACF.RoundTypes[self.BulletData["Type"]]["create"]
			CreateShell( self, self.BulletData )
			
			self:MuzzleEffect( MuzzlePos , MuzzleVec )
		
			//TODO: simulate backblast
			/*
			local Gun = self:GetPhysicsObject()  	
			if (Gun:IsValid()) then 	
				Gun:ApplyForceCenter( self:GetForward() * -(self.BulletData["ProjMass"] * self.BulletData["MuzzleVel"] * 39.37 + self.BulletData["PropMass"] * 3000 * 39.37))			
			end
			//*/
			
			self.Ready = false
			self.CurrentShot = math.min(self.CurrentShot + 1, self.MagSize)
			Wire_TriggerOutput(self, "Ready", 0)
			self.NextFire = CurTime() + self.ReloadTime
			
			
		else
			self.CurrentShot = 0
			self.Ready = false
			self.NextFire = CurTime() + self.ReloadTime
			Wire_TriggerOutput(self, "Ready", 0)
			self:LoadAmmo(false, true)	
		end
	else
		self:EmitSound("weapons/pistol/pistol_empty.wav",500,100)
	end

end




function ENT:MuzzleEffect()
	
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData["PropMass"] )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"]  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )

end




function ENT:ReloadEffect()

	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( 0 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"]  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )
	
end




function ENT:PreEntityCopy()

	local projclass = self.BulletData.ProjClass// or error("Tried to copy an ACF Rack but it was loaded with invalid ammo! (" .. tostring(self.BulletData.Id) .. ", " .. tostring(self.BulletData.Type) .. ")")
	if projclass then
		local squashedammo = projclass.GetCompact(self.BulletData)
		duplicator.StoreEntityModifier( self, "ACFRackAmmo", squashedammo )
	end
	
	//Wire dupe info
	local DupeInfo = WireLib.BuildDupeInfo(self)
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
	end
	
end




function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	local squashedammo = Ent.EntityMods.ACFRackAmmo
	if Ent.EntityMods and squashedammo then
		local ammoclass = XCF.ProjClasses[squashedammo.ProjClass]// or error("Tried to copy an ACF Rack but it was loaded with invalid ammo! (" .. tostring(squashedammo.ProjClass) ", " .. tostring(squashedammo.Id) .. ", " .. tostring(squashedammo.Type) .. ")")
		if ammoclass then
			self.BulletData = ammoclass.GetExpanded(squashedammo)
			Ent.EntityMods.ACFRackAmmo = nil
		end
	end
	
	//Wire dupe info
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end

end




function ENT:OnRemove()
	Wire_Remove(self.Entity)
end

function ENT:OnRestore()
    Wire_Restored(self.Entity)
end