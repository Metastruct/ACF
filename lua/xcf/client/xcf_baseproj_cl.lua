if !XCF then error("XCF table not initialized yet!\n") end

XCF.ProjClasses = XCF.ProjClasses or {}
XCF.ProjClasses.Base = XCF.ProjClasses.Base or {}
local this = XCF.ProjClasses.Base

local baseerror = "Tried to access a base-projectile method.  This means that a projectile was not created or written properly."



function this:Update(diffs)
	error(baseerror)
end



function this:CreateEffect()
	error(baseerror)
end



function this:Launch()
	error(baseerror)
end



function this:DoFlight()
	error(baseerror)
end



function this:EndFlight()
	error(baseerror)
end