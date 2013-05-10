


// This is the classname of this type on the serverside.  Make sure the name matches in the client and shared files, and is unique.
local classname = "Rocket"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

// TODO: ensure ballistic functions are never called in here so that rockets can exist independently of ballistics structure (for things like impact computers etc)
local balls = XCF.Ballistics or error("Tried to load " .. classname .. " before ballistics!")




this.HitTypes = 
{
	["HIT_NONE"] = "HitNone",
	["HIT_END"] = "EndFlight",
	["HIT_PENETRATE"] = "Penetrate",
	["HIT_RICOCHET"] = "Ricochet"
}
local hit = this.HitTypes





//TODO: catch rocket table modifications and cache them for updates. (use metatable)  mutable ammotypes will become possible.
function this.GetUpdate(rocket)
	return {
		["Pos"] 	= rocket.Pos,
		["Flight"] 	= rocket.Flight,
		//["Detonated"] = rocket.Detonated	// this will become unnecessary when the above todo is completed.
	}
end


/**
	rocketData: full rocket info table (uninstantiated)
	
	Prepares the stated data for launching as a rocket
//*/
function this.Prepare(rocketData)
	local cvarGrav = GetConVar("sv_gravity")
	rocketData["Accel"] = Vector(0,0,cvarGrav:GetInt()*-1)			--Those are rocketData settings that are global and shouldn't change round to round
	rocketData["LastThink"] = SysTime()
	rocketData["FlightTime"] = 0
	rocketData["TraceBackComp"] = 0
	if rocketData["Gun"]:IsValid() then		--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the rocket path
		local phys = rocketData["Gun"]:GetPhysicsObject()
		if phys and IsValid(phys) then
			rocketData["TraceBackComp"] = phys:GetVelocity():Dot(rocketData["Flight"]:GetNormalized())
		else
			rocketData["TraceBackComp"] = 0
		end
		if rocketData["Gun"].sitp_inspace then
			rocketData["Accel"] = Vector(0, 0, 0)
			rocketData["DragCoef"] = 0
		end
	end
	rocketData["Filter"] = rocketData["Filter"] or {}
	rocketData.Travelled = 0
	rocketData.Dir = rocketData.Dir or rocketData.Flight
	rocketData.Filter[#rocketData.Filter + 1] = rocketData["Gun"] 
	rocketData.ProjClass = this
	
	return rocketData
end




function this.Launched(self)
	self.LastThink = SysTime()
	self.RandDrift = this.pseudorandom(self.Seed or 1337)
	self.FutureCutout = self.LastThink + (self.Cutout or 0)
	
	printByName(self)
end


local VEC_0 = Vector(0, 0, 0)
function this.DoFlight(self, isRetry)

	if isRetry then return this.DoTrace(self) end

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
	
	local traceback = self.InvalidateTraceback and VEC_0 or -self.Flight:GetNormalized() * math.min(ACF.PhysMaxVel * DeltaTime, self.FlightTime * Speed - self.TraceBackComp * DeltaTime, self.Travelled)
	print(tostring(traceback))
	self.InvalidateTraceback = nil
	
	self.Travelled = self.Travelled + Step
	self.StartTrace = self.Pos + traceback
	
	
	//print("time", Time, "future", self.FutureCutout)
	if Time > self.FutureCutout then 
		self.Motor = 0
	end
	
	return this.DoTrace(self)
	
end




function this.DoTrace(self)

	local Index = self.Index

	local FlightTr = { }
		FlightTr.start = self.StartTrace
		FlightTr.endpos = self.NextPos
		FlightTr.filter = self.Filter
	local FlightRes = util.TraceLine(FlightTr)					--Trace to see if it will hit anything
	
	
	debugoverlay.Line( self.StartTrace, FlightRes.HitPos, 4, Color(0, 255, 255), false )
	
	
	if FlightRes.HitSky or not FlightRes.Hit then 
	
		if not util.IsInWorld(self.NextPos) then
			return hit.HIT_END, FlightRes
		end
	
		self.Pos = self.NextPos
		return hit.HIT_NONE, FlightRes
	
	elseif FlightRes.HitNonWorld then
	
		local propimpact = ACF.RoundTypes[self.Type]["propimpact"]		
		local Retry = propimpact( Index, self, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )				--If we hit stuff then send the resolution to the damage function	
		if Retry == "Penetrated" then
			return hit.HIT_PENETRATE, FlightRes
		elseif Retry == "Ricochet"  then
			return hit.HIT_RICOCHET, FlightRes
		else
			return hit.HIT_END, FlightRes
		end	
	
	elseif FlightRes.HitWorld then									--If we hit the world then try to see if it's thin enough to penetrate
	
		local worldimpact = ACF.RoundTypes[self.Type]["worldimpact"]
		local Retry = worldimpact( Index, self, FlightRes.HitPos, FlightRes.HitNormal )
		if Retry == "Penetrated" then 								--if it is, we soldier on	
			return hit.HIT_PENETRATE, FlightRes
		else														--If not, end of the line, boyo
			return hit.HIT_END, FlightRes
		end
		
	end
	
end




/**
	Projectile event callback called by the ballistic core.
//*/
function this.Penetrate(Index, Proj, FlightRes)

	//print("PENETRATE, invtr, st", (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"))
	//printByName(Proj.Filter)

	//Proj.InvalidateBacktrace = true
	//Proj.StartTrace = FlightRes.HitPos
	Proj.StartTrace = Proj.Pos
	
	if Proj.CallbackPenetrate then Proj.CallbackPenetrate(Index, Proj, FlightRes) end
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "PENETRATE: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoTrace(Proj) // INFO: discarded return here is the reason for incomplete client display.  see below todo
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_PENETRATE
	// TODO: use retry on penetration etc once recursion limit is in place
	return ret, balls.PROJ_UPDATE
end



function this.Ricochet(Index, Proj, FlightRes)
	if Proj.CallbackRicochet then Proj.CallbackRicochet(Index, Proj, FlightRes) end
	
	//Proj.InvalidateBacktrace = true
	Proj.StartTrace = FlightRes.HitPos
	
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "RICOCHET: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoFlight( Proj ) // INFO: discarded return here is the reason for incomplete client display.  see below todo
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_RICOCHET
	// TODO: use retry on penetration etc once recursion limit is in place
	return ret, balls.PROJ_UPDATE
end



function this.EndFlight(Index, Proj, FlightRes)

	//print("END")
	//printByName(Proj.Filter)

	if Proj.CallbackEndFlight then Proj.CallbackEndFlight(Index, Proj, FlightRes) end
	ACF.RoundTypes[Proj.Type]["endflight"]( Index, Proj, FlightRes.HitPos, FlightRes.HitNormal )
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "ENDFLIGHT: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_END
	return ret, balls.PROJ_REMOVE
end


