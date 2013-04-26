// extension of acf ballistics to allow for unbounded projectile types

XCF = XCF or {}

XCF.Projectiles = XCF.Projectiles or {}
XCF.ProjectilesLimit = 250  --The maximum number of bullets in flight at any one time
XCF.LastProj = 0

concommand.Add( "xcf_maxprojectiles", function(ply, cmd, args, str)
	if ply:IsAdmin() then 
		XCF.ProjectilesLimit = math.Clamp(tonumber(args[1]), 50, 1000)
	end
end)


XCF.Ballistics = { //TODO: shared
	// Projectile modification event IDs
	["PROJ_INIT"] = 1, 
	["PROJ_UPDATE"] = 2,
	["PROJ_REMOVE"] = 3,
	
	// These correlate with callbacks in the projectile classes.
	// TODO: move these into the proj classes
	["HIT_NONE"] = "HitNone",
	["HIT_END"] = "EndFlight",
	["HIT_PENETRATE"] = "Penetrate",
	["HIT_RICOCHET"] = "Ricochet"
}
local this = XCF.Ballistics

	
include("xcf/server/xcf_neteffects_sv.lua")
local netfx = XCF.NetFX



function this.Launch( Proj, ProjClass )
	
	print(Proj, ProjClass)
	
	if not Proj then return end
	
	Proj = table.Copy(Proj)
	
	local curind = (XCF.LastProj % XCF.ProjectilesLimit) + 1 	// TODO: can improve efficiency by caching table length and updating upon add/remove
	XCF.LastProj = curind
	
	if curind > XCF.ProjectilesLimit then return end
	
	if not Proj.ProjClass then
		Proj.ProjClass = ProjClass or XCF.ProjClasses.Shell or error("Tried to create an old projectile, but default projectile class is undefined!")
	end
	
	Proj.ProjClass.Prepare(Proj)
	
	local idxproj = XCF.Projectiles[curind]
	if idxproj then this.RemoveProj(curind, true) end
	
	XCF.Projectiles[curind] = Proj
	Proj.Index = curind
	
	printByName(Proj)
	
	this.NotifyClients(curind, Proj, this.PROJ_INIT)
	this.CalcFlight(curind, Proj)
	
	return Proj
	
end



function this.ProjLoop()

	local Proj
	for i, Proj in pairs(XCF.Projectiles) do
		if not Proj then continue end
		if not Proj.ProjClass then print("Removing glitched projectile (no assigned class)") this.RemoveProj(i) continue end
		
		this.CalcFlight( i, Proj )
	end
	
end
hook.Add("Think", "XCF.ProjLoop", this.ProjLoop)




//TODO: make quiet work (remove projectile without any end effects, must notify client)
function this.RemoveProj( Index, quiet )
	
	local Proj = XCF.Projectiles[Index]
	if not Proj then return end
	XCF.Projectiles[Index] = nil
	
	this.NotifyClients(Index, Proj, this.PROJ_REMOVE)
	local removed = Proj.ProjClass.Removed
	if removed then removed(Proj) end
	
end




function this.CalcFlight( Index, Proj )
	
	local result, trace = Proj.ProjClass.DoFlight(Proj)
	if not result then
		print("Projectile did not return a result value: removing.")
		this.RemoveProj(Index)
		return
	end

	local callback
	if result then
		callback = Proj.ProjClass[result]
		if not callback then return end
		
		local update, type = callback(Index, Proj, trace)
		if type then this.NotifyClients(Index, Bullet, type, update) end
		if type == this.PROJ_REMOVE then this.RemoveProj(Index) end
	end
	
end




/*
local hittable = {}
hittable[this.CL_HIT_NONE] = function( Index, Bullet, Type, Hit, HitPos )	// update in flight
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_NONE
		return ret
	end
hittable[this.CL_HIT_END] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_END
		return ret
	end
hittable[this.CL_HIT_PENETRATE] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_PENETRATE
		return ret
	end
hittable[this.CL_HIT_RICOCHET] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_RICOCHET
		return ret
	end
//*/

	
	
	
function this.NotifyClients( Index, Bullet, Type, update)

	if Type == this.PROJ_UPDATE then
		netfx.AlterProj(Index, update)
	elseif Type == this.PROJ_REMOVE then
		netfx.EndProj(Index, update)
	elseif Type == this.PROJ_INIT then
		netfx.SendProj(Index, Bullet)
	else
		error("Tried to send an unrecognized client update type (" .. tostring(Type) .. ")!\n" .. debug.traceback())
	end

end

