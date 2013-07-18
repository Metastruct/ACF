


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
	local effect = util.ClientsideEffect( "XCF_ShellEffect", effectdata )
	
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
	
	/*
	print("LAUNCHING " .. tostring(self))
	printByName(self)
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
	self.StartTrace = self.Pos - self.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime, self.FlightTime*Speed)
	self.Travelled = self.Travelled + (self.NextPos:Distance(self.Pos))
	self.Pos = self.NextPos
	self.LastThink = SysTime()
	self.FlightTime = self.FlightTime + DeltaTime
	
	
	debugoverlay.Line( self.StartTrace, self.NextPos, 4, Color(255, 255, 0), false )
	
	return true
end



function this:EndFlight()
	//print("ENDING " .. tostring(self))
	if IsValid(self.Effect) then
		self.Effect:HitEnd()
	end
end