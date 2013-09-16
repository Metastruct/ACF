
/**
	Given the victimized entity and the damage inflictor, determine if this damage is permitted or not.
	Args;
		Entity	Entity
			The entity which may be damaged.
		Inflictor Player
			The player who owns the object which inflicted the damage.
	Return; Boolean or String
		false if the damage is not permitted, else a string representing the victim's damage model.
//*/
function XCF_Check( Entity, Inflictor )
	
	--print("\nxcfchecking")
	
	if ( IsValid(Entity) ) then
	
		--if CPPI and not XCF.DamagePermission(Entity:CPPIGetOwner(), Inflictor, Entity) then print("cppi false", Entity:CPPIGetOwner(), Inflictor, Entity) return false end
		if CPPI and not XCF.DamagePermission(Entity:CPPIGetOwner(), Inflictor, Entity) then return false end
	
		if ( Entity:GetPhysicsObject():IsValid() and !Entity:IsWorld() and !Entity:IsWeapon() ) then
			local Class = Entity:GetClass()
			if ( Class != "gmod_ghost" and Class != "debris" and Class != "prop_ragdoll" and not string.find( Class , "func_" )  ) then
				if !Entity.ACF then 
					ACF_Activate( Entity )
				elseif Entity.ACF.Mass != Entity:GetPhysicsObject():GetMass() then
					ACF_Activate( Entity , true )
				end
				--print("success", Entity.ACF.Type)
				return Entity.ACF.Type	
			end	
		end
	end
	
	--print("ent invalid")
	return false
	
end



function XCF_CreateBulletSWEP( BulletData, Swep, LagComp )

	if not IsValid(Swep) then error("Tried to create swep round with no swep or owner!") return end
	
	local owner = Swep:IsPlayer() and Swep or Swep.Owner or BulletData.Owner or Ply or error("Tried to create swep round with unowned swep!")

	BulletData = table.Copy(BulletData)
	BulletData.TraceBackComp = owner:GetVelocity():Dot(BulletData.Flight:GetNormalized())
	BulletData.Gun = Swep
	
	BulletData.Filter = BulletData.Filter or {}
	BulletData.Filter[#BulletData.Filter + 1] = Swep
	BulletData.Filter[#BulletData.Filter + 1] = owner
	
	local BulletData = XCF.Ballistics.Launch(BulletData)
	if LagComp then
		BulletData.LastThink = SysTime() - owner:Ping() / 1000
		XCF.Ballistics.CalcFlight( BulletData.Index, BulletData )
	end
	
	return BulletData
	
end




XCF.SmokeWind = 5 + math.random()*35

local function msgtoconsole(hud, msg)
	print(msg)
end

util.AddNetworkString("xcf_smokewind")
concommand.Add( "xcf_smokewind", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if not args[1] then printmsg(HUD_PRINTCONSOLE,
		"Set the wind intensity upon all smoke munitions." ..
		"\n   This affects the ability of smoke to be used for screening effect." ..
		"\n   Example; xcf_smokewind 300")
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local wind = tonumber(args[1])

		if not wind then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: that wind value could not be interpreted as a number!")
			return false
		end
		
		XCF.SmokeWind = wind
		
		net.Start("xcf_smokewind")
			net.WriteFloat(wind)
		net.Broadcast()
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: set smoke-wind to " .. wind .. "!")
		return true	
	end
end)

local function sendSmokeWind(ply)
	net.Start("xcf_smokewind")
		net.WriteFloat(XCF.SmokeWind)
	net.Send(ply)
end
hook.Add( "PlayerInitialSpawn", "XCF_SendSmokeWind", sendSmokeWind )