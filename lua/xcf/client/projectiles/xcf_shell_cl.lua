


// This is the classname of this type on the clientside.  Make sure the name matches in the server and shared files, and is unique.
local classname = "Shell"



if !XCF then error("XCF table not initialized yet!\n") end
XCF.ProjClasses = XCF.ProjClasses or {}
local projcs = XCF.ProjClasses

projcs[classname] = projcs[classname] and projcs[classname].super and projcs[classname] or XCF.inheritsFrom(projcs.Base)
local this = projcs[classname]

local balls = XCF.Ballistics or error("XCF: Ballistics hasn't been loaded yet!")




function this.CreateEffect(Bullet)
	local effectdata = EffectData()
	local effect = util.ClientsideEffect( "XCF_ShellEffect", effectdata )
	
	//effect:Config(Bullet)
	effect:HelloTest()
	
	return effect
end