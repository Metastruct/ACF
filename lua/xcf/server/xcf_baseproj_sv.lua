if !XCF then error("XCF table not initialized yet!\n") end

XCF.ProjClasses = XCF.ProjClasses or {}
XCF.ProjClasses.Base = XCF.ProjClasses.Base or {}
local this = XCF.ProjClasses.Base

local baseerror = "Tried to access a base-projectile method.  This means that a projectile was not created or written properly."



function this.GetUpdate(bullet)
	error(baseerror)
end



function this.Prepare(BulletData)
	error(baseerror)
end



function this.DoFlight(Index, Bullet)
	error(baseerror)
end



function this.Removed(Proj)
	error(baseerror)
end



function this.Penetrate(Proj)
	error(baseerror)
end



function this.Ricochet(Proj)
	error(baseerror)
end



function this.EndFlight(Proj)
	error(baseerror)
end