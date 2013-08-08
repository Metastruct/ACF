


// This is the classname of this type on the clientside.  Make sure the name matches in the server and shared files, and is unique.
local classname = "Bomb"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




function this:CreateEffect()
	local effectdata = EffectData()
	local effect = util.ClientsideEffect( "XCF_BombEffect", effectdata )
	
	effect:Config(self)
	
	self.Effect = effect
end



function this:Update(diffs)
	//print("UPDATE for " .. tostring(self) .. "\nDIFFS:")
	//printByName(diffs)
	table.Merge(self, diffs)
	//*
	if IsValid(self.Effect) then
		self.Effect:Update(diffs)
	end
	//*/
end



function this:Launch()

	self.LastThink = SysTime()
	self.FlightTime = 0
	self.Travelled = 0
	
	//*
	self.Forward = self.Forward or IsValid(self.Gun) and self.Gun:GetForward() or self.Flight:GetNormalized() or Vector(1, 0, 0)
	self.RotAxis = Vector(0,0,0)
	local inchlength = self.ProjLength / 2.54
	local inchcaliber = self.Caliber / 2.54
	local mass = self.RoundMass or self.ProjMass or 100
	self.Inertia = 0.08333 * mass * (3 * (inchcaliber / 2)^2 + inchlength) -- cylinder, non-roll axes
	self.TorqueMul = inchlength / 3 * inchcaliber * inchlength / 2 -- square fins 1/5th the length of the bomb with center of mass at bomb center.
	//self.RotDecay = 1 - (0.000197 * inchcaliber * inchlength / 4) -- resistance-factor of fins at normal air-density (1.96644768 × 10-5 kg / in^3)
	//print("Bomb specs:", "Inertia: " .. self.Inertia, "TorqueMul: " .. self.TorqueMul)//, "RotDecay: " .. self.RotDecay)
	
	/*
	local follower = ents.Create("xcf_projfollower")
	follower:Spawn()
	follower:RegisterTo(self)
	self.Filter[#self.Filter + 1] = follower
	//*/
end



function this:DoFlight()
	if not self then print("Flight failed; tried to fly a nil bomb!") return false end
	if not self.LastThink then print("Flight failed; bombs must contain a LastThink parameter!") return false end
	
	local Time = SysTime()
	local DeltaTime = Time - self.LastThink
	
	local Speed = self.Flight:Length()
	local Drag = self.Flight:GetNormalized() * (self.DragCoef * Speed^2)/ACF.DragDiv
	self.NextPos = self.Pos + (self.Flight * ACF.VelScale * DeltaTime)		--Calculates the next bomb position
	self.Flight = self.Flight + (self.Accel - Drag)*DeltaTime				--Calculates the next bomb vector
	
	local flightnorm = self.Flight:GetNormalized()
	//local aimdot = 1 - math.abs((-flightnorm):Dot(self.Forward))
	local angveldiff
	local aimdiff = self.Forward - flightnorm
	local difflen = aimdiff:Length()
	//if aimdot <= 0.99 then 
	if difflen >= 0.01 then 
		local torque = difflen * self.TorqueMul
		angveldiff = torque / self.Inertia * DeltaTime
		local diffaxis = aimdiff:Cross(self.Forward):GetNormalized()
		self.RotAxis = self.RotAxis + diffaxis * angveldiff
	end
	self.RotAxis = self.RotAxis * 0.992 //TODO: real energy-loss function
	
	//print(aimdot, angveldiff, self.RotAxis:Length())
	
	local newforward = self.Forward:Angle()
	newforward:RotateAroundAxis(self.RotAxis, self.RotAxis:Length())
	self.Forward = newforward:Forward()
	
	self.StartTrace = self.Pos - self.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime, self.FlightTime*Speed)
	self.Travelled = self.Travelled + (self.NextPos:Distance(self.Pos))
	self.Pos = self.NextPos
	self.LastThink = SysTime()
	self.FlightTime = self.FlightTime + DeltaTime
	
	
	debugoverlay.Line( self.Pos, self.Pos + self.Forward * 200, 20, Color(255, 255, 0), false )
	--debugoverlay.Line( self.StartTrace, self.NextPos, 4, Color(255, 255, 0), false )
	
	return true
end



function this:EndFlight()
	//print("ENDING " .. tostring(self))
	if IsValid(self.Effect) then
		self.Effect:HitEnd()
	end
end



function this:Delete()
	if IsValid(self.Effect) then
		self.Effect:Remove()
	end
end