// This file defines damage permission with all ACF and XCF weaponry

XCF = XCF or {}
XCF.Permissions = {}
XCF.Permissions.Selfkill = true


function XCF.DamagePermission(owner, attacker, ent)
	
	xcf_dbgprint("permission: owner=",tostring(owner), "attacker=",tostring(attacker), "ent=",tostring(ent))
	
	if not CPPI then return true end
	if IsValid(ent) and ent:IsPlayer() or ent:IsNPC() then return true end
	
	if not (attacker and IsValid(attacker)) then /*Dbg("Attacker not valid\n")*/ return false end
	if not (owner and IsValid(owner)) then 
		if IsValid(ent) and ent:IsPlayer() then 
			//Dbg("Ent is player ", ent, "\n")
			owner = ent
		else 
			//Dbg("Owner not valid\n") 
			return false
		end
	end
	
	local ownerid = owner:SteamID()
	local attackerid = attacker:SteamID()
	
	if ownerid == attackerid then
		//Dbg("Owner is attacker\n")
		return XCF.Permissions.Selfkill
	end
	
	if not XCF.Permissions[ownerid] then
		XCF.Permissions[ownerid] = {}
	end
	
	if XCF.Permissions[ownerid][attackerid] then /*Dbg("Attacker is permitted\n")*/ return true end
	
	//Dbg("Fell through\n")
	return false
end


function XCF.AddDamagePermission(owner, attacker)
	if not XCF.Permissions[ownerid] then
		XCF.Permissions[ownerid] = {}
	end
	
	XCF.Permissions[ownerid][attackerid] = true
end


function XCF.RemoveDamagePermission(owner, attacker)
	if not XCF.Permissions[ownerid] then return end
	
	XCF.Permissions[ownerid][attackerid] = nil
end


function XCF.ClearDamagePermissions(owner)
	if not XCF.Permissions[ownerid] then return end
	
	XCF.Permissions[ownerid] = nil
end


function XCF.PermissionsRaw(ownerid, attackerid, value)
	if not ownerid then return end
	
	if not XCF.Permissions[ownerid] then
		XCF.Permissions[ownerid] = {}
	end
	
	if attackerid then
		local old = XCF.Permissions[ownerid][attackerid] and true or nil
		local new = value and true or nil
		XCF.Permissions[ownerid][attackerid] = new
		return old != new
	end
	
	return false
end


local function onDisconnect( ply )
	plyid = ply:SteamID()
	
	if XCF.Permissions[plyid] then
		XCF.Permissions[plyid] = nil
	end
end
hook.Add( "PlayerDisconnected", "XCF_PermissionDisconnect", onDisconnect )


local function plyBySID(steamid)
	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			return v
		end
	end
	
	return false
end


// All code below modified from the NADMOD client permissions menu, by Nebual
// http://www.facepunch.com/showthread.php?t=1221183
util.AddNetworkString("xcf_dmgfriends")
util.AddNetworkString("xcf_refreshfeedback")
net.Receive("xcf_dmgfriends", function(len, ply)
	//Msg("\nsv dmgfriends\n")
	if not ply:IsValid() then return end

	local perms = net.ReadTable()
	local ownerid = ply:SteamID()
	
	//Msg("ownerid = ", ownerid)
	//PrintTable(perms)
	
	local changed
	for k, v in pairs(perms) do
		changed = XCF.PermissionsRaw(ownerid, k, v)
		//Msg(k, " has ", changed and "changed\n" or "not changed\n")
		
		if changed then
			local targ = plyBySID(k)
			if targ then
				local note = v and "given you" or "removed your"
				//Msg("Sending", targ, " ", note, "\n")
				targ:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", ply:Nick() .. " has " .. note .. " permission to damage their objects with ACF!", "NOTIFY_GENERIC" ) )
			end
		end
	end
	
	net.Start("xcf_refreshfeedback")
		net.WriteBit(true)
	net.Send(ply)
	
end)


util.AddNetworkString("xcf_refreshfriends")
net.Receive("xcf_refreshfriends", function(len, ply)
	//Msg("\nsv refreshfriends\n")
	if not ply:IsValid() then return end

	local perms = XCF.Permissions[ply:SteamID()] or {}
	
	net.Start("xcf_refreshfriends")
		net.WriteTable(perms)
	net.Send(ply)
end)

//Msg("loaded rev 5")