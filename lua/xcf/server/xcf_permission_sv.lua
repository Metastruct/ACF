// This file defines damage permission with all ACF and XCF weaponry

XCF = XCF or {}
XCF.Permissions = {}

//TODO: make player-customizable
XCF.Permissions.Selfkill = true

XCF.Permissions.Safezones = false

XCF.Permissions.Modes = {}
XCF.Permissions.ModeDescs = {}

//TODO: convar this
local mapSZDir = "xcf/safezones/"




local function msgtoconsole(hud, msg)
	print(msg)
end




local function resolveAABBs(mins, maxs)
	
	/*
	for xyz, val in pairs(mins) do	// ensuring points conform to AABB mins/maxs
		if val > maxs.xyz then
			local store = maxs.xyz
			maxs.xyz = val
			mins.xyz = store
		end
	end
	//*/
	
	local store
	if mins.x > maxs.x then
		store = maxs.x
		maxs.x = mins.x
		mins.x = store
	end
	
	if mins.y > maxs.y then
		store = maxs.y
		maxs.y = mins.y
		mins.y = store
	end
	
	if mins.z > maxs.z then
		store = maxs.z
		maxs.z = mins.z
		mins.z = store
	end
	
	return mins, maxs
end


//TODO: sanitize safetable instead of marking it all as bad
local function validateSZs(safetable)
	if type(safetable) ~= "table" then return false end
	
	PrintTable(safetable)

	for k, v in pairs(safetable) do
		if type(k) ~= "string" then return false end
		if not (#v == 2 and v[1] and v[2]) then return false end
		
		for a, b in ipairs(v) do
			if not (b.x and b.y and b.z) then return false end
		end
		
		local mins = v[1]
		local maxs = v[2]
		
		mins, maxs = resolveAABBs(mins, maxs)
		
	end
	
	return true
end




local function getMapFilename()
	
	local mapname = string.gsub(game.GetMap(), "[^%a%d-_]", "_")
	return mapSZDir .. mapname .. ".txt"
	
end



local function getMapSZs()
	local mapname = getMapFilename()
	local mapSZFile = file.Read(mapname, "DATA") or ""
	
	local safezones = util.JSONToTable(mapSZFile)
	
	if not validateSZs(safezones) then
		// TODO: generate default safezones around spawnpoints.
		return false
	end
	
	XCF.Permissions.Safezones = safezones
	return true
end




hook.Add( "Initialize", "XCF_LoadSafesForMap", function()
	if not getMapSZs() then
		print("!!!!!!!!!!!!!!!!!!\nWARNING: Safezone file " .. mapname .. " is missing, invalid or corrupt!  Safezones will not be restored this time.\n!!!!!!!!!!!!!!!!!!")
	end
end )




local plyzones = {}
hook.Add("Think", "XCF_DetectSZTransition", function()
	for k, ply in pairs(player.GetAll()) do
		local sid = ply:SteamID()
		local trans = false
		local pos = ply:GetPos()
		local oldzone = plyzones[sid]
		
		local zone = XCF.IsInSafezone(pos) or nil
		plyzones[sid] = zone
		
		if oldzone ~= zone then
			hook.Call("XCF_PlayerChangedZone", GAMEMODE, ply, zone, oldzone)
		end
	end
end)




concommand.Add( "xcf_addsafezone", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if not args[1] then printmsg(HUD_PRINTCONSOLE,
		" - Add a safezone as an AABB box." ..
		"\n   Input a name and six numbers.  First three numbers are minimum co-ords, last three are maxs." ..
		"\n   Example; xcf_addsafezone airbase -500 -500 0 500 500 1000")
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local szname = tostring(args[1])
		args[1] = nil
		local default = tostring(args[8])
		if default ~= "default" then default = nil end
		
		if not XCF.Permissions.Safezones then XCF.Permissions.Safezones = {} end
		
		if XCF.Permissions.Safezones[szname] and XCF.Permissions.Safezones[szname].default then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: an unmodifiable safezone called " .. szname .. " already exists!")
			return false
		end
	
		for k, v in ipairs(args) do			
			args[k] = tonumber(v)
			if args[k] == nil then 
				printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: argument " .. k .. " could not be interpreted as a number (" .. v .. ")")
				return false
			end
		end
		
		local mins = Vector(args[2], args[3], args[4])
		local maxs = Vector(args[5], args[6], args[7])
		mins, maxs = resolveAABBs(mins, maxs)
		
		XCF.Permissions.Safezones[szname] = {mins, maxs}
		if default then XCF.Permissions.Safezones[szname].default = true end
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: added a safezone called " .. szname .. " between " .. tostring(mins) .. " and " .. tostring(maxs) .. "!")
		return true	
	end
end)




concommand.Add( "xcf_removesafezone", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if not args[1] then printmsg(HUD_PRINTCONSOLE,
		" - Delete a safezone using its name." ..
		"\n   Input a safezone name.  If it exists, it will be removed." ..
		"\n   Deletion is not permanent until safezones are saved.")
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local szname = tostring(args[1])
		if not szname then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: could not interpret your input as a string.")
			return false
		end
		
		if not (XCF.Permissions.Safezones and XCF.Permissions.Safezones[szname]) then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: could not find a safezone called " .. szname .. ".")
			return false
		end
		
		if XCF.Permissions.Safezones[szname].default then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: an unmodifiable safezone called " .. szname .. " already exists!")
			return false
		end
		
		XCF.Permissions.Safezones[szname] = nil
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: removed the safezone called " .. szname .. "!")
		return true	
	end
end)




concommand.Add( "xcf_savesafezones", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else	
		if not XCF.Permissions.Safezones then 
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: There are no safezones on the map which can be saved.")
			return false
		end
		
		local szjson = util.TableToJSON(XCF.Permissions.Safezones)
		
		local mapname = getMapFilename()
		file.CreateDir(mapSZDir)
		file.Write(mapname, szjson)
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: All safezones on the map have been made restorable.")
		return true	
	end
end)




concommand.Add( "xcf_reloadsafezones", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local ret = getMapSZs()
		
		if ret then
			printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: All safezones on the map have been restored.")
		else
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: Safezone file for this map is missing, invalid or corrupt.")
		end
		return ret
	end
end)




concommand.Add( "xcf_setpermissionmode", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole

	if not args[1] then 
		local modes = ""
		for k, v in pairs(XCF.Permissions.Modes) do
			modes = modes .. k .. " "
		end
		printmsg(HUD_PRINTCONSOLE,
		" - Set damage permission behaviour mode." ..
		"\n   Available modes: " .. modes)
		return false
	end
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		local mode = tostring(args[1])
		if not XCF.Permissions.Modes[mode] then
			printmsg(HUD_PRINTCONSOLE, 
			"Command unsuccessful: " .. mode .. " is not a valid permission mode!" .. 
			"\nUse this command without arguments to see all available modes.")
			return false
		end
		
		local oldmode = table.KeyFromValue(XCF.Permissions.Modes, XCF.DamagePermission)
		XCF.DamagePermission = XCF.Permissions.Modes[mode]
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: Current damage permission policy is now " .. mode .. "!")
		
		hook.Call("XCF_ProtectionModeChanged", GAMEMODE, mode, oldmode)
		
		return true
	end
end)




concommand.Add( "xcf_reloadpermissionmodes", function(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	
	if validply and not ply:IsAdmin() then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
		
	else
		if not aaa_IncludeHere then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful: folder-loading function is not available.")
			return false
		end
		
		aaa_IncludeHere("xcf/server/permissionmodes")
		
		local mode = table.KeyFromValue(XCF.Permissions.Modes, XCF.DamagePermission)
		
		if not mode then
			XCF.DamagePermission = function() return true end
			hook.Call("XCF_ProtectionModeChanged", GAMEMODE, "default", nil)
			mode = "default"
		end
		
		printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: Current damage permission policy is now " .. mode .. "!")
		return true
	end
end)




local function tellPlysAboutDPMode(mode, oldmode)
	if mode == oldmode then return end
	
	for k, v in pairs(player.GetAll()) do
		v:SendLua("chat.AddText(Color(255,0,0),\"Damage protection has been changed to " .. mode .. " mode!\")") 
	end
end
hook.Add("XCF_ProtectionModeChanged", "XCF_TellPlysAboutDPMode", tellPlysAboutDPMode)




function XCF.IsInSafezone(pos)

	if not XCF.Permissions.Safezones then return false end
	
	local szmin, szmax
	for szname, szpts in pairs(XCF.Permissions.Safezones) do
		szmin = szpts[1]
		szmax = szpts[2]
		
		if	(pos.x > szmin.x and pos.y > szmin.y and pos.z > szmin.z) and 
			(pos.x < szmax.x and pos.y < szmax.y and pos.z < szmax.z) then
			return szname
		end
	end
	return false
end




function XCF.Permissions.RegisterMode(mode, name, desc)
	XCF.Permissions.Modes[name] = mode
	XCF.Permissions.ModeDescs[name] = desc
	
	print("XCF: Registered damage permission mode \"" .. name .. "\"!")
end




XCF.DamagePermission = function() return true end
hook.Call("XCF_ProtectionModeChanged", GAMEMODE, "default", nil)




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
	
	plyzones[plyid] = nil
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