


// This is the classname of this type on the clientside.  Make sure the name matches in the server and shared files, and is unique.
local classname = "Rocket"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




function this:CreateEffect()
	local effectdata = EffectData()
	local effect = util.ClientsideEffect( "XCF_RocketEffect", effectdata )
	
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
	
	self.RandDrift = this.pseudorandom(self.Seed or 1337)
	self.FutureCutout = self.LastThink + (self.Cutout or 0)
	self.Dir = self.Dir or self.Flight
	self.Travelled = 0
	
	//printByName(self)
end



local VEC_0 = Vector(0, 0, 0)
function this.DoFlight(self, isRetry)

	local Time = SysTime()
	local DeltaTime = Time - self.LastThink
	self.LastThink = Time
	self.FlightTime = self.FlightTime + DeltaTime

	self.NextPos = self.Pos + self.Flight * DeltaTime		--Calculates the next shell position
	local Step = self.NextPos:Distance(self.Pos)
	local Speed = (Step / DeltaTime)
	local Dir = self.Dir

	local Drag = (Dir*Speed^3) / 10000000 * self.DragCoef
	local Motor = Dir * self.Motor
	
	//TODO: sync drift (integrator)
	local Drift = Vector(0,0,0)	
	//local Drift = self.RandDrift(self.FlightTime) * self.Drift * Step
	
	//print(self.Flight:Length() / 39.37, self.Accel:Length(), Motor:Length(), Drag:Length(), Drift:Length())
	self.Flight = self.Flight + (self.Accel + Motor - Drag + Drift) * DeltaTime		--Calculates the next shell vector 
	self.Dir = (Dir*(Speed/2) + self.Flight):GetNormalized()
	
	self.Travelled = self.Travelled + Step
	
	debugoverlay.Line( self.Pos, self.NextPos, 4, Color(255, 255, 0), false )
	
	self.Pos = self.NextPos
	
	
	//print("time", Time, "future", self.FutureCutout)
	if Time > self.FutureCutout then 
		self.Motor = 0
	end
	
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