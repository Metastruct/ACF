-- init.lua

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')


local MUZZLE = "xcfRkMzl"
local RELOAD = "xcfRkRld"


local permittedRackAmmo = 
{
	Rocket = true,
	Bomb = true
}


function ENT:Initialize()

	self.SpecialHealth = true	--If true needs a special ACF_Activate function
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
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
		self.BulletData["FillerMass"] = 0
		self.BulletData["ConeAng"] = 0
		self.BulletData["PropLength"] = 0
		self.BulletData["ProjLength"] = 0
		self.BulletData["PropMass"] = 0
		self.BulletData["ProjMass"] = 0
	
	self.Inaccuracy 	= 1
	
	self.Inputs = Wire_CreateInputs( self, { "Fire" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self, 	{ "Ready",	"Entity",	"Shots Left",	"Fire Rate",	"Muzzle Weight",	"Muzzle Velocity" },
														{ "NORMAL",	"ENTITY",	"NORMAL",		"NORMAL",		"NORMAL",			"NORMAL" } )
	Wire_TriggerOutput(self, "Entity", self)
	Wire_TriggerOutput(self, "Ready", 1)
	self.WireDebugName = "ACF Rack"
	
	self.lastCol = self:GetColor() or Color(255, 255, 255)
	self.nextColCheck = CurTime() + 2
end



function ENT:ACF_Activate( Recalc )
	
	local EmptyMass = self.Mass --math.max(self.Mass, self:GetPhysicsObject():GetMass() - self.Mass)

	self.ACF = self.ACF or {} 
	
	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end
	
	//print(self.ACF.Volume, ACF.Threshold)
	
	local Armour = EmptyMass*1000 / self.ACF.Aera / 0.78 --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume/ACF.Threshold							--Setting the threshold of the prop aera gone 
	local Percent = 1 
	
	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health/self.ACF.MaxHealth
	end
	
	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent/2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = (self:GetPhysicsObject():GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"
	
end



//* TODO
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )	--This function needs to return HitRes

	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	
	//printByName(HitRes)
	
	local curammo = self.MagSize - self.CurrentShot
	
	// Detonate rack if damage causes ammo rupture, or a penetrating shot hits some ammo.
	if not HitRes.Kill then
		local Ratio = (HitRes.Damage * (self.ACF.MaxHealth - self.ACF.Health) / self.ACF.MaxHealth)^0.2
		local ammoRatio = self.MagSize / curammo
		local chance = math.Rand(0,1)
		//print(Ratio, ammoRatio, chance, ( Ratio * ammoRatio ) > chance, HitRes.Overkill > 0 and chance > (1 - ammoRatio))
		if ( Ratio * ammoRatio ) > chance or HitRes.Overkill > 0 and chance > (1 - ammoRatio) then  
			self.Inflictor = Inflictor
			HitRes.Kill = true
		end
	end
	
	if HitRes.Kill then
		local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
		if CanDo == false then return HitRes end
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		if curammo > 0 then
			self.Ammo = curammo
			ACF_AmmoExplosion( self , self:GetPos() )
		else
			ACF_HEKill( self , VectorRand() )
		end
	end
	
	return HitRes --This function needs to return HitRes
end
//*/




function ENT:Link( Target )

	-- Don't link if it's not an ammo crate
	if not IsValid( Target ) or Target:GetClass() ~= "acf_ammo" then
		return false, "Racks can only be linked to ammo crates!"
	end
	
	-- Don't link if it's a refill crate
	if Target.BulletData["RoundType"] == "Refill" or Target.BulletData["Type"] == "Refill" then
		return false, "Refill crates cannot be linked!"
	end
	
	if self.Id ~= Target.BulletData.Id then
		return false, "This rack doesn't hold that ammo type!"
	end
	
	MakeACF_Rack(self.Owner, self:GetPos(), self:GetAngles(), Target.BulletData.Id, self, Target.BulletData)
	
	//self.ReloadTime = ( ( Target.BulletData["RoundVolume"] / 500 ) ^ 0.60 ) * self.RoFmod * self.PGRoFmod
	//self.RateOfFire = 60 / self.ReloadTime
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

	local color = self:GetColor()
	local lastCol = self.lastCol
	if (CurTime() > self.nextColCheck) and (color.r ~= lastCol.r or color.g ~= lastCol.g or color.b ~= lastCol.b or color.a ~= lastCol.a) then
		self.nextColCheck = CurTime() + 2
		self.lastCol = color
		MakeACF_Rack(self.Owner, self:GetPos(), self:GetAngles(), self.BulletData.Id, self)
	end


	local Time = CurTime()
	if self.LastSend+1 <= Time then
		local Ammo = self.MagSize - self.CurrentShot
		
		Wire_TriggerOutput(self, "Shots Left", Ammo)
		
		self:SetNetworkedBeamString("GunType",		self.Id)
		self:SetNetworkedBeamInt(	"Ammo",			Ammo)
		self:SetNetworkedBeamString("Type",			self.BulletData["Type"])
		self:SetNetworkedBeamInt(	"Mass",			self.BulletData["ProjMass"]*100)
		self:SetNetworkedBeamInt(	"Propellant",	self.BulletData["PropMass"]*1000)
		self:SetNetworkedBeamInt(	"Filler", 		(self.BulletData["FillerMass"] or 0)*1000)
		self:SetNetworkedBeamInt(	"FireRate",		self.RateOfFire)
		
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
	local Ammo = self.MagSize - self.CurrentShot
	local curtime = CurTime()
	if not self.Ready and not (Ammo == 0 and curtime > self.NextFire) then return false end
		
	self.CurrentShot = math.Clamp(self.CurrentShot - Reload, 0, self.MagSize)
	
	Ammo = self.MagSize - self.CurrentShot
	self:SetNetworkedBeamInt("Ammo",	Ammo)
	
	local phys = self:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass(self.Mass + (self.BulletData.ProjMass or 0) * Ammo)
	end 
	
	self.NextFire = curtime + self.ReloadTime
	if AddTime then
		self.NextFire = curtime + self.ReloadTime + AddTime
	end
	self.Ready = false
	Wire_TriggerOutput(self, "Ready", 0)
	
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
	Rack.BulletData.Id = Id
	
	local gundef = List["Guns"][Id] or error("Couldn't find the " .. tostring(Id) .. " gun-definition in acfgunlist.lua!")
	
	Rack.Caliber	= gundef["caliber"]
	Rack.Model = gundef["model"]
	Rack.Mass = gundef["weight"]
	Rack.Class = gundef["gunclass"]
	-- Custom BS for karbine. Per Rack ROF.
	Rack.PGRoFmod = 1
	if(gundef["rofmod"]) then
		Rack.PGRoFmod = math.max(0, gundef["rofmod"])
	end
	-- Custom BS for karbine. Magazine Size, Mag reload Time
	
	Rack.MagSize = 1
	if(gundef["magsize"]) then
		Rack.MagSize = math.max(Rack.MagSize, gundef["magsize"] or 1)
	end
	Rack.MagReload = 0
	if(gundef["magreload"]) then
		Rack.MagReload = math.max(Rack.MagReload, gundef["magreload"])
	end
	
	if not UpdateRack then
		Rack.CurrentShot = 0
	else
		Rack.CurrentShot = math.Clamp(Rack.CurrentShot, 0, Rack.MagSize)
	end
	-- self.CurrentShot, self.MagSize, self.MagReload
	
	local gunclass = Classes["GunClass"][Rack.Class] or error("Couldn't find the " .. tostring(Rack.Class) .. " gun-class in acfgunlist.lua!")
	
	Rack:SetNWString( "Class" , Rack.Class )
	Rack:SetNWString( "ID" , Rack.Id )
	Rack.Muzzleflash = gundef.muzzleflash or gunclass.muzzleflash or ""
	Rack.RoFmod = gunclass["rofmod"]
	Rack.Sound = gundef.sound or gunclass.sound or "vo/npc/barney/ba_turret.wav"
	Rack:SetNWString( "Sound", Rack.Sound )
	Rack.Inaccuracy = gunclass["spread"]
	
	if not UpdateRack or Rack.Model ~= Rack:GetModel() then
		Rack:SetModel( Rack.Model )	
	
		Rack:PhysicsInit( SOLID_VPHYSICS )      	
		Rack:SetMoveType( MOVETYPE_VPHYSICS )     	
		Rack:SetSolid( SOLID_VPHYSICS )
	end
	
	local Attach, Muzzle = Rack:GetNextLaunchMuzzle()
	Rack.Muzzle = Rack:WorldToLocal(Muzzle.Pos)
	
	if UpdateBullet then
		Rack.BulletData = table.Copy(UpdateBullet)
	end
	Rack.BulletData.Colour = Rack:GetColor()
	
	local phys = Rack:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:SetMass(Rack.Mass + (Rack.BulletData.ProjMass or 0) * Rack.MagSize)
	end 	
	
	local volume = Rack.BulletData["RoundVolume"]
	if volume then
		Rack.ReloadTime = ( ( volume / 500 ) ^ 0.60 ) * Rack.RoFmod * Rack.PGRoFmod
		Rack.RateOfFire = 60 / Rack.ReloadTime
	end
	
	local bdata = Rack.BulletData
	bdata = bdata.ProjClass and (bdata.ProjClass.GetCompact(bdata)) or bdata
	
	--[[print("--", "rack bdata")
	printByName(bdata)
	print("--", "end rack bdata")]]
	
		--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	Rack.RoundId = bdata.Id		--Weapon this round loads into, ie 140mmC, 105mmH ...
	Rack.RoundType = bdata.Type		--Type of round, IE AP, HE, HEAT ...
	Rack.RoundPropellant = bdata.PropLength or 0--Lenght of propellant
	Rack.RoundProjectile = bdata.ProjLength or 0--Lenght of the projectile
	Rack.RoundData5 = ( bdata.FillerVol or bdata.Data5 or 0 )
	Rack.RoundData6 = ( bdata.ConeAng or bdata.Data6 or 0 )
	Rack.RoundData7 = ( bdata.Data7 or 0 )
	Rack.RoundData8 = ( bdata.Data8 or 0 )
	Rack.RoundData9 = ( bdata.Data9 or 0 )
	Rack.RoundData10 = ( bdata.Tracer or bdata.Data10 or 0 )
	
	hook.Call("ACF_RackCreate", nil, Rack)
	
	return Rack
	
end

list.Set( "ACFCvars", "acf_rack" , {"id"} )
duplicator.RegisterEntityClass("acf_rack", MakeACF_Rack, "Pos", "Angle", "Id")




function ENT:GetNextLaunchMuzzle()
	local shot = self.CurrentShot + 1
	
	local trymissile = "missile" .. shot
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(self.Id, attach, trymissile) end
	
	trymissile = "missile1"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(self.Id, attach, trymissile) end
	
	trymissile = "muzzle"
	local attach = self:LookupAttachment(trymissile)
	if attach ~= 0 then return attach, self:GetMunitionAngPos(self.Id, attach, trymissile) end
	
	return 0, {self:GetPos(), self:GetAngles()}
end




function ENT:FireMissile()

	local CanDo = hook.Run("ACF_FireShell", self, self.BulletData )
	if CanDo == false then return end
	
	if self.Ready and self:GetPhysicsObject():GetMass() >= self.Mass and not self:GetParent():IsValid() then
		
		local type = self.BulletData["Type"]
		local Blacklist = ACF.AmmoBlacklist[type] or {}
		local ammoblist = ACF.Weapons.Guns[self.BulletData["Id"]].blacklist or {}
		
		if ACF.RoundTypes[type] and not table.HasValue( Blacklist, self.Class ) and not ammoblist[type] then		--Check if the roundtype loaded actually exists
		
			local attach, muzzle = self:GetNextLaunchMuzzle()
			//PrintTable(muzzle)
			local MuzzlePos = muzzle.Pos
			local MuzzleVec = muzzle.Ang:Forward()
			local Inaccuracy = VectorRand() / 360 * self.Inaccuracy
			
			//print("\n\n\nfiredata\n\n\n")
			//PrintTable(self.BulletData)
			
			self.BulletData["Pos"] = MuzzlePos
			self.BulletData["Forward"] = MuzzleVec
			self.BulletData["Flight"] = (MuzzleVec+Inaccuracy):GetNormalized() * self.BulletData["MuzzleVel"] * 39.37 + self:GetVelocity()
			self.BulletData["Owner"] = self.User
			self.BulletData["Gun"] = self
			self.BulletData["Filter"] = {self}
			local CreateShell = ACF.RoundTypes[type]["create"]
			CreateShell( self, self.BulletData )
			
			self:MuzzleEffect( attach )
		
			//TODO: simulate backblast
			/*
			local Gun = self:GetPhysicsObject()  	
			if (Gun:IsValid()) then 	
				Gun:ApplyForceCenter( self:GetForward() * -(self.BulletData["ProjMass"] * self.BulletData["MuzzleVel"] * 39.37 + self.BulletData["PropMass"] * 3000 * 39.37))			
			end
			//*/
			
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self.CurrentShot = math.min(self.CurrentShot + 1, self.MagSize)
			self.NextFire = CurTime() + self.ReloadTime
			
			Ammo = self.MagSize - self.CurrentShot
			self:SetNetworkedBeamInt("Ammo",	Ammo)
			
			local phys = self:GetPhysicsObject()  	
			if (phys:IsValid()) then 
				phys:SetMass(self.Mass + (self.BulletData.ProjMass or 0) * Ammo)
			end 
			
		else
			//self.CurrentShot = 0
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self.NextFire = CurTime() + self.ReloadTime
			self:LoadAmmo(false, true)	
		end
	else
		self:EmitSound("weapons/pistol/pistol_empty.wav",500,100)
	end

end



util.AddNetworkString(MUZZLE)
function ENT:MuzzleEffect(attach)
	--print("Muzzle out!", self.BulletData.NetUID)

	net.Start(MUZZLE)
		net.WriteEntity(self)
		net.WriteDouble(self.BulletData.NetUID)
		net.WriteDouble(self.ReloadTime)
		net.WriteDouble(attach or 0)
	net.Broadcast()

end

util.AddNetworkString(RELOAD)
function ENT:ReloadEffect()

	--print("Reload out!", self.ReloadTime)

	net.Start(RELOAD)
		net.WriteEntity(self)
		net.WriteDouble(self.ReloadTime)
	net.Broadcast()
	
end
/*
function ENT:MuzzleEffect( attach )
	
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData["PropMass"] )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetRadius(attach or 0)
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
//*/




function ENT:PreEntityCopy()

	local projclass = self.BulletData.ProjClass// or error("Tried to copy an ACF Rack but it was loaded with invalid ammo! (" .. tostring(self.BulletData.Id) .. ", " .. tostring(self.BulletData.Type) .. ")")
	if projclass then
		local squashedammo = projclass.GetCompact(self.BulletData)
		//printByName(squashedammo)
		duplicator.StoreEntityModifier( self, "ACFRackAmmo", squashedammo )
	end
	
	//Wire dupe info
	local DupeInfo = WireLib.BuildDupeInfo(self)
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
	end
	
end




function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end

	local squashedammo = Ent.EntityMods and Ent.EntityMods.ACFRackAmmo or nil
	/*
	print("SQUASHED AMMO:")
	printByName(squashedammo)
	//*/
	if squashedammo then
		local ammoclass = XCF.ProjClasses[squashedammo.ProjClass]// or error("Tried to copy an ACF Rack but it was loaded with invalid ammo! (" .. tostring(squashedammo.ProjClass) ", " .. tostring(squashedammo.Id) .. ", " .. tostring(squashedammo.Type) .. ")")
		//print(squashedammo.ProjClass, permittedRackAmmo[squashedammo.ProjClass])
		if ammoclass and permittedRackAmmo[squashedammo.ProjClass] then
			self.BulletData = ammoclass.GetExpanded(squashedammo)
			//printByName(self.BulletData)
			Ent.EntityMods.ACFRackAmmo = nil
		end
	end
	
	//printByName(self.BulletData)
	
	MakeACF_Rack(self.Owner, self:GetPos(), self:GetAngles(), self.BulletData.Id, self, self.BulletData)

end




function ENT:OnRemove()
	Wire_Remove(self.Entity)
end

function ENT:OnRestore()
    Wire_Restored(self.Entity)
end