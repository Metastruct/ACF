-- we need a table in this standardized format for easy usage;
/**
	data =
	{
		<1..n or class id> =
		{
			Class = -- entry class table
			{
				name = <verbose class name>
			}
			<1..n>ClassMember = 
			{
				name = <verbose entry name>
				desc = <verbose entry description>
				id   = <class id>
				model= <model path for the entry>
			}
		}
	}	
 */

 
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
 
 
XCF = XCF or {}

-- Sanitize guns.  Organize gun by type and include access to gun class entry.
XCF.GunsByClass = {}
local class, classtable
for k, v in pairs(ACF.Weapons.Guns) do
	class = v.gunclass
	classtable = XCF.GunsByClass[class]
	
	if not classtable then -- create the class table if it doesn't exist
		XCF.GunsByClass[class] = {}
		classtable = XCF.GunsByClass[class]
		classtable.Class = ACF.Classes.GunClass[class] or error("Encountered unknown ACF gun class \"" .. class .. "\"!  Aborting...")
	end
	
	classtable[#classtable+1] = v
end


-- Sanitize engines, gearboxes and fuel.  Held in the same table! (oh why?!)

-- TODO: fill this in
XCF.EngineClassNames = {}
XCF.EngineClassNames["I4"] = "Inline 4"
XCF.EngineClassNames["I6"] = "Inline 6"
XCF.EngineClassNames["B4"] = "Boxer 4"
XCF.EngineClassNames["B6"] = "Boxer 6"

XCF.EnginesByClass = {}
XCF.GearboxesByClass = {}
XCF.FueltanksByClass = {}
for k, v in pairs(ACF.Weapons.Mobility) do
	if( v.ent == "acf_engine" ) then
		class = v.category
		classtable = XCF.EnginesByClass[class]
		
		if not classtable then -- create the class table if it doesn't exist
			XCF.EnginesByClass[class] = {}
			classtable = XCF.EnginesByClass[class]
			classtable.Class = {name = XCF.EngineClassNames[class] or class}
		end
		
		classtable[#classtable+1] = v
	elseif ( v.ent == "acf_gearbox" ) then
		class = v.category
		classtable = XCF.GearboxesByClass[class]
		
		if not classtable then -- create the class table if it doesn't exist
			XCF.GearboxesByClass[class] = {}
			classtable = XCF.GearboxesByClass[class]
			classtable.Class = {name = class}
		end
		
		classtable[#classtable+1] = v
	elseif ( v.ent == "acf_fueltank" ) then
		class = v.category
		classtable = XCF.FueltanksByClass[class]
		
		if not classtable then -- create the class table if it doesn't exist
			XCF.FueltanksByClass[class] = {}
			classtable = XCF.FueltanksByClass[class]
			classtable.Class = {name = class}
		end
		
		classtable[#classtable+1] = v
	end
end


-- Sanitize ammo blacklist.  Convert into lookup table by gun type

XCF.AmmoBlacklist = {}
local blklst = XCF.AmmoBlacklist
for ammo, v in pairs(ACF.AmmoBlacklist) do
	for _, gun in pairs(v) do
		if not blklst[gun] then
			blklst[gun] = {}
		end
		
		blklst[gun][ammo] = true
	end
end
