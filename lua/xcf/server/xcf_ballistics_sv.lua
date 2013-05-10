// extension of acf ballistics to allow for unbounded projectile types

XCF = XCF or {}

XCF.Projectiles = XCF.Projectiles or {}
XCF.ProjectilesLimit = 250  --The maximum number of bullets in flight at any one time
XCF.LastProj = 0

local projmin = 50
local projmax = 1000
concommand.Add( "xcf_maxprojectiles", function(ply, cmd, args, str)
	if not args[1] then ply:PrintMessage(HUD_PRINTCONSOLE,
		"\"xcf_maxprojectiles\" = " .. XCF.ProjectilesLimit .. "\t(min = " .. projmin .. ", max = " .. projmax .. ")" ..
		"\n - Set the number of flying projectiles at any time." ..
		"\n   Projs fired after the limit will overwrite the oldest flying projs.")
		return
	end
	if ply:IsAdmin() then 
		XCF.ProjectilesLimit = math.Clamp(tonumber(args[1]) or 0, projmin, projmax)
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "You can't change this because you are not an admin.")
	end
end)


XCF.Ballistics = { //TODO: shared
	// Projectile modification event IDs
	["PROJ_INIT"] = 1, 
	["PROJ_UPDATE"] = 2,
	["PROJ_REMOVE"] = 3,
	["PROJ_RETRY"] = 4,	// is really update-then-retry
}
local this = XCF.Ballistics

	
include("xcf/server/xcf_neteffects_sv.lua")
local netfx = XCF.NetFX



function this.Launch( Proj, ProjClass )
	
	if not Proj then return end
	
	Proj = table.Copy(Proj)
	
	//xcf_dbgprint(XCF.LastProj, XCF.ProjectilesLimit, XCF.LastProj % XCF.ProjectilesLimit)
	local curind = (XCF.LastProj % XCF.ProjectilesLimit) + 1 	// TODO: can improve efficiency by caching table length and updating upon add/remove
	XCF.LastProj = curind
	
	if curind > XCF.ProjectilesLimit then return end
	
	if not Proj.ProjClass then
		Proj.ProjClass = ProjClass or XCF.ProjClasses.Shell or error("Tried to create an old projectile, but default projectile class is undefined!")
	end
	
	Proj.ProjClass.Prepare(Proj)
	
	
	local idxproj = XCF.Projectiles[curind]
	xcf_dbgprint("Launching @ index", curind, idxproj and "(existing proj @ index!)" or "")
	if idxproj then this.RemoveProj(curind, true) end
	
	XCF.Projectiles[curind] = Proj
	Proj.Index = curind
	Proj.ProjClass.Launched(Proj)
	
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




function this.CalcFlight( Index, Proj, isRetry )
	
	local result, trace = Proj.ProjClass.DoFlight(Proj, isRetry)
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
		// TODO: use retry on penetration etc once recursion limit is in place
		if 		type == this.PROJ_RETRY  then this.CalcFlight(Index, Proj, update or true)
		elseif 	type == this.PROJ_REMOVE then this.RemoveProj(Index) end
	end
	
end

	
	
	
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

