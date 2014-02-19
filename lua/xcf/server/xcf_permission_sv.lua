// This file re-routes old XCF 

//TODO: convar this
local mapSZDir = "xcf/safezones/"
local mapDPMDir = "xcf/permissions/"
file.CreateDir(mapDPMDir)



local function msgtoconsole(hud, msg)
	print(msg)
end



local function convertSZData()
	local files, dirs = file.Find("*", mapSZDir)
	
	if not files or #files == 0 then
		print("Couldn't find any XCF SZ data!")
		return
	end
	
	for k, json in pairs(files) do
		local acfjson = "acf/safezones/" .. json
		local xcfjson = mapSZDir .. json
		
		if file.Exists(acfjson, "DATA") then continue end
		
		print("Moving", xcfjson, "to", acfjson)
		
		local content = file.Read(xcfjson, "DATA")
		if content then
			file.Write(acfjson, content)
			file.Delete(xcfjson)
		end
	end
end



local function convertDPData()
	local files, dirs = file.Find("*", mapDPDir)
	
	if not files or #files == 0 then
		print("Couldn't find any XCF Map-DP data!")
		return
	end
	
	for k, json in pairs(files) do
		local acfjson = "acf/permissions/" .. json
		local xcfjson = mapDPMDir .. json
		
		if file.Exists(acfjson, "DATA") then continue end
		
		print("Moving", xcfjson, "to", acfjson)
		
		local content = file.Read(xcfjson, "DATA")
		if content then
			file.Write(acfjson, content)
			file.Delete(xcfjson)
		end
	end
end



local function markConverted()
	file.CreateDir("xcf")
	file.Write("xcf/dp_moved.txt", "XCF DP has moved to ACF DP!\nLook in the ACF folder for DP data!")
end



local function convertDataToACFDP()

	print("XCF DP has changed to ACF DP!  Converting SZ and DP files...")

	file.CreateDir("acf")
	file.CreateDir("acf/safezones")
	file.CreateDir("acf/permissions")

	convertSZData()
	convertDPData()
	markConverted()
	
	print("Done XCF DP -> ACF DP conversion!")
	
end



local function movedCommand(ply, cmd, args, str)
	local validply = IsValid(ply)
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or msgtoconsole
	printmsg(HUD_PRINTCONSOLE, "ACF DP is replacing XCF DP!  This command will disappear soon!  Find out about ACF DP at http://goo.gl/pe73QH")
	concommand.Run(ply, string.Replace(string.lower(cmd), "xcf", "acf"), args)
end



concommand.Add( "xcf_addsafezone", movedCommand)
concommand.Add( "xcf_removesafezone", movedCommand)
concommand.Add( "xcf_savesafezones", movedCommand)
concommand.Add( "xcf_reloadsafezones", movedCommand)
concommand.Add( "xcf_setpermissionmode", movedCommand)
concommand.Add( "xcf_setdefaultpermissionmode", movedCommand)
concommand.Add( "xcf_reloadpermissionmodes", movedCommand)


	
hook.Add("ACF_ProtectionModeChanged", "XCFBackCompat", function(mode, oldmode)
	hook.Call("XCF_ProtectionModeChanged", GAMEMODE, mode, oldmode)
end)


hook.Add("ACF_PlayerChangedZone", "XCFBackCompat", function(ply, zone, oldzone)
	hook.Call("XCF_PlayerChangedZone", GAMEMODE, ply, zone, oldzone)
end)

