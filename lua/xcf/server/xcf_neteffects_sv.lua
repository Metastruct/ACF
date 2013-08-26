// rewrite of server->client effects using net library instead of effect hax

include("xcf/shared/xcf_util_sh.lua")

XCF.NetFX = XCF.NetFX or {}

local this = XCF.NetFX
local str = this.Strings
local ammouids = this.AmmoUIDs

if not (str or ammouids) then 
	include("xcf/shared/xcf_neteffects_sh.lua")
	str = this.Strings or error("Couldn't load XCF net strings.")
	ammouids = this.AmmoUIDs
end


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



local ammoAttribs
local function generateAmmoUID(ammo)
	if not IsValid(ammo) then error("Got invalid ammo in net create hook: " .. tostring(ammo)) return end
	
	if not ammoAttribs then
		local dupeEntTbl = duplicator.FindEntityClass("acf_ammo")
		if not dupeEntTbl then error("Couldn't find duplicator records for acf_ammo!") return end
		ammoAttribs = table.Copy(dupeEntTbl.Args)
		table.remove(ammoAttribs, 1)
		table.remove(ammoAttribs, 1)
		if not ammoAttribs then error("Couldn't find duplicator-replicable attributes for acf_ammo!") return end
	end
	
	local attribs = {}
	--printByName(ammoAttribs)
	for k, v in pairsByName(ammoAttribs) do
		--print(k, v, ammo[v])
		attribs[#attribs + 1] = ammo[v] or error("No ammo-data available for " .. tostring(v) .. "!")
	end
	
	local ammoUID = util.CRC(table.concat(attribs))
	ammo.NetUID = ammoUID
	if ammo.BulletData then
		ammo.BulletData.NetUID = ammoUID
	end
	
	return ammoUID
end



local function ammoHook(ammo)
	
	local uid  = generateAmmoUID(ammo)
	--print("Got UID", uid)
	--[[
	local uids = ammouids[uid]
	if not uids then
		uids = {}
		ammouids[uid] = uids
	end
	uids[uids+1] = ammo
	ammo:CallOnRemove( "xcfammo_remUID",
		function(ent)
			local uid = ammo.NetUID
			if not uid then print("WARNING: Destroyed ammo was not net-registered!") return end
			local uids = ammouids[uid]
			table.remove(uids, ent)
		end
	)
	--]]--
	
	this.AmmoRegisterNet(ammo)
	
end
hook.Add("ACF_AmmoCreate", "XCF_NetAmmo", ammoHook)




function this.AmmoRegisterNet(ammo)
	if not ammo.NetUID then error("Tried to register ammo across net without a net id!") return end
	
	local bData = ammo.BulletData or error("Tried to register ammo across net without bullet data!")
	local tosend = bData.ProjClass.GetCompact(bData)
	
	/*
	print("TO AMMOREG:", ammo.NetUID)
	printByName(tosend)
	print("TO AMMOREG END\n\n")
	//*/
	
	//TODO: more this
	//*
	net.Start(str.AMMOREG)
	net.WriteDouble(ammo.NetUID)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to register new ammo across net: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()
	//*/
	
end




/**
	Send all clients a projectile definition to begin simulating.
//*/
function this.SendProj(Index, Proj)

	if Proj.NetUID then
		this.SendUIDProj(Index, Proj)
	else
		this.SendFullProj(Index, Proj)
	end

end



function this.SendUIDProj(Index, Proj)

	local tosend = {
		ID = Proj.NetUID,
		Pos = Proj.Pos or error("No projectile 'Pos' index for proj no. " .. tostring(Index)),
		Dir = Proj.Flight or error("No projectile 'Flight' index for proj no. " .. tostring(Index))
	}
	/*
	print("TO SENDUID:")
	printByName(tosend)
	print("TO SENDUID END\n\n")
	//*/
	
	net.Start(str.SENDUID)
	net.WriteInt(Index, 16)
	vectorhack(true)
	local success, err = pcall(net.WriteTable, tosend)
	vectorhack(false)
	
	if not success then error("Failure to write new projectile: " .. err .. "\n" .. debug.traceback()) end
	
	net.Broadcast()
	
end



function this.SendFullProj(Index, Proj)

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



function this.EndProjQuiet(Index)
	net.Start(str.ENDQUIET)
	net.WriteInt(Index, 16)
	net.Broadcast()
end



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

