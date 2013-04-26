

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

// If net messages arrive out of sequence, these caches ensure that projectiles are created/updated before they're deleted.
this.CreateCache = {}
this.UpdateCache = {}
this.EndCache = {}


include("xcf/client/xcf_neteffects_cl.lua")
local netfx = XCF.NetFX



function this.CreateProj(Index, Proj)
	
	this.CreateCache[Index] = Proj

end


function this.processCreateCache()
	for k, v in pairs(this.CreateCache) do
		this.CreateCache[k] = nil
		this.createProjNow(k, v)
	end
end


function this.createProjNow(Index, Proj)
	
	Proj.ProjClass.CreateEffect(Proj)
	XCF.Projectiles[Index] = Proj
	Proj.Index = Index
	Proj.ProjClass.Launch(Proj)

end




function this.EndProj(index)

	this.EndCache[index] = true
	
end


function this.processEndCache()
	for k, v in pairs(this.EndCache) do
		this.EndCache[k] = nil
		this.endProjNow(k, v)
	end
end


function this.endProjNow(index)

	local Proj = XCF.Projectiles[index]
	XCF.Projectiles[index] = nil
	//if not Proj then error("No projectile could be found at index " .. index) end
	if not Proj then return end
	Proj.ProjClass.EndFlight(Proj)
	
end




function this.UpdateProj(index, diffs)

	this.UpdateCache[#this.UpdateCache + 1] = {index, diffs}

end


function this.processUpdateCache()
	for k, v in pairs(this.UpdateCache) do
		this.UpdateCache[k] = nil
		this.updateProjNow(v[1], v[2])
	end
end


function this.updateProjNow(index, diffs)

	local Proj = XCF.Projectiles[index] or error("No projectile could be found at index " .. index)
	if not diffs then error("NetFX let an invalid update reach the ballistics core! (" .. index .. ")") end
	Proj.ProjClass.Update(Proj, diffs)

end




//TODO: protection against end-event arriving significantly before create-event
function this.ProjLoop()

	this.processCreateCache()
	this.processUpdateCache()

	local Proj
	for i, Proj in pairs(XCF.Projectiles) do
		if not Proj then continue end
		if not Proj.ProjClass then
			print("Removing glitched projectile (no assigned class)")
			this.EndProj(i)
			continue
		end
		
		if not Proj.ProjClass.DoFlight(Proj) then
			print("Flight step failed for projectile " .. tostring(i) .. ", removing.")
			this.EndProj(i)
		end
	end
	
	this.processEndCache()
	
end
hook.Add("Think", "XCF.ProjLoop", this.ProjLoop)

