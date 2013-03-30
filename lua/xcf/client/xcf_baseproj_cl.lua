if !XCF then error("XCF table not initialized yet!\n") end

XCF.ProjClasses = XCF.ProjClasses or {}
XCF.ProjClasses.Base = XCF.ProjClasses.Base or {}
local this = XCF.ProjClasses.Base

local baseerror = "Tried to access a base-projectile method.  This means that a projectile was not created or written properly."



function this.GetUpdate(bullet)
	error(baseerror)
end



function this.CreateEffect(Bullet)
	error(baseerror)
end