// rewrite of server->client effects using net library instead of effect hax


XCF.NetFX = XCF.NetFX or {}

local this = XCF.NetFX
local balls = XCF.Ballistics or error("Ballistics hasn't been initialized yet.")
//local projs = XCF.ProjClasses or error("Projectile classes haven't been initialized yet.")
local str = {	//TODO: shared
	SEND 	= "xcf_sendproj",
	END		= "xcf_endproj",
	ALTER	= "xcf_alterproj"
}



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



/**
	Receive a projectile definition to begin simulating.
//*/
function this.ReceiveProj(len)

	local index 	= net.ReadInt(16)
	vectorhack(true)
	local success, compact 	= pcall(net.ReadTable)
	vectorhack(false)
	
	if not (success and compact) then
		print("Received an invalid projectile from the server! (" .. index .. ")")
		return
	end
	
	print("RECV: idx = " .. index .. "\ntbl = ")
	//*
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
net.Receive(str.SEND, this.ReceiveProj)



function this.EndProj(len)
	local index = net.ReadInt(16)
	
	vectorhack(true)
	local success, update = pcall(net.ReadTable)
	vectorhack(false)
	
	if success and update and not update[0] then 
		print("ENDDIFF: idx = " .. index .. "\ntbl = ")
		printByName(update)
		balls.UpdateProj(index, update)
	end
	
	print("ENDP: idx = " .. index)
	balls.EndProj(index)
end
net.Receive(str.END, this.EndProj)




function this.AlterProj(len)
	local index 	= net.ReadInt(16)
	vectorhack(true)
	local success, diffs = pcall(net.ReadTable)
	vectorhack(false)
	
	print(tostring(success), tostring(diffs))
	
	if not (success and diffs) then
		print("Received an invalid update for projectile " .. index .. "!")
		return
	end
	
	print("DIFF: idx = " .. index .. "\ntbl = ")
	printByName(diffs)
	
	balls.UpdateProj(index, diffs)
end
net.Receive(str.ALTER, this.AlterProj)

