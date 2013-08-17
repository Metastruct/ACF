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
		class = v.id
		XCF.FueltanksByClass[class] = v
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




local sizeClassName = "%ix Size"
local otherSizes = "Other Sizes"

local function throwInOther(v, ret)
	if not ret[otherSizes] then ret[otherSizes] = {Class = {name = otherSizes}} end
	ret[otherSizes][#ret[otherSizes] + 1] = v
end

local function addToSizeList(ret, v, x)
	if v.id == "Class" then return end	-- jjjjust in case
	local classname = string.format(sizeClassName, x)
	
	if not ret[classname] then ret[classname] = {Class = {name = classname}} end
	ret[classname][tostring(v.id)] = v
end

local function finalizeSizeList(ret)
	for _, tbl in pairs(ret) do
		for k, v in pairsByName(tbl) do
			if type(k) == "number" then continue end
			if k == "Class" then continue end
			tbl[#tbl + 1] = v
			tbl[k] = nil
		end
	end
end




-- Create a list of boxes by size.  Inclusion requires name to contain NxNxN standard, otherwise is thrown in the "other" pile.
local function toBoxSizeList(boxes)
	
	local ret = {}
	
	local isOther, x, y, z
	for k, v in pairs(boxes) do
		--print(k, v)
		isOther = false
		x, y, z = nil, nil, nil
		
		if not type(k) == "string" then
			throwInOther(v, ret)
			continue
		end
		
		x, y, z = string.match(k, "(%d)[xX](%d)[xX](%d)")
		--print("Sizes:", x, y, z)
		if not (x and y and z) then 
			throwInOther(v, ret)
			continue
		end
		
		addToSizeList(ret, v, x)
		addToSizeList(ret, v, y)
		addToSizeList(ret, v, z)
	end
	
	finalizeSizeList(ret)
	
	return ret
end

XCF.AmmoBySize = toBoxSizeList(ACF.Weapons.Ammo)
XCF.FuelBySize = toBoxSizeList(ACF.Weapons.FuelTanks)




XCF.Maximum = {}

local maxcal = 0
local maxmass = 0
for k, v in pairs(ACF.Weapons.Guns) do

	if v.caliber and v.caliber > maxcal then
		maxcal = v.caliber
	end
	
	if v.weight and v.weight > maxmass then
		maxmass = v.weight
	end
end

maxcal = maxcal * 10
XCF.Maximum.GunCaliber = maxcal
XCF.Maximum.GunMass = maxmass




local function enginePower(eng)
	if eng.iselec then
		if not eng.elecpower then return nil end
		return eng.elecpower*1.34
	end
	
	if not (eng.torque and eng.peakmaxrpm) then return nil end
	return 1.34 * (eng.torque * eng.peakmaxrpm) / 9548.8
end


local maxtorque = 0
local maxpower = 0
local maxpowperkg = 0
local maxredline = 0
maxmass = 0
local maxgeartorque = 0
local maxgearmass = 0
for k, v in pairs(ACF.Weapons.Mobility) do
	if v.ent == "acf_engine" then
	
		if v.torque and v.torque > maxtorque then
			maxtorque = v.torque
		end
		
		local power = enginePower(v)
		if power and power > maxpower then
			maxpower = power
		end
		
		if v.weight then
			if v.weight > maxmass then
				maxmass = v.weight
			end
			local powperkg = power / v.weight
			if powperkg > maxpowperkg then
				maxpowperkg = powperkg
			end
		end
		
		local redline = v.limitprm or v.limitrpm
		if redline and redline > maxredline then
			maxredline = redline
		end
	elseif v.ent == "acf_gearbox" then
		
		if v.maxtq and v.maxtq > maxgeartorque then
			maxgeartorque = v.maxtq
		end
		
		if v.weight and v.weight > maxgearmass then
			maxgearmass = v.weight
		end
	end
end

XCF.Maximum.EngineTorque = maxtorque
XCF.Maximum.EnginePower = maxpower
XCF.Maximum.EnginePowerPerKG = maxpowperkg
XCF.Maximum.EngineRedline = maxredline
XCF.Maximum.EngineMass = maxmass

XCF.Maximum.GearTorque = maxgeartorque
XCF.Maximum.GearMass = maxgearmass