/**
	XCF Permission mode: Build
		This mode blocks all damage to entities without the owner's permission.
		Owners can permit damage from specific players.
		Players and NPCs remain vulnerable to damage.  This is what admin mods are for.
		This mode requires a CPPI-compatible prop-protector to function properly.
//*/


// the name for this mode used in commands and identification
local modename = "build"

// a short description of what the mode does
local modedescription = "Disables all ACF damage unless the owner permits it."


/*
	Defines the behaviour of XCF damage protection under this protection mode.
	This function is called every time an entity can be affected by potential ACF damage.
	Args;
		owner		Player:	The owner of the potentially-damaged entity
		attacker	Player:	The initiator of the ACF damage event
		ent			Entity:	The entity which may be damaged.
	Return: boolean
		true if the entity should be damaged, false if the entity should be protected from the damage.
//*/
local function modepermission(owner, attacker, ent)
	
	if not CPPI then return true end
	if IsValid(ent) and ent:IsPlayer() or ent:IsNPC() then return true end
	
	if not (attacker and IsValid(attacker) and attacker:IsPlayer()) then return false end
	if not (owner and IsValid(owner) and owner:IsPlayer()) then 
		if IsValid(ent) and ent:IsPlayer() then 
			owner = ent
		else 
			return false
		end
	end
	
	if not (owner.SteamID or attacker.SteamID) then
		print("XCF ERROR: owner or attacker is not a player!", tostring(owner), tostring(attacker), "\n", debug.traceback())
		return false
	end	
	
	local ownerid = owner:SteamID()
	local attackerid = attacker:SteamID()
	
	--if ownerid == attackerid then
	--	return XCF.Permissions.Selfkill
	--end
	
	if not XCF.Permissions[ownerid] then
		XCF.Permissions[ownerid] = {}
	end
	
	if XCF.Permissions[ownerid][attackerid] then return true end
	
	return false
end


if not XCF or not XCF.Permissions or not XCF.Permissions.RegisterMode then error("XCF: Tried to load the " .. modename .. " permission-mode before the permission-core has loaded!") end
XCF.Permissions.RegisterMode(modepermission, modename, modedescription)
