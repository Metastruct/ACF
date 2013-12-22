// rewrite of server->client effects using net library instead of effect hax


XCF.NetFX = XCF.NetFX or {}

local balls = XCF.Ballistics or error("Ballistics hasn't been initialized yet.")
local this = XCF.NetFX
local str = this.Strings
local ammouids = this.AmmoUIDs

if not (str or ammouids) then 
	include("xcf/shared/xcf_neteffects_sh.lua")
	str = this.Strings or error("Couldn't load XCF net strings.")
	ammouids = this.AmmoUIDs
end




include("xcf/shared/xcf_util_sh.lua")

local oldvec
local function vectorhack(bool)
	if oldvec then return end
	
	if bool then
		oldvec = net.ReadVector
		net.ReadVector = net.ReadVectorDouble
	else
		net.ReadVector = oldvec or net.ReadVector
		oldvec = nil
	end
end




-- Retains old ammo registry: if collisions occur, we want to keep the old things working.
-- TODO: if collisions become a common complaint, improve id-ing.
function this.AmmoRegister(len)

	local uid 	= net.ReadDouble()
	vectorhack(true)
	local success, compact 	= pcall(net.ReadTable)
	vectorhack(false)
	
	if not (uid and success and compact) then
		print("Received an invalid ammo registration from the server!")
		return
	end
	
	compact.ProjClass = XCF.ProjClasses[compact.ProjClass] or error("Couldn't find appropriate projectile class for " .. compact.ProjClass .. "!")
	local proj = compact.ProjClass.GetExpanded(compact)
	
	--[[
	print("AMMOREG: uid = " .. uid .. "\ntbl = ")
	printByName(compact)
	printByName(compact.Colour or {255, 255, 255})
	print("AMMOREG END\n\n")
	--]]--
	//*
	local uidstr = tostring(uid)
	local tblproj = ammouids[uidstr]
	
	if tblproj then
		local vtype
		for k, v in pairs(tblproj) do
			vtype = type(v)
			if vtype == "number" or vtype == "string" then
				if v ~= proj[k] then error("Ammo NetUID collision - a new, different ammocrate has the same NetUID as an old one!  The old ammo data has been retained.") return end
			end
		end
		
		for k, v in pairs(proj) do
			vtype = type(v)
			if vtype == "number" or vtype == "string" then
				if v ~= tblproj[k] then error("Ammo NetUID collision - a new, different ammocrate has the same NetUID as an old one!  The old ammo data has been retained.") return end
			end
		end
	else
		ammouids[uidstr] = proj
		--[[
		print("REPLACING ammouids", uid, "=")
		printByName(proj)
		--]]--
	end
	//*/
	
	this.UIDLastBad[uidstr] = nil
end
net.Receive(str.AMMOREG, this.AmmoRegister)




function this.AmmoDeregister(len)
	local uid = net.ReadDouble()
	--print("AMMODEREG: uid = " .. uid)
	
	local uidtbl = ammouids[tostring(uid)]
	if not uidtbl then print("WARNING: Tried to de-register an unregistered ammo-type!") return end
	
	this.AmmoQueuedDeregister(uid)
end
net.Receive(str.AMMODEREG, this.AmmoDeregister)



this.UIDLastBad = {}
this.PerBadUIDWait = 1
function this.UnknownAmmoUID(uid)

	local uidtype = type(uid)
	local uidstr
	
	if uidtype == "string" then
		uidstr = uid
		uid = tonumber(uid)
	elseif uidtype == "number" then 
		uidstr = tostring(uid)
	else
		error("Tried to request resend of an invalid ammo UID!")
		return
	end
	
	local lastbad = this.UIDLastBad[uidstr]
	local curtime = CurTime()
	
	if not lastbad or (lastbad + this.PerBadUIDWait <= curtime) then
		--print("Requesting resend of ammo UID", uid, "...")
		net.Start(str.BADUID)
			net.WriteDouble(uid)
		net.SendToServer()
		
		this.UIDLastBad[uidstr] = curtime
	end

end




local ammoderegq = ammoderegq or {}

local function doAmmoDereg()
	--local ammoderegqCt = #ammoderegq
	--print("AmmoDereg", #XCF.Projectiles, ammoderegqCt)
	if #XCF.Projectiles == 0 and #ammoderegq > 0 then
		for k, uid in pairs(ammoderegq) do
			ammouids[tostring(uid)] = nil
		end
		--print("Deregistered", ammoderegqCt, "ammo datas.")
		ammoderegq = {}
		timer.Remove("XCF_AmmoQueuedDeregister")
	end
end




function this.AmmoQueuedDeregister(uid)
	--print("AmmoDRGQ", uid, #ammoderegq)
	if uid and #ammoderegq == 0 then
		timer.Create("XCF_AmmoQueuedDeregister", 0.5, 0, doAmmoDereg)
	end
	
	ammoderegq[#ammoderegq + 1] = uid
end




function this.ReceiveProjUID(len)

	local index 	= net.ReadInt(16)
	vectorhack(true)
	local success, compact 	= pcall(net.ReadTable)
	vectorhack(false)
	
	if not (success and compact) then
		print("Received an invalid uid-projectile from the server! (" .. index .. ")")
		return
	end
	
	/*
	print("RECVUID: idx = " .. index .. "\ntbl = ")
	printByName(compact)
	print("RECVUID END\n\n")
	//*/
	
	local ammoType = ammouids[tostring(compact.ID)]--	or error("Couldn't find appropriate ammo info for projectile " .. index .. "!")
	if not ammoType then
		print("Couldn't find appropriate ammo info for projectile " .. index .. "!")
		this.UnknownAmmoUID(compact.ID)
		return
	end
	
	local proj = table.Copy(ammoType)
	proj.Pos = compact.Pos
	proj.Flight = compact.Dir
	
	/*
	print("EXPANDED:\n")
	printByName(proj)
	print("EXPANDED END\n\n\n")
	//*/
	
	balls.CreateProj(index, proj)
	
end
net.Receive(str.SENDUID, this.ReceiveProjUID)




/**
	Receive a projectile definition to begin simulating.
//*/
function this.ReceiveProjFull(len)

	local index 	= net.ReadInt(16)
	vectorhack(true)
	local success, compact 	= pcall(net.ReadTable)
	vectorhack(false)
	
	if not (index and success and compact) then
		print("Received an invalid projectile from the server! (" .. index .. ")")
		return
	end
	
	/*
	print("RECV: idx = " .. index .. "\ntbl = ")
	printByName(compact)
	print("RECV END\n\n")
	//*/
	
	compact.ProjClass = XCF.ProjClasses[compact.ProjClass] or error("Couldn't find appropriate projectile class for " .. compact.ProjClass .. "!")
	
	local proj = compact.ProjClass.GetExpanded(compact)
	
	/*
	print("EXPANDED:\n")
	printByName(proj)
	print("EXPANDED END\n\n\n")
	//*/
	
	balls.CreateProj(index, proj)

end
net.Receive(str.SEND, this.ReceiveProjFull)




function this.EndProj(len)
	local index = net.ReadInt(16)
	
	vectorhack(true)
	local success, update = pcall(net.ReadTable)
	vectorhack(false)
	
	if success and update and not update[0] then 
		/*
		print("ENDDIFF: idx = " .. index .. "\ntbl = ")
		printByName(update)
		//*/
		balls.UpdateProj(index, update)
	end
	
	//print("ENDP: idx = " .. index)
	balls.EndProj(index)
end
net.Receive(str.END, this.EndProj)




function this.EndProjQuiet(len)
	local index = net.ReadInt(16)
	
	--print("ENDQ: idx = " .. index)
	balls.EndProjQuiet(index)
end
net.Receive(str.ENDQUIET, this.EndProjQuiet)




function this.AlterProj(len)
	local index 	= net.ReadInt(16)
	vectorhack(true)
	local success, diffs = pcall(net.ReadTable)
	vectorhack(false)
	
	//print(tostring(success), tostring(diffs))
	
	if not (index and success and diffs) then
		--print("Received an invalid update for projectile " .. index .. "!")
		return
	end
	
	/*
	print("DIFF: idx = " .. index .. "\ntbl = ")
	printByName(diffs)
	//*/
	
	balls.UpdateProj(index, diffs)
end
net.Receive(str.ALTER, this.AlterProj)

