// extension of acf ballistics to allow for unbounded projectile types

XCF = XCF or {}

XCF.Projectiles = XCF.Projectiles or {}
XCF.ProjectilesLimit = 1000  --The maximum number of bullets in flight at any one time

XCF.Ballistics = { //TODO: shared
	["CL_INIT"] = 1, 
	["CL_UPDATE"] = 2,
	["CL_REMOVE"] = 3,
	
	["HIT_NONE"] = "HitNone",
	["HIT_END"] = "EndFlight",
	["HIT_PENETRATE"] = "Penetrate",
	["HIT_RICOCHET"] = "Ricochet",
}
local this = XCF.Ballistics
/*
timer.Create("XCFBallsGetDefClass", 1, 0,
	function() 
		if XCF.ProjClasses then 
			this.DEFAULT_PROJCLASS = XCF.ProjClasses.Shell
			timer.Remove("XCFBallsGetDefClass")
			print("got it!!")
		else
			print("didn't get it this time")
		end
	end)
//*/
	
include("xcf/server/xcf_neteffects_sv.lua")
local netfx = XCF.NetFX

//local projs = XCF.ProjClasses or error("Projectile classes haven't been initialized yet.")



function this.Launch( Proj, ProjClass )
	
	if not Proj then return end
	
	local curind = #XCF.Projectiles + 1	// TODO: can improve efficiency by caching table length and updating upon add/remove
	if curind > XCF.ProjectilesLimit then return end
	
	if not Proj.ProjClass then
		Proj.ProjClass = ProjClass or XCF.ProjClasses.Shell or error("Tried to create an old projectile, but default projectile class is undefined!")
	end
	
	Proj.ProjClass.Prepare(Proj)	// todo: see if acf framework can support class-based projectiles or if it needs total overhaul
		
	XCF.Projectiles[curind] = Proj
	Proj.Index = curind
	
	this.NotifyClients(curind, Proj, this.CL_INIT)
	this.CalcFlight(curind, Proj)
	
	return Proj
	
end




function this.ProjLoop()

	local Proj
	for i, Proj in pairs(XCF.Projectiles) do
		//print(i, Proj)
		if not Proj then continue end
		if not Proj.ProjClass then this.RemoveProj(i) end
		
		this.CalcFlight( i, Proj )
	end
	
end
hook.Add("Think", "XCF.ProjLoop", this.ProjLoop)




function this.RemoveProj( Index )
	
	local Proj = XCF.Projectiles[Index]
	XCF.Projectiles[Index] = nil
	this.NotifyClients(Index, Proj, this.CL_REMOVE)
	Proj.ProjClass.Removed(Proj) // todo: see if acf framework can support class-based projectiles or if it needs total overhaul

end




function this.CalcFlight( Index, Proj )
	
	local result, trace = Proj.ProjClass.DoFlight(Proj)
	if not result then this.RemoveProj(Index) return end
	
	if result != this.HIT_NONE then 
		Proj.ProjClass[result](Index, Proj, trace)
	end
	
end




local hittable = {}
hittable[0] = function( Index, Bullet, Type, Hit, HitPos )	// update in flight
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_NONE
		return ret
	end
hittable[1] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_END
		return ret
	end
hittable[2] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_PENETRATE
		return ret
	end
hittable[3] = function( Index, Bullet, Type, Hit, HitPos )	// update upon end hit
		local ret =  Bullet.ProjClass.GetUpdate()
		ret.UpdateType = this.HIT_RICOCHET
		return ret
	end
	
	
	
// TODO: net library
function this.NotifyClients( Index, Bullet, Type, Hit, HitPos )

	if Type == this.CL_UPDATE then
		netfx.AlterProj(Index, hittable[Hit]())
	elseif Type == this.CL_REMOVE then
		netfx.EndProj(Index)
	else
		netfx.SendProj(Index, Bullet)
	end

end




/* TODO: figure out the significance of having these defined in the ballistics file

function ACF_BulletWorldImpact( Bullet, Index, HitPos, HitNormal )
	--You overwrite this with your own function, defined in the ammo definition file
end

function ACF_BulletPropImpact( Bullet, Index, Target, HitNormal, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
end

function ACF_BulletEndFlight( Bullet, Index, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
end

//*/
