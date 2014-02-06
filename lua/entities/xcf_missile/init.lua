
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
PrecacheParticleSystem( "Rocket Motor" )

function ENT:Initialize()
	
	self.BulletData = {}
		/* rpg
	self.BulletData["BlastRadius"]			= 53.542728888373
	self.BulletData["BoomPower"]			= 2.9305305970856
	self.BulletData["Caliber"]			= 8.5
	self.BulletData["CasingMass"]			= 0.29570050752128
	self.BulletData["ConeAng"]			= 60
	self.BulletData["Cutout"]			= 0.35416583847288
	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.0037179919757052
	self.BulletData["Drift"]			= 5.567397921999
	self.BulletData["FillerMass"]			= 1.2305305970856
	self.BulletData["FillerVol"]			= 50000
	self.BulletData["FrAera"]			= 56.74515
	self.BulletData["Id"]			= "85mmRK"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]			= 3.2262311046069
	self.BulletData["Motor"]			= 24406.187110267
	self.BulletData["MuzzleVel"]			= 114
	self.BulletData["PenAera"]			= 30.962743577239
	self.BulletData["ProjLength"]			= 21
	self.BulletData["ProjMass"]			= 1.5262311046069
	self.BulletData["PropLength"]			= 18.724067166974
	self.BulletData["PropMass"]			= 1.7
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 2254.14815
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 1.9165880508742
	self.BulletData["SlugDragCoef"]			= 0.0018928390741967
	self.BulletData["SlugMV"]			= 1057.3584926577
	self.BulletData["SlugMass"]			= 0.1524174729
	self.BulletData["SlugPenAera"]			= 2.4610825543958
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "HEAT"
	//*/
	
	//* dumbfire
	self.BulletData["BlastRadius"]			= 155.65293089663
	self.BulletData["BoomPower"]			= 42.120393621566
	self.BulletData["Caliber"]			= 17
	self.BulletData["CasingMass"]			= 7.6978450405652
	self.BulletData["ConeAng"]			= 60
	self.BulletData["Cutout"]			= 2.960609598546
	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.00058315034670604
	self.BulletData["Drift"]			= 1.4167910854076
	self.BulletData["FillerMass"]			= 31.225324821566
	self.BulletData["FillerVol"]			= 50000
	self.BulletData["FrAera"]			= 226.9806
	self.BulletData["Id"]			= "170mmRK"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]			= 49.818238662132
	self.BulletData["Motor"]			= 4899.6914896059
	self.BulletData["MuzzleVel"]			= 39.37
	self.BulletData["PenAera"]			= 100.5982506735
	self.BulletData["ProjLength"]			= 110
	self.BulletData["ProjMass"]			= 38.923169862132
	self.BulletData["PropLength"]			= 30
	self.BulletData["PropMass"]			= 10.8950688
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 31777.284
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 3.8331761017484
	self.BulletData["SlugDragCoef"]			= 0.00094641953709837
	self.BulletData["SlugMV"]			= 2455.7784689146
	self.BulletData["SlugMass"]			= 1.2193397832
	self.BulletData["SlugPenAera"]			= 7.9960808097539
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "HEAT"
	//*/

	self.BulletData["Crate"] 			= -1
	
	
	
	local cvarGrav = GetConVar("sv_gravity")
	self.BulletData.Accel = Vector(0,0,-cvarGrav:GetInt())
	
	
	//self.Owner = self.Entity:GetVar( "Owner", self.Entity )
	self.Model = "models/missiles/aim54.mdl"
	//self.Model = "models/props_vehicles/car005a_physics.mdl"
		
	self:SetModel( Model(self.Model) )
	//self.Entity:SetNoDraw(false)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass( self.BulletData.Mass ) 
	end 
		
	local Time = CurTime()
	self.ThinkDelay = 0.01
	
	self.Entity:NextThink( Time + self.ThinkDelay )
	
	self.Owner = self:GetOwner()
end



local function getParentRecursive(child)
	//print("child = ", child )
	if !(child != nil and IsValid(child)) then return nil end
	local parent = child:GetParent()
	//print("parent = ", parent )
	return getParentRecursive(parent) or child
end



function ENT:Launch()
	self.Flying = true
	
	local launcher = self.Entity:GetParent()
	local addvel
	if launcher and IsValid(launcher) then
		launcher = getParentRecursive(launcher) or launcher
		//print("launcher = ", launcher)
	
		//TODO: get velocity at point instead of copying vel.  easy to do.
		local phys = launcher:GetPhysicsObject()
		
		if phys then
			addvel = phys:GetVelocity()
		else
			addvel = launcher:GetVelocity()
		end
	else
		addvel = self.Entity:GetPhysicsObject():GetVelocity()
	end
	
	self.BulletData.Pos = self.Entity:GetPos()
	self.BulletData.Flight = addvel + self.Entity:GetForward()*self.BulletData.MuzzleVel*39.34
	self.BulletData.Dir = self.BulletData.Flight:GetNormalized()
	self.BulletData.FlightTime = 0
		
	//*
	if self.BulletData.Cutout > 0 then
		self.Trail = ents.Create( "info_particle_system" )
		self.Trail:SetPos(self.Entity:GetPos())
		self.Trail:SetAngles(self.BulletData.Flight:Angle())
		self.Trail:SetKeyValue( "effect_name", "Rocket Motor")
		self.Trail:SetKeyValue( "start_active", "1")
		self.Trail:Spawn()
		self.Trail:Activate()
		self.Trail:SetParent(self.Entity)
		self.Trail:Fire("SetParentAttachment", "exhaust", 0)
		self:EmitSound("cannon/missilefire.wav",100,100) 
	end
	//*/
	
	local Time = CurTime()
	
	self.Guidance = Vector(0,0,0)
	self.FutureCutout = Time + self.BulletData.Cutout
	

	self.KillAction = true	
	self.DamageAction = true
	self.Filter = { self.Entity , self.Owner }
	self.Traveled = 0
	self.BulletData.LastThink = Time - 0.01
	
	self.BulletIndex = -1
	//self:BecomeCrate()
	
	self:Think()
end




function ENT:Think()
 	
	if self.Flying then
		self:CalcFlight()
	elseif self.IsCrate and self.MadeBullet and not ACF.Bullet[self.BulletIndex] then
		self.Entity:Remove()
	end
	
	return true

end




function ENT:CalcFlight()

	local Time = CurTime()
	local DeltaTime = Time - self.BulletData.LastThink
	self.BulletData.LastThink = Time
	self.BulletData.FlightTime = self.BulletData.FlightTime + DeltaTime

	local NextPos = self.BulletData.Pos + self.BulletData.Flight * DeltaTime		--Calculates the next shell position
	local Step = NextPos:Distance(self.BulletData.Pos)
	local Speed = (Step / DeltaTime)
	local Dir = self.BulletData.Dir
	self.Traveled = self.Traveled + Step

	local Drag = (Dir*Speed^3) / 10000000 * self.BulletData.DragCoef
	local Motor = Dir * self.BulletData.Motor
	local Drift = VectorRand() * self.BulletData.Drift * Step
	//print(self.BulletData.Flight:Length() / 39.37, self.BulletData.Accel:Length(), Motor:Length(), Drag:Length(), Drift:Length())
	self.BulletData.Flight = self.BulletData.Flight + (self.BulletData.Accel + Motor - Drag + Drift) * DeltaTime		--Calculates the next shell vector 
	self.BulletData.Dir = (Dir*(Speed/2) + self.BulletData.Flight):GetNormalized()
	
	if Time > self.FutureCutout then 
		self.BulletData.Motor = 0
		if self.Trail then
			self.Trail:Fire("Kill", "", 0)
			self.Trail = nil
		end
	end
	
	debugoverlay.Line( self.BulletData.Pos, NextPos, 4, CLIENT and Color(255, 255, 0) or Color(0, 255, 255) )
	
	self:DoFlight( NextPos , Speed )
	
end




function ENT:DoFlight( NextPos , Speed )

	local FlightTr = { }
		FlightTr.start = self.BulletData.Pos
		FlightTr.endpos = NextPos
		FlightTr.filter = self.Filter
	local FlightRes = util.TraceLine(FlightTr)					--Trace to see if it will hit anything
		
	local Bullet = self.BulletData
		//ACF_CreateBullet( BulletData )
	if FlightRes.HitNonWorld or FlightRes.HitWorld then
		if self.Traveled < self.BulletData.BlastRadius then
			self:Dud( FlightRes.HitPos , Speed )
		else
			self:Detonate(FlightRes)
		end
	else
		Bullet.Pos = NextPos
	end
	
	self.Entity:SetPos( Bullet.Pos )
	self.Entity:SetAngles( self.BulletData.Dir:Angle() )
	self.Entity:NextThink( CurTime() + self.ThinkDelay )
	
end




function ENT:BecomeCrate(alsofreeze)

	self.IsCrate = true

	self:SetNetworkedInt( "Caliber",		self.BulletData.Caliber or 10 )
	self:SetNetworkedInt( "ProjMass",		self.BulletData.ProjMass or 10 )
	self:SetNetworkedInt( "FillerMass",		self.BulletData.FillerMass or 0 )
	self:SetNetworkedInt( "DragCoef",		self.BulletData.DragCoef or 1 )
	self:SetNetworkedString( "AmmoType",	self.BulletData.Type or "AP" )
	self:SetNetworkedInt( "Tracer",  		self.BulletData.Tracer or 0)
	self:SetNetworkedVector( "Accel",		self.BulletData.Accel or Vector(0,0,-600))
	
	self.BulletData.Crate = self:EntIndex()
	
	if alsofreeze then
		self:SetNoDraw(true)
		self:SetSolid( SOLID_NONE )
		self:SetNotSolid( true )
		local phys = self:GetPhysicsObject()
		if phys then
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
		end
	end
	
end




function ENT:SetCrate(crate)

	if crate.BulletData then
		table.Merge(self.BulletData, crate.BulletData)
	end

	self.BulletData.Crate = crate:EntIndex()
	
	crate:SetNetworkedInt( "Caliber",		self.BulletData.Caliber or 10 )
	crate:SetNetworkedInt( "ProjMass",		self.BulletData.ProjMass or 10 )
	crate:SetNetworkedInt( "FillerMass",		self.BulletData.FillerMass or 0 )
	crate:SetNetworkedInt( "DragCoef",		self.BulletData.DragCoef or 1 )
	crate:SetNetworkedString( "AmmoType",	self.BulletData.Type or "AP" )
	crate:SetNetworkedInt( "Tracer",  		self.BulletData.Tracer or 0)
	crate:SetNetworkedVector( "Accel",		self.BulletData.Accel or Vector(0,0,-600))
	
end




function ENT:Detonate( FlightRes )
	
	self.Flying = false
	//self:BecomeCrate(true)
	self:SetPos(Vector(0,0,0))
	if self.Trail then
		self.Trail:Fire("Kill", "", 0)
		self.Trail = nil
	end
	
	self.BulletData["Owner"] = self.Owner or self:GetOwner() or error("No owner for this missile!")
	self.BulletData.Filter = self.Filter
	
	self.MadeBullet = true
	
	self.Entity:Remove()
	
	self.BulletData = XCF_CreateBulletSWEP( self.BulletData, self)
	
	//timer.Simple(15, function() if self and self.Entity and IsValid(self.Entity) then self.Entity:Remove() end end)
	//self.Entity:Remove()

end
	
	
	

function ENT:Dud( HitPos , Speed )
	//print("dud")
	Dud = ents.Create("prop_physics")
	Dud:SetPos( HitPos - self.BulletData.Dir*100 )
	Dud:SetAngles( self.BulletData.Dir:Angle() )
	Dud:SetKeyValue( "model", self.Model )
	Dud:PhysicsInit( SOLID_VPHYSICS )
	Dud:SetMoveType( MOVETYPE_VPHYSICS )
	Dud:SetSolid( SOLID_VPHYSICS )
	Dud:Activate()
	Dud:Spawn()
	Dud:Fire("Kill", "", 10)
	local phys = Dud:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetVelocity(self.BulletData.Dir * Speed)
	end
	
	self.Entity:Remove()
	
end




function ENT:IsDamaged( Damage )
	
	if Damage > math.random(1,self.Entity.ACF.MaxHealth) then
		self.KillAction = false	
		self.DamageAction = false
		self:Detonate( self.BulletData.Pos , self.BulletData.Dir )
	else
		self.BulletData.Drift = math.max(self.BulletData.Drift + 2*Damage)
	end
	
end




function ENT:IsKilled()

	self.KillAction = false	
	self.DamageAction = false
	self:Detonate( self.BulletData.Pos , self.BulletData.Dir )

end
