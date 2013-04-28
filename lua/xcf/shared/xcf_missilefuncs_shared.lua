/**
	Generate full missile info from basic missile info.
	
	partial = 
	{
		Id<string>,
		Type<string>,
		ProjLength<number>,
		PropLength<number>,
		FillerVol<number>,
		ConeAng<number>
	}
//*/
local noboom = {["HP"] = true, ["SM"] = true, ["AP"] = true}	// should have a blast radius?
local hollow = {["HEAT"] = true, ["SM"] = true, ["HE"] = true}	// should be hollow except for warhead?
function XCF_GenerateMissileInfo( partial, docopy )

	printByName(partial)

	local conversion = ACF.RoundTypes[partial.Type].convert
	if not conversion then Error("Couldn't find conversion function for ammo type: " .. partial.AmmoType) end
	
	if docopy then partial = table.Copy(partial) end
	
	partial.BlastRadius = 0
	
	local fillerVol = partial.FillerVol
	local coneAng = partial.ConeAng
	
	partial.Data5 = fillerVol
	partial.Data6 = coneAng
	
	partial = conversion( nil, partial )
	
	partial.FillerVol = fillerVol
	partial.ConeAng = coneAng
	
	local round = ACF.Weapons["Guns"][partial.Id]["round"]
	
	if not noboom[partial.Type] then
		partial.BlastRadius = (partial.FillerMass or 0) ^ 0.33 * 5 * 10
	end
	
	if hollow[partial.Type] and partial.FillerMass then
		// fix mass of missile - free space is hollow
		local casingarea = partial.FrAera - (math.pi * (partial.Caliber/2 - round.casing) ^ 2)
		local casingvol = casingarea * partial.ProjLength
		partial.CasingMass = casingvol * 0.0027 // density of aluminium, kg/cm^3
		partial.ProjMass = partial.FillerMass + partial.CasingMass
		partial.DragCoef = (partial.FrAera / 10000) / partial.ProjMass
	end
	
	// TODO: kinetic for ap/aphe
	
	partial.Mass = partial.PropMass + partial.ProjMass
	partial.Drift = 10 / partial.Mass ^ 0.5
	partial.Motor = round.thrust / partial.Mass
	partial.MuzzleVel = round.muzzlevel
	
	local propvolume = partial.PropLength * (math.pi * (partial.Caliber/2) ^ 2)
	partial.Cutout = propvolume / round.burnrate
	
	return partial

end



/*
	self.BulletData["BlastRadius"]		= 164.53173881845
	self.BulletData["BoomPower"]		= 47.83654034402
	self.BulletData["Caliber"]			= 17
	self.BulletData["CasingMass"]		= 9.0974532297589
	self.BulletData["Cutout"]			= 4.2294422836372
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]			= 0.00049301889893239
	self.BulletData["Drift"]			= 13.252999329603
	self.BulletData["FillerMass"]		= 36.94147154402
	self.BulletData["FrAera"]			= 226.9806
	self.BulletData["Id"]				= "170mmRK"
	self.BulletData["KETransfert"]		= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["Mass"]				= 56.933993573779
	self.BulletData["Motor"]			= 84.308155790614
	self.BulletData["MuzzleVel"]		= 520.72248960355
	self.BulletData["PenAera"]			= 100.5982506735
	self.BulletData["ProjLength"]		= 130
	self.BulletData["ProjMass"]			= 46.038924773779
	self.BulletData["PropLength"]		= 30
	self.BulletData["PropMass"]			= 10.8950688
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]		= 36316.896
	self.BulletData["ShovePower"]		= 0.1
	self.BulletData["SlugCaliber"]		= 3.8331761017484
	self.BulletData["SlugDragCoef"]		= 0.00094641953709837
	self.BulletData["SlugMV"]			= 2776.4155155407
	self.BulletData["SlugMass"]			= 1.2193397832
	self.BulletData["SlugPenAera"]		= 7.9960808097539
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]				= "HEAT"
	self.BulletData["Crate"] = -1
//*/
function XCF_RocketRepresentSimply( bullet )
	return
	{
		["Id"] = bullet.Id,
		["Type"] = bullet.Type,
		["PropLength"]	= bullet.PropLength,
		["ProjLength"]	= bullet.ProjLength,
		["FillerVol"]	= bullet.FillerVol,
		["ConeAng"]		= bullet.ConeAng,
	}
end




function XCF_MoveMissile(Bullet, noreturn)
	local Time = CurTime()
	local DeltaTime = Time - Bullet.LastThink
	
	Bullet.LastThink = Time
	
	local Step, Speed, Drag, oldpos, Drift
	if DeltaTime != 0 then
		Bullet.FlightTime = Bullet.FlightTime + DeltaTime

		oldpos = Bullet.Pos
		
		Bullet.NextPos = oldpos + Bullet.Flight * DeltaTime
		local NextPos = Bullet.NextPos
		Step = NextPos:Distance(oldpos)
		Speed = (Step / DeltaTime)
		Bullet.Travelled = Bullet.Travelled + Step
		
		Drag = Vector(0,0,0)//((Bullet.Dir * Speed^2) / 10000) * Bullet.DragCoef
		local Motor = Bullet.Dir * math.abs(Bullet.Motor * 39.37)
		print("Motor ", Motor)
		//Drift = VectorRand() * Bullet.Drift * Step	//TODO: random seed based on networked var so client missile is synched
		//local fuk = (Bullet.Accel + Motor - Drag + Drift) * DeltaTime
		local fuk = Bullet.Accel
		fuk = fuk + Motor
		fuk = fuk - Drag
		//fuk = fuk + Drift
		fuk = fuk * DeltaTime
		//print("fuk u nilvalue ", fuk)
		
		Bullet.Flight = Bullet.Flight + fuk
		//Bullet.Dir = (Bullet.Dir*(Speed/2) + Bullet.Flight):GetNormalized()
		Bullet.Dir = Bullet.Flight:GetNormalized()

		debugoverlay.Line( oldpos, NextPos, 20, CLIENT and Color(255, 255, 0) or Color(0, 255, 255) )
	else
		Bullet.NextPos = Bullet.Pos
	end
	
	return noreturn and nil or 
		{	
			["Time"] = Time, 					["DeltaTime"] = DeltaTime,
			["OldPos"] = oldpos or Bullet.Pos, 	["Step"] = Step or 0,
			["Speed"] = Speed or 0,				["Drag"] = Drag or 0,
			["Drift"] = Drift or Vector(0,0,0)
		}
end






//	-	-	-	-	-		SERVER		-	-	-	-	-	//






/**
	Make sure that MissileData is FULL missile data (e.g. constructed with XCF_GenerateMissileInfo)
	This requirement is inefficient - these lua ops are for you, kai <3
//*/
if SERVER then

	function XCF_CreateDumbMissile( MissileData, isswep )

		ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
		if ACF.CurBulletIndex > ACF.BulletIndexLimt then
			ACF.CurBulletIndex = 1
		end
		local curind = ACF.CurBulletIndex
		
		if not (MissileData.Pos and MissileData.Flight) then return false end
		
		local gun = MissileData["Gun"]
		
		MissileData["IsRocket"] = true
		local cvarGrav = GetConVar("sv_gravity")
		MissileData["Accel"] = Vector(0,0,cvarGrav:GetInt()*-1)
		MissileData["LastThink"] = CurTime()
		MissileData["FlightTime"] = 0
		MissileData["Travelled"] = 0
		MissileData["Dir"] = MissileData.Flight:GetNormalized()
		MissileData["TraceBackComp"] = 0
		if gun:IsValid() then
			MissileData["TraceBackComp"] = gun.Owner:GetVelocity():Dot(MissileData["Flight"]:GetNormalized())
			if gun.sitp_inspace then
				MissileData["Accel"] = Vector(0, 0, 0)
				MissileData["DragCoef"] = 0
			end
		end
		MissileData["Filter"] = { gun, isswep and gun.Owner or nil }
		MissileData["Index"] = curind
		
		MissileData = table.Copy(MissileData)
		ACF.Bullet[curind] = MissileData
		XCF_MissileClient( curind, MissileData, "Init" , 0 )
		
	end
	
	
	
	function XCF_MissileClient( Index, Bullet, Type, Hit, HitPos )
	
		/*
		if Type == "Update" then
			
			local sendrocket = XCF_RocketRepresentSimply(Bullet)
			sendrocket.NetType = Type
			
			

		else
			local Effect = EffectData()
				local Filler = 0
				if Bullet["FillerMass"] then Filler = Bullet["FillerMass"]*15 end
				Effect:SetAttachment( Index )
				Effect:SetStart( Bullet.Flight/10 )
				Effect:SetOrigin( Bullet.Pos )
				Effect:SetMagnitude( Bullet["Crate"] )
				Effect:SetScale( 0 )
			util.Effect( "XCF_MissileEffect_Dumb", Effect, true, true )

		end
		//*/
		//*
		if Type == "Update" then
			local Effect = EffectData()
				Effect:SetAttachment( Index )
				Effect:SetStart( Bullet.Flight/10 )
				if Hit > 0 then
					Effect:SetOrigin( HitPos )
				else
					Effect:SetOrigin( Bullet.Pos )
				end
				Effect:SetScale( Hit )
			util.Effect( "XCF_MissileEffect_Dumb", Effect, true, true )

		else
			local Effect = EffectData()
				local Filler = 0
				if Bullet["FillerMass"] then Filler = Bullet["FillerMass"]*15 end
				Effect:SetAttachment( Index )
				Effect:SetStart( Bullet.Flight/10 )
				Effect:SetOrigin( Bullet.Pos )
				Effect:SetMagnitude( Bullet["Crate"] )
				Effect:SetScale( 0 )
			util.Effect( "XCF_MissileEffect_Dumb", Effect, true, true )

		end
		//*/
		
	end
	
	
	
	
	function XCF_SimMissileFlight( Bullet, Index )
		
		if not Bullet.LastThink then ACF_RemoveBullet( Index ) return end
		//if BackTraceOverride then Bullet.FlightTime = 0 end
		
		if Bullet.FlightTime > Bullet.Cutout then 
			Bullet.Motor = 0
			if Bullet.Trail then //TODO: this
				Bullet.Trail:Fire("Kill", "", 0)
				Bullet.Trail = nil
			end
		end
		
		local moveres = XCF_MoveMissile(Bullet)		
		
		XCF_MissileDoFlight( Index, Bullet )
		
	end

	
	
	function XCF_MissileDoFlight( Index, Bullet )
		
		local FlightTr = { }
			FlightTr.start = Bullet.StartTrace
			FlightTr.endpos = Bullet.NextPos
			FlightTr.filter = Bullet.Filter
		local FlightRes = util.TraceLine(FlightTr)
		
		
		if FlightRes.HitNonWorld then
			ACF_BulletPropImpact = ACF.RoundTypes[Bullet.Type]["propimpact"]		
			local Retry = ACF_BulletPropImpact( Index, Bullet, FlightRes.Entity , FlightRes.HitNormal , FlightRes.HitPos , FlightRes.HitGroup )
			if Retry == "Penetrated" then
				XCF_MissileClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
				XCF_MissileDoFlight( Index, Bullet )
			elseif Retry == "Ricochet"  then
				XCF_MissileClient( Index, Bullet, "Update" , 3 , FlightRes.HitPos  )
				XCF_SimMissileFlight( Bullet, Index, true )
			else
				XCF_MissileClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
			end
		elseif FlightRes.HitWorld then
			ACF_BulletWorldImpact = ACF.RoundTypes[Bullet.Type]["worldimpact"]
			local Retry = ACF_BulletWorldImpact( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )
			if Retry == "Penetrated" then
				XCF_MissileClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos  )
				XCF_SimMissileFlight( Bullet, Index, true )
			else
				XCF_MissileClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )
				ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
				ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )	
			end
		else
			Bullet.Pos = Bullet.NextPos
		end
		
	end
	
end






//	-	-	-	-	-		CLIENT		-	-	-	-	-	//






if CLIENT then

	function XCF_SimMissileFlight( Bullet, Index ) 
		
		/**
		if Bullet.FlightTime > Bullet.Cutout then 
			Bullet.Motor = 0
			if Bullet.Trail then //TODO: this
				Bullet.Trail:Fire("Kill", "", 0)
				Bullet.Trail = nil
			end
		end
		//*/
		
		moveres = XCF_MoveMissile(Bullet)
		//print(Bullet.Pos, Bullet.NextPos, moveres.Speed)
		Bullet.Pos = Bullet.NextPos
		
		if Bullet.Effect then
			Bullet.Effect:ApplyMovement( Bullet )
		end
		
	end
	
end