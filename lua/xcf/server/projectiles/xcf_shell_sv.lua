


// This is the classname of this type on the serverside.  Make sure the name matches in the client and shared files, and is unique.
local classname = "Shell"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

// ONGOING: ensure ballistic functions are never called in here so that shells can exist independently of ballistics structure (for things like impact computers etc)
local balls = XCF.Ballistics or error("Tried to load " .. classname .. " before ballistics!")




this.HitTypes = 
{
	["HIT_NONE"] = "HitNone",
	["HIT_END"] = "EndFlight",
	["HIT_PENETRATE"] = "Penetrate",
	["HIT_RICOCHET"] = "Ricochet"
}
local hit = this.HitTypes





//TODO: catch bullet table modifications and cache them for updates. (use metatable)  mutable ammotypes will become possible.
function this.GetUpdate(bullet)
	return {
		["Pos"] 	= bullet.Pos,
		["Flight"] 	= bullet.Flight,
		//["Detonated"] = bullet.Detonated	// this will become unnecessary when the above todo is completed.
	}
end


/**
	BulletData: full bullet info table (uninstantiated)
	
	Prepares the stated data for launching as a Shell
//*/
function this.Prepare(BulletData)
	local cvarGrav = GetConVar("sv_gravity")
	BulletData["Accel"] = Vector(0,0,cvarGrav:GetInt()*-1)			--Those are BulletData settings that are global and shouldn't change round to round
	BulletData["LastThink"] = SysTime()
	BulletData["FlightTime"] = 0
	BulletData["TraceBackComp"] = 0
	if BulletData["Gun"]:IsValid() then		--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		local phys = BulletData["Gun"]:GetPhysicsObject()
		if phys and IsValid(phys) then
			BulletData["TraceBackComp"] = phys:GetVelocity():Dot(BulletData["Flight"]:GetNormalized())
		else
			BulletData["TraceBackComp"] = 0
		end
		if BulletData["Gun"].sitp_inspace then
			BulletData["Accel"] = Vector(0, 0, 0)
			BulletData["DragCoef"] = 0
		end
	end
	BulletData.Travelled = 0
	BulletData["Filter"] = BulletData["Filter"] or {}
	BulletData.Filter[#BulletData.Filter + 1] = BulletData["Gun"] 
	BulletData.ProjClass = this
	
	if BulletData.Tracer and BulletData.Tracer > 0 and BulletData.Crate then
		local crate = Entity(BulletData.Crate)
		if IsValid(crate) then
			BulletData.Colour = crate:GetColor()
		end
	end
	
	return BulletData
end



function this.Launched(self)
	self.LastThink = SysTime()
end



function this.DoFlight(self, isRetry)
	if not self then print("Flight failed; tried to fly a nil shell!") return false end
	if not self.LastThink then print("Flight failed; shells must contain a LastThink parameter!") return false end
	if not self.Index then print("Flight failed; shells must contain an Index parameter!") return false end
	
	if isRetry then return this.DoTrace(self) end
	
	local Index = self.Index
	local Time = SysTime()
	local DeltaTime = Time - self.LastThink
	
	//*
	local Speed = self.Flight:Length()
	local Drag = self.Flight:GetNormalized() * (self.DragCoef * Speed^2)/ACF.DragDiv
	self.NextPos = self.Pos + (self.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	self.Flight = self.Flight + (self.Accel - Drag)*DeltaTime				--Calculates the next shell vector
	
	local traceback = self.InvalidateTraceback and Vector(0,0,0) or -self.Flight:GetNormalized() * math.min(ACF.PhysMaxVel * DeltaTime, self.FlightTime * Speed - self.TraceBackComp * DeltaTime)
	self.InvalidateTraceback = nil
	
	self.StartTrace = self.Pos + traceback
	
	local Step = self.NextPos:Distance(self.Pos)
	self.Travelled = self.Travelled + Step
	
	self.LastThink = Time
	self.FlightTime = self.FlightTime + DeltaTime
	
	return this.DoTrace(self)
	
end



function this.DoTrace(self)

	local Index = self.Index

	local FlightTr = { }
		FlightTr.start = self.StartTrace
		FlightTr.endpos = self.NextPos
		FlightTr.filter = self.Filter
	local FlightRes = util.TraceLine(FlightTr)					--Trace to see if it will hit anything
	
	
	--debugoverlay.Line( self.StartTrace, FlightRes.HitPos, 20, Color(0, 255, 255), false )
	
	if not FlightRes.Hit or FlightRes.HitSky then 
	
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
	
	elseif FlightRes.HitWorld then				--If we hit the world then try to see if it's thin enough to penetrate
	
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

	//print("PENETRATE, invtr, st2")
	//printByName(Proj.Filter)

	//Proj.StartTrace = FlightRes.HitPos
	Proj.StartTrace = Proj.Pos
	/*
	if FlightRes.HitWorld then
		Proj.InvalidateBacktrace = true
	end
	//*/
	
	if Proj.OnPenetrate then Proj.OnPenetrate(Index, Proj, FlightRes) end
	--debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	--debugoverlay.Text( FlightRes.HitPos, "PENETRATE: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoTrace(Proj) // discarded return here is the reason for incomplete client display.  see below todo
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_PENETRATE
	// TODO: use retry on penetration etc once recursion limit is in place
	return ret, balls.PROJ_UPDATE
end



function this.Ricochet(Index, Proj, FlightRes)
	if Proj.OnRicochet then Proj.OnRicochet(Index, Proj, FlightRes) end
	
	//Proj.InvalidateBacktrace = true
	Proj.StartTrace = FlightRes.HitPos
	
	--debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	--debugoverlay.Text( FlightRes.HitPos, "RICOCHET: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoFlight( Proj ) // discarded return here is the reason for incomplete client display.  see below todo
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_RICOCHET
	// TODO: use retry on penetration etc once recursion limit is in place
	return ret, balls.PROJ_UPDATE
end



function this.EndFlight(Index, Proj, FlightRes)

	//print("END")
	//printByName(Proj.Filter)
			
	if Proj.OnEndFlight then Proj.OnEndFlight(Index, Proj, FlightRes) end
	ACF.RoundTypes[Proj.Type]["endflight"]( Index, Proj, FlightRes.HitPos, FlightRes.HitNormal )
	--debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	--debugoverlay.Text( FlightRes.HitPos, "ENDFLIGHT: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = hit.HIT_END
	return ret, balls.PROJ_REMOVE
end


