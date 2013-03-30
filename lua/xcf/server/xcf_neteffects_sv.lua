// rewrite of server->client effects using net library instead of effect hax


XCF.NetFX = XCF.NetFX or {}

local this = XCF.NetFX
local str = { //TODO: shared
	SEND 	= "xcf_sendproj",
	END		= "xcf_endproj",
	ALTER	= "xcf_alterproj"
}


/**
	Send all clients a projectile definition to begin simulating.
//*/
util.AddNetworkString(str.SEND)
function this.SendProj(Index, Proj)

	local tosend = Proj.ProjClass.GetCompact(Proj)
	
	net.Start(str.SEND)
	net.WriteInt(Index, 16)
	net.WriteTable(tosend)
	net.Broadcast()

end



util.AddNetworkString(str.END)
function this.EndProj(Index)
	net.Start(str.END)
	net.WriteInt(Index, 16)
	net.Broadcast()
end



//TODO: this
util.AddNetworkString(str.ALTER)
function this.AlterProj(Index, Alterations)
	net.Start(str.ALTER)
	net.WriteInt(Index, 16)
	net.WriteTable(Alterations)
	net.Broadcast()
end


/*
if (Hit == 1) then		--Bullet has reached end of flight, remove old effect
elseif (Hit == 2) then		--Bullet penetrated, don't remove old effect
elseif (Hit == 3) then		--Bullet ricocheted, don't remove old effect
//*/