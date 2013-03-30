


// This is the classname of this type on the serverside.  Make sure the name matches in the client and shared files, and is unique.
local classname = "Shell"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




function this.GetUpdate(bullet)
	return {
		["Pos"] 	= bullet.Pos,
		["Flight"] 	= bullet.Flight
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
	if BulletData["Gun"]:IsValid() then											--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		BulletData["TraceBackComp"] = BulletData["Gun"]:GetPhysicsObject():GetVelocity():Dot(BulletData["Flight"]:GetNormalized())
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
	if not Bullet then return false end
	if not Bullet.LastThink then return false end
	if not Bullet.Index then return false end
	
	local Index = Bullet.Index
	local Time = SysTime()
	local DeltaTime = Time - Bullet.LastThink
	
	local Speed = Bullet.Flight:Length()
	local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Speed^2)/ACF.DragDiv
	Bullet.NextPos = Bullet.Pos + (Bullet.Flight * ACF.VelScale * DeltaTime)		--Calculates the next shell position
	Bullet.Flight = Bullet.Flight + (Bullet.Accel - Drag)*DeltaTime				--Calculates the next shell vector
	Bullet.StartTrace = Bullet.Pos - Bullet.Flight:GetNormalized()*math.min(ACF.PhysMaxVel*DeltaTime, Bullet.FlightTime*Speed)
	
	Bullet.LastThink = Time
	Bullet.FlightTime = Bullet.FlightTime + DeltaTime
	
	
	
	local FlightTr = { }
		FlightTr.start = Bullet.StartTrace
		FlightTr.endpos = Bullet.NextPos
		FlightTr.filter = Bullet.Filter
	local FlightRes = util.TraceLine(FlightTr)					--Trace to see if it will hit anything
	
	
	debugoverlay.Line( Bullet.StartTrace, FlightRes.HitPos, 10, Color(0, 255, 255), false )
	
	
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



function this.Removed(Proj)
end



function this.Penetrate(Index, Proj, FlightRes)
	//ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
	ACF_DoBulletsFlight( Index, Proj )
end



function this.Ricochet(Index, Proj, FlightRes)
	//ACF_BulletClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
	ACF_CalcBulletFlight( Index, Proj, true )
end



function this.EndFlight(Index, Proj, FlightRes)
	//ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
	//printByName(Proj)
	ACF_BulletEndFlight = ACF.RoundTypes[Proj.Type]["endflight"]	//TODO: why global?
	ACF_BulletEndFlight( Index, Proj, FlightRes.HitPos, FlightRes.HitNormal )
end