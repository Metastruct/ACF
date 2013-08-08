// rewrite of server->client effects using net library instead of effect hax


XCF.NetFX = XCF.NetFX or {}

local this = XCF.NetFX
local str = { //TODO: shared
	SEND 		= "xcf_sendproj",
	END			= "xcf_endproj",
	ENDQUIET	= "xcf_endquietproj",
	ALTER		= "xcf_alterproj"
}



include("xcf/shared/xcf_util_sh.lua")

local oldvec
// Make sure to pcall all code while hack is active - can't afford to mess up global functions for other code.
// doing this because WriteVector compression is horrendous and rewriting the entire WriteTable function is not my current focus.
local function vectorhack(bool)
	if oldvec then return end
	
	if bool then
		oldvec = net.WriteVector
		net.WriteVector = net.WriteVectorDouble
	else
		net.WriteVector = oldvec
		oldvec = nil
	end
end

/**
	Send all clients a projectile definition to begin simulating.
//*/
util.AddNetworkString(str.SEND)
function this.SendProj(Index, Proj)

	local tosend = Proj.ProjClass.GetCompact(Proj)
	
	/*
	print("TO SEND:")
	printByName(tosend)
	print("TO SEND END\n\n")
	//*/
	
	net.Start(str.SEND)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to write new projectile: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()

end



util.AddNetworkString(str.END)
function this.EndProj(Index, Update)
	net.Start(str.END)
	net.WriteInt(Index, 16)
	if Update then
		vectorhack(true)
		pcall(net.WriteTable, Update)
		vectorhack(false)
	else	// signify no update (net lib requires)
		net.WriteTable({[0] = true})
	end
	net.Broadcast()
end



util.AddNetworkString(str.ENDQUIET)
function this.EndProjQuiet(Index)
	net.Start(str.ENDQUIET)
	net.WriteInt(Index, 16)
	net.Broadcast()
end



//TODO: this
util.AddNetworkString(str.ALTER)
function this.AlterProj(Index, Alterations)
	if not Alterations then error("Tried to send invalid projectile update (" .. Index .. ")") end
	
	/*
	print("UPDATE OUT:")
	printByName(Alterations)
	print("UPDATE END")
	//*/
	
	net.Start(str.ALTER)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, Alterations)
	vectorhack(false)
	
	if not success then error("Failure to write projectile alterations: " .. err .. "\n" .. debug.traceback()) end
	net.Broadcast()
end

