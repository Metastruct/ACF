local labelTemplates = {}
labelTemplates.Base = {
	LabelCapacity	= "Fuel Capacity: %.1f litres, %.1f gallons",
	LabelMasses		= "Tank Mass: %.1f kg full, %.1f kg empty",
	LabelVolume		= "Tank Volume: %.2f cubic metres",
	LabelLinks		= "This fuel tank %s be linked to engines.",
	LabelExplosive	= "This fuel tank %s explode when damaged."
}

//*

function makeBlankLabel(self, labname, labels, entrylist, spacer)
	self[labname] = vgui.Create( "DLabel" )
	local label = self[labname]
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	labels[labname] = label
	entrylist:AddItem(label)
	
	if spacer then entrylist:AddItem(spacer) end
end


local createSlidersForFuel = {}


createSlidersForFuel["base"] = function(self, entrylist, spacer)
	self.SliderWatchList = {}
	self.Labels = {}
	local watch = self.SliderWatchList
	local labels = self.Labels
	
	self.LabelCapacity = nil
	self.LabelMasses = nil
	self.LabelVolume = nil
	self.LabelLinks = nil
	self.LabelExplosive = nil
	
	local labname = "LabelCapacity"
	makeBlankLabel(self, labname, labels, entrylist)
	
	labname = "LabelMasses"
	makeBlankLabel(self, labname, labels, entrylist)
	
	labname = "LabelVolume"
	makeBlankLabel(self, labname, labels, entrylist)
	
	labname = "LabelLinks"
	makeBlankLabel(self, labname, labels, entrylist)
	
	labname = "LabelExplosive"
	makeBlankLabel(self, labname, labels, entrylist)
	
end


createSlidersForFuel["after"] = function(self, entrylist, spacer)
	self:InvalidateLayout()
end




labelTemplates.Petrol = labelTemplates.Base

createSlidersForFuel["Petrol"] = function(self, entrylist, spacer)
	createSlidersForFuel["base"](self, entrylist, spacer)

	for k, v in pairs(labelTemplates.Petrol) do
		self.Labels[k]:SetText(v)
	end
	
	createSlidersForFuel["after"](self, entrylist, spacer)
end



labelTemplates.Diesel = labelTemplates.Base

createSlidersForFuel["Diesel"] = function(self, entrylist, spacer)
	createSlidersForFuel["base"](self, entrylist, spacer)

	for k, v in pairs(labelTemplates.Diesel) do
		self.Labels[k]:SetText(v)
	end
	
	createSlidersForFuel["after"](self, entrylist, spacer)
end



labelTemplates.Electric = {
	LabelCapacity	= "Charge Capacity: %.1f kWh, %.1f MJ",
	LabelMasses		= "Tank Mass: %.1f kg full, %.1f kg empty",
	LabelVolume		= "Tank Volume: %.2f cubic metres",
	LabelLinks		= "This fuel tank %s be linked to engines.",
	LabelExplosive	= "This fuel tank %s explode when damaged."
}

createSlidersForFuel["Electric"] = function(self, entrylist, spacer)
	createSlidersForFuel["base"](self, entrylist, spacer)

	local label
	for k, v in pairs(labelTemplates.Electric) do
		label = self.Labels[k] or error("Couldn't find a label for the " .. k .. " description!")
		label:SetText(v)
		label:SizeToContents()
	end
	
	createSlidersForFuel["after"](self, entrylist, spacer)
end

//*/

//*
-- table of functions for gui modification.
local modifyControlsWith = {}

-- SLIDER MODIFICATION;

modifyControlsWith["TankName"] = function(self, val, fueldata) end
modifyControlsWith["TankDesc"] = function(self, val, fueldata) end


modifyControlsWith["Cap"] = function(self, val, fueldata)
	local val1, val2
	if self.FuelType == "Electric" then 
		val1 = val * ACF.LiIonED
		val2 = val1 * 3.6	
	else
		val1 = val
		val2 = val1 * 0.264172
	end
	
	local labelname = "LabelCapacity"
	
	local label = self.Labels[labelname]
	local labeltemp = labelTemplates[self.FuelType][labelname] or labelTemplates.Base[labelname] or error("Label template for " .. labelname .. " does not exist!")
	label:SetText(string.format(labeltemp, val1, val2))
	label:SizeToContents()
end


modifyControlsWith["Volume"] = function(self, val, fueldata)
	local labelname = "LabelVolume"
	
	local label = self.Labels[labelname]
	local labeltemp = labelTemplates[self.FuelType][labelname] or labelTemplates.Base[labelname] or error("Label template for " .. labelname .. " does not exist!")
	label:SetText(string.format(labeltemp, val * 0.000016387064))
	label:SizeToContents()
end


modifyControlsWith["nolinks"] = function(self, val, fueldata)
	local labelname = "LabelLinks"
	
	local label = self.Labels[labelname]
	local labeltemp = labelTemplates[self.FuelType][labelname] or labelTemplates.Base[labelname] or error("Label template for " .. labelname .. " does not exist!")
	label:SetText(string.format(labeltemp, val and "cannot" or "can"))
	label:SizeToContents()
end


modifyControlsWith["explosive"] = function(self, val, fueldata)
	local labelname = "LabelExplosive"
	
	local label = self.Labels[labelname]
	local labeltemp = labelTemplates[self.FuelType][labelname] or labelTemplates.Base[labelname] or error("Label template for " .. labelname .. " does not exist!")
	label:SetText(string.format(labeltemp, val and "can" or "cannot"))
	label:SizeToContents()
end


modifyControlsWith[#modifyControlsWith + 1] = function(self, val, fueldata)	-- masses	
	local labelname = "LabelMasses"
	
	local label = self.Labels[labelname]
	local labeltemp = labelTemplates[self.FuelType][labelname] or labelTemplates.Base[labelname]
	if not labeltemp then return end
	
	label:SetText(string.format(labeltemp, fueldata.Mass or 0, fueldata.EmptyMass or 0))
	label:SizeToContents()
end
//*/


local PANEL = {}


local function constructFuelTypeList(self, fuellist, typelist)
	fuellist:Clear()
	self.FuelChoices = {}
	self.FuelTypeChoices = {}
	local fuels, types = self.FuelChoices, self.FuelTypeChoices

	for k, v in pairsByName(XCF.FueltanksByClass) do
		fuellist:AddChoice(v.name, k)
		fuels[k] = true
	end
	
	for k, v in pairsByName(ACF.FuelDensity) do
		typelist:AddChoice(k, k)
		types[k] = true
	end
	
end


function PANEL:Init( )

	self.Crate = ACF.Weapons.FuelTanks["Tank_1x1x1"]	
	self.Fuel = "Basic_FuelTank"
	self.FuelType = "Petrol"

	self.Categories = {}
	self.Meters = {}
	self.SliderWatchList = {}
	self.Labels = {}
	
	
	self.FuelList = vgui.Create("DComboBox", self)
	self.FuelTypeList = vgui.Create("DComboBox", self)
	
	self.FuelLabel = vgui.Create( "DLabel", self )
	local label = self.FuelLabel
	label:SetText("Fuel Grade:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	self.FuelTypeLabel = vgui.Create( "DLabel", self )
	label = self.FuelTypeLabel
	label:SetText("Fuel Type:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	
	constructFuelTypeList(self, self.FuelList, self.FuelTypeList)
	
	self.FuelTypeList.OnSelect = function(list, idx, name, type)
		self.FuelType = type
		self:SetFuel()
	end
	
	self.FuelList.OnSelect = function(list, idx, name, fuel)
		self.Fuel = fuel
		self:SetFuel()
	end
	
	
	self.ClassPanel = nil
	self.FuelPreview = vgui.Create( "DModelPanel", self )
	self.FuelPreview.LayoutEntity = function() end -- no rotation please ty
	
	self.FuelPreview2 = vgui.Create( "DModelPanel", self )
	self.FuelPreview2.LayoutEntity = function() end -- no rotation please ty
	
	self:SetFuel()
	
end




/**
	This function populates the tab with the appropriate info.
	This function modifies the input (re-orders the class members)
	Make sure the table is in the following format to parse successfully into the tab;
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
			}
		}
	}	
 */
function PANEL:SetFuel(fueltype, crate, fuelsubtype)
	self.Fuel = fueltype or self.Fuel
	self.Crate = crate or self.Crate
	self.FuelType = fuelsubtype or self.FuelType
	
	if not (self.Crate and self.Fuel) then return end
	local _
	
	-- pick a valid fuel if we're trying to use an invalid one.
	if not (self.Fuel and XCF.FueltanksByClass[self.Fuel]) then
		self.Fuel = next(XCF.FueltanksByClass) or "Basic_FuelTank"
	end
	
	-- pick a valid crate if we're trying to use an invalid one.
	if not (self.Crate.id and ACF.Weapons.FuelTanks[self.Crate.id]) then
		_, self.Crate = next(ACF.Weapons.FuelTanks) or ACF.Weapons.FuelTanks["Fuel_Drum"]
	end
	
	-- pick a valid fueltype if we're trying to use an invalid one.
	if not (self.FuelType and ACF.FuelDensity[self.FuelType]) then
		self.FuelType = next(ACF.FuelDensity) or "Petrol"
	end
	
	
	-- set Fuel model preview and centre the camera on the Fuel.
	self.FuelPreview:SetModel(self.Crate.model)
	self.FuelPreview:SetFOV(45)
	self.FuelPreview2:SetModel(self.Crate.model)
	self.FuelPreview2:SetFOV(45)
	
	local viewent = self.FuelPreview:GetEntity()
	local boundmin, boundmax = viewent:GetRenderBounds()
	local dist = boundmin:Distance(boundmax)*1.5
	local centre = boundmin + (boundmax - boundmin)/2
	dist = dist < 70 and 70 or dist
	
	self.FuelPreview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.FuelPreview:SetLookAt( centre )
	
	self.FuelPreview2:SetCamPos( centre + Vector( 0, 0.1, dist ) )
	self.FuelPreview2:SetLookAt( centre )
	
	
	-- replace fuel info panel with info about this fuel.
	if self.ClassPanel and IsValid(self.ClassPanel) then 
		self.ClassPanel:Remove()
		self.ClassPanel = nil
	end
	
	local fueltbl = XCF.FueltanksByClass[self.Fuel] or error("No fuel table for the fuel class " .. tostring(self.Fuel))
	
	self.ClassPanel = vgui.Create( "DCollapsibleCategory", self )
	self.ClassPanel:SetLabel(fueltbl.name .. "; " .. self.Crate.name)
	self.ClassPanel.Header.DoClick = function() end
		
	local entrylist = vgui.Create("DPanelList", category)
	entrylist:SetAutoSize( true )
	entrylist:SetPadding( 5 )
	entrylist:EnableVerticalScrollbar( false )
	
	-- label spam below; fuel description text
	
	-- description header
	local label = vgui.Create( "DLabel" )
	label:SetText("Description:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	local spacer = vgui.Create( "DPanel" )
	spacer:SetSize(5, 5)
	spacer.Paint = function() end
	
	--description body
	label = vgui.Create( "DLabel" )
	label:SetColor(Color(40, 40, 40))
	label:SetWrap(true)
	label:SetAutoStretchVertical( true )
	label:SetText(tostring(fueltbl.desc or "Fuel Description unavailable!") .. "\n" .. tostring(self.Crate.desc or "Fueltank Description unavailable!") .. "\n")
	label:SetSize(self:GetWide(), 10)
	label:SizeToContentsY()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	
	createSlidersForFuel[self.FuelType](self, entrylist, spacer)
	
	
	entrylist:SizeToContents()
	
	self.ClassPanel:SetContents(entrylist)
	self.ClassPanel:SetExpanded(true)
	
	-- this overrides the selection behaviour of the gun select list
	RunConsoleCommand("xcfmenu_id", self.Fuel)
	RunConsoleCommand("xcfmenu_mdl", self.Crate.model)
	RunConsoleCommand("xcfmenu_type", fueltbl.ent)
	
	self:InvalidateLayout()
	
end


function PANEL:GetFuelData()
	if not (self.Crate and self.Fuel) then return nil end
	local ret = {}
	
	local Dims = self.Crate.dims or error("No dims found for the current crate!" .. tostring(self.Crate and self.Crate.id or ""))
	local Wall = 0.1 --wall thickness in inches
	local Size = math.floor(Dims[1] * Dims[2] * Dims[3])
	local Volume = (Dims[1] - Wall) * (Dims[2] - Wall) * (Dims[3] - Wall)
	local Capacity = Volume * ACF.CuIToLiter * ACF.TankVolumeMul * 0.125
	local EmptyMass = ((Size - Volume)*16.387)*7.9/1000
	local Mass = EmptyMass + Capacity * ACF.FuelDensity[self.FuelType]

	local fueltbl = ACF.Weapons.FuelTanks[self.Crate.id] or error("No crate table for the fuelcrate class " .. tostring(self.Crate.id))
	
	ret["TankName"] = fueltbl.name
	ret["TankDesc"] = fueltbl.desc
	ret["Cap"] = Capacity
	ret["Mass"] = Mass
	ret["EmptyMass"] = EmptyMass
	ret["Volume"] = Volume
	ret["nolinks"] = fueltbl["nolinks"] or false
	ret["explosive"] = fueltbl["explosive"] == nil or fueltbl["explosive"]
	
	return ret
	
end


local maxCPTall = surface.ScreenHeight()/2 - 20


function PANEL:PerformLayout()
	
	local wided2 = self:GetWide()/2
	local prevsize = 80
	self.FuelPreview:SetTall(prevsize)
	self.FuelPreview:SetWide(prevsize)
	
	self.FuelPreview2:SetTall(prevsize)
	self.FuelPreview2:SetWide(prevsize)
	
	self.FuelPreview:SetPos((wided2 - prevsize) / 2, 0)
	self.FuelPreview2:SetPos(wided2 + (wided2 - prevsize) / 2, 0)
	
	local ypos = 80
	
	self.FuelLabel:SetPos(0, ypos)
	ypos = ypos + self.FuelLabel:GetTall()
	
	self.FuelList:SetPos(0, ypos)
	self.FuelList:SetSize(self:GetWide(), 20)
	
	ypos = ypos + self.FuelList:GetTall()
	
	self.FuelTypeLabel:SetPos(0, ypos)
	ypos = ypos + self.FuelTypeLabel:GetTall()
	
	self.FuelTypeList:SetPos(0, ypos)
	self.FuelTypeList:SetSize(self:GetWide(), 20)
	
	ypos = ypos + self.FuelTypeList:GetTall()
	
	if self.ClassPanel and IsValid(self.ClassPanel) then
		self.ClassPanel:SetPos(0, ypos)
		self.ClassPanel:SizeToContents()
		self.ClassPanel:SetWide(self:GetWide())
		
		ypos = ypos + self.ClassPanel:GetTall()
		
		self:SetTall(ypos)
		
		local fueldata = self:GetFuelData()		
		if fueldata then			
			local func
			for k, v in pairs(fueldata) do
				func = modifyControlsWith[k]
				if func then func(self, v, fueldata) end
			end
			
			for i=1, #modifyControlsWith do
				modifyControlsWith[i](self, v, fueldata)
			end
			
			RunConsoleCommand( "xcfmenu_data1",  self.Crate.id )
			RunConsoleCommand( "xcfmenu_data2",  self.FuelType )
		end
		
	else
		self:SetTall(ypos)
	end	
	
	if self:GetTall() > maxCPTall then
		self:SetTall(maxCPTall)
	end
	
end


function PANEL:WatchSliders()
	local last, val
	for k, v in pairs(self.SliderWatchList) do
		if not (v and IsValid(v)) then continue end
		last = v.lastValWatched or 0
		val = v:GetValue()
		
		if last != val then
			self:InvalidateLayout()
		end
		
		v.lastValWatched = val
	end
end



function PANEL:GetInfoTable()
	
	local fueltbl = XCF.FueltanksByClass[self.Fuel] or error("No fuel table for the fuel class " .. tostring(self.Fuel))
	
	local tbl = {
		["ent"] = self.Crate.ent,
		["id"]	= fueltbl.id,
	}
	
	tbl[1] = fueltbl.id
	tbl[2] = self.Crate.id
	tbl[3] = self.FuelType
	
	return tbl
end



function PANEL:Think()
	local selpanel = self:GetParent().SelectPanel
	
	if self:GetParent() and selpanel then
		local entry = selpanel:GetSelectedEntry()
		if entry and entry != self.Crate then
			self:SetFuel(nil, entry)
		end
	end
	
	local ent = GetConVarString("xcfmenu_type")
	
	if ent != self.Crate.ent then
		self:SetFuel()
	end
	
	self:WatchSliders()
end

derma.DefineControl( "XCF_ToolMenuFuelPanel", "Menu panel for an XCF gun", PANEL, "DPanel" )
