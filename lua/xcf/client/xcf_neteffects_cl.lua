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
	
	compact.ProjClass = XCF.ProjClasses[compact.ProjClass] or error("Couldn't find appropriate projectile class for " .. compact.ProjClass .. "!")
	
	local proj = compact.ProjClass.GetExpanded(compact)
	
	balls.CreateProj(index, proj)

end
net.Receive(str.SEND, this.ReceiveProj)



function this.EndProj(len)
	balls.EndProj(net.ReadInt(16))
end
net.Receive(str.END, this.EndProj)


//TODO: this
function this.AlterProj(len)
	local index 	= net.ReadInt(16)
	local diffs 	= net.ReadTable()
	
	balls.UpdateProj(index, diffs)
end
net.Receive(str.END, this.EndProj)

/*
if (Hit == 1) then		--Bullet has reached end of flight, remove old effect
elseif (Hit == 2) then		--Bullet penetrated, don't remove old effect
elseif (Hit == 3) then		--Bullet ricocheted, don't remove old effect
//*/