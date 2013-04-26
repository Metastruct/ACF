if !XCF then error("XCF table not initialized yet!\n") end

XCF.ProjClasses = XCF.ProjClasses or {}
XCF.ProjClasses.Base = XCF.ProjClasses.Base or {}
local this = XCF.ProjClasses.Base

local baseerror = "Tried to access a base-projectile method.  This means that a projectile was not created or written properly."



// This function is called whenever an update is required on the projectile's state.
function this.GetUpdate(bullet)
	error(baseerror)
end



// This function is called just before the projectile is launched, to prepare the projectile to be launched.
function this.Prepare(BulletData)
	error(baseerror)
end



// This function is called by the ballistics core every frame to simulate the projectile's flight.
function this.DoFlight(Index, Bullet)
	error(baseerror)
end



// Callbacks can be added to the class.  These functions have a name identical to a result type from DoFlight.
// Callbacks have a signature (index, projectile, traceresult) and return two values; update and update-type.
// The update-type tells the ballistics core what to do with the update.
// EXAMPLE (figures out if the shell exploded against something or in mid-air, and tells ballistics-core to tell the client + remove projectile):
/*
function this.EndFlight(index, projectile, traceresult)
	local ret = this.GetUpdate(projectile)
	if traceresult.Hit == false then
		ret.AirExplode = true
	else
		ret.SurfaceExplode = true
	end
	
	return ret, XCF.Ballistics.CL_REMOVE
end
//*/