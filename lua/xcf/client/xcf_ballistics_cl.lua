

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

//local projs = XCF.ProjClasses or error("Projectile classes haven't been initialized yet.")




function this.CreateProj(Index, Bullet)
	
	printByName(Bullet)
	
	local effect = Bullet.ProjClass.CreateEffect(Bullet)
	XCF.Projectiles[Index] = effect
	effect:Launch()

end




function this.EndProj(index)

	local effect = XCF.Projectiles[index]
	XCF.Projectiles[index] = nil
	if not effect then error("No projectile could be found at index " .. index) end
	effect:EndFlight()
	
end




function this.UpdateProj(index, diffs)

	local effect = XCF.Projectiles[index] or error("No projectile could be found at index " .. index)
	effect:Update(diffs)

end




function this.ProjLoop()

	local Proj
	for i, Proj in pairs(XCF.Projectiles) do
		if not Proj then continue end
		if not Proj.ProjClass then this.EndProj(i) end
		
		Proj.ProjClass.DoFlight(Proj)
	end
	
end
hook.Add("Think", "XCF.ProjLoop", this.ProjLoop)
