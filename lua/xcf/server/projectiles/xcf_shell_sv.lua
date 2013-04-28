


// This is the classname of this type on the serverside.  Make sure the name matches in the client and shared files, and is unique.
local classname = "Shell"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

// TODO: ensure ballistic functions are never called in here so that shells can exist independently of ballistics structure (for things like impact computers etc)
local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




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
	BulletData["Filter"] = BulletData["Filter"] or {}
	BulletData.Filter[#BulletData.Filter + 1] = BulletData["Gun"] 
	BulletData.ProjClass = this
	
	return BulletData
end



function this.DoFlight(Bullet)
	if not Bullet then print("Flight failed; tried to fly a nil shell!") return false end
	if not Bullet.LastThink then print("Flight failed; shells must contain a LastThink parameter!") return false end
	if not Bullet.Index then print("Flight failed; shells must contain an Index parameter!") return false end
	
	local Index = Bullet.Index
	local Time = SysTime()
	local DeltaTime = Time - Bullet.LastThink
	
	//*
	local Speed = Bullet.Flight:Length()
	local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Speed^2)/ACF.DragDiv
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	Bullet.Flight = Bullet.Flight + (Bullet.Accel - Drag)*DeltaTime				--Calculates the next shell vector
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime, Bullet.FlightTime*Speed)
	//TODO: fix traceback for static objects
	//*/
	
	Bullet.LastThink = Time
	Bullet.FlightTime = Bullet.FlightTime + DeltaTime
	
	return this.DoTrace(Bullet)
	
end



function this.DoTrace(Bullet)

	local Index = Bullet.Index

	local FlightTr = { }
		FlightTr.start = Bullet.StartTrace
		FlightTr.endpos = Bullet.NextPos
		FlightTr.filter = Bullet.Filter
	local FlightRes = util.TraceLine(FlightTr)					--Trace to see if it will hit anything
	
	
	debugoverlay.Line( Bullet.StartTrace, FlightRes.HitPos, 4, Color(0, 255, 255), false )
	
	
	if FlightRes.HitNonWorld then
	
		local propimpact = ACF.RoundTypes[Bullet.Type]["propimpact"]		
		local Retry = propimpact( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )				--If we hit stuff then send the resolution to the damage function	
		if Retry == "Penetrated" then
			return balls.HIT_PENETRATE, FlightRes
		elseif Retry == "Ricochet"  then
			return balls.HIT_RICOCHET, FlightRes
		else
			return balls.HIT_END, FlightRes
		end
		
	elseif FlightRes.HitWorld then									--If we hit the world then try to see if it's thin enough to penetrate
	
		local worldimpact = ACF.RoundTypes[Bullet.Type]["worldimpact"]
		local Retry = worldimpact( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
		if Retry == "Penetrated" then 								--if it is, we soldier on	
			return balls.HIT_PENETRATE, FlightRes
		else														--If not, end of the line, boyo
			return balls.HIT_END, FlightRes
		end
		
	else															--If we didn't hit anything, move the shell and schedule next think
		Bullet.Pos = Bullet.NextPos
		return balls.HIT_NONE, FlightRes
	end
	
end



/**
	Projectile event callback called by the ballistic core.
//*/
function this.Penetrate(Index, Proj, FlightRes)
	if Proj.CallbackPenetrate then Proj.CallbackPenetrate(Index, Proj, FlightRes) end
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "PENETRATE: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoTrace(Proj)
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = balls.HIT_PENETRATE
	return ret, balls.PROJ_UPDATE
end



function this.Ricochet(Index, Proj, FlightRes)
	if Proj.CallbackRicochet then Proj.CallbackRicochet(Index, Proj, FlightRes) end
	Proj.FlightTime = 0	// TODO: find a better way of temporarily invalidating backtracing.
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "RICOCHET: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	this.DoFlight( Proj )
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = balls.HIT_RICOCHET
	return ret, balls.PROJ_UPDATE
end



function this.EndFlight(Index, Proj, FlightRes)
	if Proj.CallbackEndFlight then Proj.CallbackEndFlight(Index, Proj, FlightRes) end
	ACF.RoundTypes[Proj.Type]["endflight"]( Index, Proj, FlightRes.HitPos, FlightRes.HitNormal )
	debugoverlay.Cross( FlightRes.HitPos, 10, 10, Color(0, 255, 0), true )
	debugoverlay.Text( FlightRes.HitPos, "ENDFLIGHT: " .. (FlightRes.Entity and tostring(FlightRes.Entity) or "NON-ENTITY"), 10 )
	
	local ret = this.GetUpdate(Proj)
	ret.UpdateType = balls.HIT_END
	return ret, balls.PROJ_REMOVE
end


