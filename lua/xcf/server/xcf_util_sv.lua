
function XCF_Check(Ent, Inflictor)
	print("WARNING: XCF_Check is no longer needed and is deprecated in favour of ACF_Check!")
	return ACF_Check(Ent)
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




--XCF.SmokeWind = 5 + math.random()*35

local function msgtoconsole(hud, msg)
	print(msg)
end

util.AddNetworkString("xcf_smokewind")
concommand.Add( "xcf_smokewind", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	printmsg(HUD_PRINTCONSOLE, "This command is deprecated in favour of acf_smokewind and will be removed in the future!")
	
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
		
		ACF.SmokeWind = wind
		
		net.Start("acf_smokewind")
			net.WriteFloat(wind)
		net.Broadcast()
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: set smoke-wind to " .. wind .. "!")
		return true	
	end
end)

/*
local function sendSmokeWind(ply)
	net.Start("xcf_smokewind")
		net.WriteFloat(XCF.SmokeWind)
	net.Send(ply)
end
hook.Add( "PlayerInitialSpawn", "XCF_SendSmokeWind", sendSmokeWind )
//*/