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


/**
	Receive a projectile definition to begin simulating.
//*/
function this.ReceiveProj(len)

	local index 	= net.ReadInt(16)
	local compact 	= net.ReadTable()
	
	print("RECV: idx = " .. index .. "\ntbl = ")
	printByName(compact)
	
	compact.ProjClass = XCF.ProjClasses[compact.ProjClass] or error("Couldn't find appropriate projectile class for " .. compact.ProjClass .. "!")
	
	local proj = compact.ProjClass.GetExpanded(compact)
	
	balls.CreateProj(index, proj)

end
net.Receive(str.SEND, this.ReceiveProj)



function this.EndProj(len)
	local index = net.ReadInt(16)
	print("ENDP: idx = " .. index)
	
	balls.EndProj(index)
end
net.Receive(str.END, this.EndProj)


//TODO: this
function this.AlterProj(len)
	local index 	= net.ReadInt(16)
	local diffs 	= net.ReadTable()
	
	print("DIFF: idx = " .. index .. "\ntbl = ")
	printByName(diffs)
	
	balls.UpdateProj(index, diffs)
end
net.Receive(str.END, this.EndProj)

/*
if (Hit == 1) then		--Bullet has reached end of flight, remove old effect
elseif (Hit == 2) then		--Bullet penetrated, don't remove old effect
elseif (Hit == 3) then		--Bullet ricocheted, don't remove old effect
//*/