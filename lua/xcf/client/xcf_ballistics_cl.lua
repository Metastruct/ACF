

XCF.Projectiles = XCF.Projectiles or {}
XCF.ProjectilesLimit = 1000  --The maximum number of bullets in flight at any one time

XCF.Ballistics = { //TODO: shared
	["CL_INIT"] = 1, 
	["CL_UPDATE"] = 2,
	["CL_REMOVE"] = 3,
	["HIT_NONE"] = "HitNone",
	["HIT_END"] = "EndFlight",
	["HIT_PENETRATE"] = "Penetrate",
	["HIT_RICOCHET"] = "Ricochet"
}
local this = XCF.Ballistics

include("xcf/client/xcf_neteffects_cl.lua")
local netfx = XCF.NetFX




function this.CreateProj(Index, Proj)
	
	Proj.ProjClass.CreateEffect(Proj)
	XCF.Projectiles[Index] = Proj
	Proj.ProjClass.Launch(Proj)

end




function this.EndProj(index)

	local Proj = XCF.Projectiles[index]
	XCF.Projectiles[index] = nil
	if not Proj then error("No projectile could be found at index " .. index) end
	Proj.ProjClass.EndFlight(Proj)
	
end




function this.UpdateProj(index, diffs)

	local Proj = XCF.Projectiles[index] or error("No projectile could be found at index " .. index)
	Proj.ProjClass.Update(diffs)

end




function this.ProjLoop()

	local Proj
	for i, Proj in pairs(XCF.Projectiles) do
		if not Proj then continue end
		if not Proj.ProjClass then print("Removing glitched projectile (no assigned class)") this.EndProj(i) continue end
		
		Proj.ProjClass.DoFlight(Proj)
	end
	
end
hook.Add("Think", "XCF.ProjLoop", this.ProjLoop)
