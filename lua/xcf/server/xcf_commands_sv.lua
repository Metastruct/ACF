XCF = XCF or {}

XCF.Commands = {}



function util.b2n(bool) return bool and 1 or 0 end


function XCF.AddSpecialCVar(type,cmd, def, admin, desc, func)

	if func then 
		XCF.Commands[cmd] = {func=func,type=type,default=def,adminonly=admin,description=desc,current=def}
	else
		XCF.Commands[cmd] = {type=type,default=def,adminonly=admin,description=desc}
	end
	
	if not GetConVar(cmd) then 
		concommand.Add(cmd,function(ply,cmd,args) XCF.RunCommand(ply,cmd,args) end)
	end
end

function XCF.RunCommand(ply,cmd,args)

	if not GetConVar(cmd) then return end
	
	local validply = IsValid(ply)
	local adminonly = validply and not ply:IsAdmin() and XCF.Commands[cmd]["adminonly"]
	local printmsg = validply and function(hud, msg) ply:PrintMessage(hud, msg) end or function(hud, msg) print(msg) end
	
	if validply and adminonly then
		printmsg(HUD_PRINTCONSOLE, "You can't use this because you are not an admin.")
		return false
	else
		if args[1] and not type(args[1]) == "number" then
			printmsg(HUD_PRINTCONSOLE, "Command unsuccessful:  the arguments must be a number!")
			return false
		end
		
		if not args[1] then
			printmsg(HUD_PRINTCONSOLE, "Command: "..cmd..
			"\n\nDescription: "..XCF.Commands[cmd]["description"]..
			"\n\nCurrent Value: "..XCF.Commands[cmd]["current"]..
			"\nDefault Value: "..XCF.Commands[cmd]["default"])
			return false
		end
		
		if XCF.Commands[cmd]["func"] then
			local _,err = pcall(function() 
				printmsg(HUD_PRINTCONSOLE, "Command SUCCESSFUL: "..cmd.." set to "..args[1].." from "..XCF.Commands[cmd]["current"])
				XCF.Commands[cmd]["current"] = XCF.Commands[cmd]["func"](ply,cmd,args) 
			end)
			if err then
				print(err)
			end
		end
		return true
	end
end


/*
util.AddNetworkString("xcf_refreshpermissions")
net.Receive("xcf_convars",function(len,ply)

	net.Start("xcf_convars")
		net.WriteTable(XCF.Commands)
	net.Send(ply)
	
end)
*/

//normal types are Guns, Ammo, Setting, and Mobility, but you can name it whatever, its for the location on the panel


// to create new cvars :

//XCF.AddSpecialCVar(type,convar,default,adminonly,description,function
// stuff return default
//end

 

// to convert cvars to the panel:

//XCF.AddSpecialCVar(type,convar,default,adminonly,description)

---------------------------------------------------------------------------------------------------------------------------------------

// converting some convars for the panel
XCF.AddSpecialCVar("Setting","sbox_max_acf_gun", GetConVarNumber("sbox_max_acf_gun"), true, "Max amount of ACF Gun Entities." )
XCF.AddSpecialCVar("Setting","sbox_max_acf_ammo", GetConVarNumber("sbox_max_acf_ammo"), true, "Max amount of ACF Ammo Entities." )
XCF.AddSpecialCVar("Setting","sbox_max_acf_misc", GetConVarNumber("sbox_max_acf_misc"), true, "Max amount of Miscellaneous ACF Entities." )




XCF.AddSpecialCVar("Guns","xcf_gunfire", util.b2n(ACF.GunfireEnabled), true, "Allow weapons to fire rounds.", function(ply,cmd,args) 
	ACF.GunfireEnabled = util.tobool(args[1]) return util.b2n(ACF.GunfireEnabled)
end)
