local createSlidersForGear = {}


createSlidersForGear["before"] = function(self, entrylist, spacer)
	
	entrylist:AddItem(spacer)
	self.Gears = {}
	
end


createSlidersForGear["after"] = function(self, entrylist, spacer)

	entrylist:AddItem(spacer)

	
	local label = vgui.Create( "DLabel" )
	label:SetText("Final Drive:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	entrylist:AddItem(label)
	
	-- final drive body
	self.DriveMeter = self.DriveMeter or vgui.Create( "XCF_ToolMenuMeterSlider" )
	label = self.DriveMeter
	label:SetExtents(-1, 1)
	label:SetTall(15)
	label:SetConVar("xcfmenu_data10")
	entrylist:AddItem(label)

end


createSlidersForGear["Common"] = function(self, entrylist, spacer)

	createSlidersForGear["before"](self, entrylist, spacer)

	local label = vgui.Create( "DLabel" )
	label:SetText("Gears 1 to " .. (self.Gear.gears or 0) .. ":")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	entrylist:AddItem(label)
	
	self.Gears = {}
	local j
	for i=1, (self.Gear.gears or 0) do		
		//if not self.Gears[i] or self.Gears[i] == NULL then
			self.Gears[i] = vgui.Create( "XCF_ToolMenuMeterSlider" )
			self.Gears[i]:SetConVar("xcfmenu_data" .. i)	-- TODO: optimize convar alterations
			RunConsoleCommand("xcfmenu_data" .. i, i == self.Gear.gears and -0.1 or i / 10)
		//end
		
		label = self.Gears[i]
		label:SetExtents(-1, 1)
		label:SetTall(15)
		
		entrylist:AddItem(label)
		j = i
	end
	
	entrylist:AddItem(spacer)
	
	
	-- final drive label
	label = vgui.Create( "DLabel" )
	label:SetText("Final Drive:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	entrylist:AddItem(label)
	
	createSlidersForGear["after"](self, entrylist, spacer)
end


createSlidersForGear["CVT"] = function(self, entrylist, spacer)

	createSlidersForGear["before"](self, entrylist, spacer)

	local label = vgui.Create( "DLabel" )
	label:SetText("Gear 2:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	entrylist:AddItem(label)
	
	label = vgui.Create( "XCF_ToolMenuMeterSlider" )
	self.Gears[2] = label
	label:SetConVar("xcfmenu_data2")
	RunConsoleCommand("xcfmenu_data2", -1)
	label:SetExtents(-1, 1)
	label:SetTall(15)
	entrylist:AddItem(label)
	
	entrylist:AddItem(spacer)
	
	label = vgui.Create( "DLabel" )
	label:SetText("Minimum and Maximum RPM:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	entrylist:AddItem(label)
	
	label = vgui.Create( "XCF_ToolMenuMeterSlider" )
	self.Gears[3] = label
	label:SetConVar("xcfmenu_data3")
	RunConsoleCommand("xcfmenu_data3", 0)
	label:SetExtents(0, XCF.Maximum and XCF.Maximum.EngineRedline or 13500)
	label:SetTall(15)	
	entrylist:AddItem(label)
	
	label = vgui.Create( "XCF_ToolMenuMeterSlider" )
	self.Gears[4] = label
	label:SetConVar("xcfmenu_data4")
	RunConsoleCommand("xcfmenu_data4", 5000)
	label:SetExtents(0, XCF.Maximum and XCF.Maximum.EngineRedline or 13500)
	label:SetTall(15)	
	entrylist:AddItem(label)
	
	createSlidersForGear["after"](self, entrylist, spacer)

end



local PANEL = {}

function PANEL:Init( )

	self.Categories = {}
	self.Meters = {}
	self.Gear = ACF.Weapons.Mobility["8Gear-L-L"]
	self.Gears = {}
	
	self.ClassPanel = nil
	self.GearPreview = vgui.Create( "DModelPanel", self )
	self.GearPreview.LayoutEntity = function() end -- no rotation please ty
	
	self.GearPreview2 = vgui.Create( "DModelPanel", self )
	self.GearPreview2.LayoutEntity = function() end -- no rotation please ty
	
end



local function sortByName(a, b)
	local startnuma, startnumb 
	startnuma = string.match(a.name, "^(%d+)[^%d]")
	if startnuma then
		startnumb = string.match(b.name, "^(%d+)[^%d]")
		return tonumber(startnuma) < tonumber(startnumb)
	end
	
	return a.name < b.name
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
function PANEL:SetGear(geartable)
	self.Gear = geartable
	
	-- set gun model preview and centre the camera on the gun.
	self.GearPreview:SetModel(geartable.model)
	self.GearPreview:SetFOV(45)
	self.GearPreview2:SetModel(geartable.model)
	self.GearPreview2:SetFOV(45)
	
	local viewent = self.GearPreview:GetEntity()
	local boundmin, boundmax = viewent:GetRenderBounds()
	local dist = boundmin:Distance(boundmax)*1.1
	local centre = boundmin + (boundmax - boundmin)/2
	
	self.GearPreview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.GearPreview:SetLookAt( centre )
	
	self.GearPreview2:SetCamPos( centre + Vector( dist, 0, 0 ) )
	self.GearPreview2:SetLookAt( centre )
	
	
	-- replace gun info panel with info about this gun.
	if self.ClassPanel then 
		self.ClassPanel:Remove()
		self.ClassPanel = nil
	end
	
	self.ClassPanel = vgui.Create( "DCollapsibleCategory", self )
	self.ClassPanel:SetLabel(geartable.name)
	self.ClassPanel.Header.DoClick = function() end
		
	local entrylist = vgui.Create("DPanelList", category)
	entrylist:SetAutoSize( true )
	entrylist:SetPadding( 5 )
	entrylist:EnableVerticalScrollbar( false )
	
	-- label spam below; gun description text
	
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
	label:SetText(tostring(geartable.desc or "Description unavailable!") .. "\n")
	label:SetSize(self:GetWide(), 10)
	label:SizeToContentsY()
	
	entrylist:AddItem(label)
	//*
	-- torque label
	local label = vgui.Create( "DLabel" )
	label:SetText("Clutch Torque Limit (N/m):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--torque body
	self.TorqueMeter = self.TorqueMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.TorqueMeter
	label:SetMax(XCF.Maximum and XCF.Maximum.GearTorque or 10000)
	label:AnimateToValues(0, geartable.maxtq or 0)
	label:SetTall(15)
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	-- mass label
	local label = vgui.Create( "DLabel" )
	label:SetText("Mass (kg):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--mass body
	self.MassMeter = self.MassMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.MassMeter
	label:SetMax(XCF.Maximum and XCF.Maximum.GearMass or 320)
	label:InvertGradient(true)
	label:AnimateToValues(0, tonumber(geartable.weight) or 0)
	label:SetTall(15)
	//*/
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	local gearheadpanel = vgui.Create( "DPanel" )
	local label = vgui.Create( "DLabel", gearheadpanel)
	label:SetText(geartable.category or "Gearbox")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	
	local function doSave(success, filepath)
		self.fileDialogue = nil
		if success and filepath then
			savefile = {}
			
			for i=1, 10 do
				savefile[i] = GetConVarNumber("xcfmenu_data"..i) or 0
			end
				
			savefile.id		= self.Gear.id
			savefile.mdl	= self.Gear.model
			savefile.type	= self.Gear.ent
				
			file.CreateDir(string.match(filepath, "^(.*/)[^/]*$"))
			file.Write(filepath, util.TableToJSON(savefile))
		end
	end
	
	
	local function createSaveMenu()
		if self.fileDialogue then
			if self.fileDialogue != NULL then 
				self.fileDialogue:Close()
			end
			self.fileDialogue = nil
		end
		
		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
		self.fileDialogue:SetRootFolder("xcfmenu/gear", true)
		self.fileDialogue:SetTitle("XCFMenu; Save Gearbox Profile")
		self.fileDialogue:SetDeleteOnClose(true)
		self.fileDialogue:Center()
		self.fileDialogue:MakePopup()
		self.fileDialogue:SetCallback(doSave)
	end
	
	
	local function doLoad(success, filepath)
		self.fileDialogue = nil
		
		if success and filepath then		
			local content = file.Read(filepath, "DATA")
			local conttable = util.JSONToTable(content)
			
			PrintTable(conttable)
			
			RunConsoleCommand("xcfmenu_id", conttable.id)
			RunConsoleCommand("xcfmenu_mdl", conttable.mdl)
			RunConsoleCommand("xcfmenu_type", conttable.type)
			
			local gear = ACF.Weapons.Mobility[conttable.id]
			self:GetParent().SelectPanel:SetSelectedEntry(gear)
			self:SetGear(gear)
			
			for i=1, #conttable do
				RunConsoleCommand("xcfmenu_data" .. i, conttable[i] or 0)
			end			
			
			for k, v in pairs(self.Gears) do
				v:SetValue(conttable[k])
				print(k, conttable[k], v:GetValue())
			end
			
			self.DriveMeter:SetValue(conttable[10])
				
			self:InvalidateLayout()
			
		end
	end
	
	
	local function createLoadMenu()
		if self.fileDialogue then
			if self.fileDialogue != NULL then 
				self.fileDialogue:Close()
			end
			self.fileDialogue = nil
		end
		
		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
		self.fileDialogue:SetRootFolder("xcfmenu/gear", true)
		self.fileDialogue:SetLoading(true)
		self.fileDialogue:SetTitle("XCFMenu; Load Gearbox Profile")
		self.fileDialogue:SetDeleteOnClose(true)
		self.fileDialogue:Center()
		self.fileDialogue:MakePopup()
		self.fileDialogue:SetCallback(doLoad)
	end
	
	
	local save = vgui.Create("DButton", gearheadpanel)
	save:SetText("Save...")
	save:SizeToContentsX()
	save:SetWide(save:GetWide() + 4)
	save:SetTall(label:GetTall() + 2)
	save:SetPos(label:GetWide() + 5, 0)
	save.DoClick = createSaveMenu
	
	
	local load = vgui.Create("DButton", gearheadpanel)
	load:SetText("Load...")
	load:SizeToContentsX()
	load:SetWide(save:GetWide() + 4)
	load:SetTall(label:GetTall() + 2)
	load:SetPos(label:GetWide() + save:GetWide() + 10, 0)
	load.DoClick = createLoadMenu
	
	gearheadpanel:SizeToContentsX()
	gearheadpanel:SetTall(load:GetTall())
	entrylist:AddItem(gearheadpanel)
	
	
	local geartype = geartable.cvt and "CVT" or "Common"
	createSlidersForGear[geartype](self, entrylist, spacer)
	
	
	
	entrylist:SizeToContents()
	
	self.ClassPanel:SetContents(entrylist)
	self.ClassPanel:SetExpanded(true)
	
	self:InvalidateLayout()
	
end



local maxCPTall = surface.ScreenHeight()/2 - 20

function PANEL:PerformLayout()
	local wided2 = self:GetWide()/2
	local prevsize = 80
	self.GearPreview:SetTall(prevsize)
	self.GearPreview:SetWide(prevsize)
	
	self.GearPreview2:SetTall(prevsize)
	self.GearPreview2:SetWide(prevsize)
	
	self.GearPreview:SetPos((wided2 - prevsize) / 2, 0)
	self.GearPreview2:SetPos(wided2 + (wided2 - prevsize) / 2, 0)
	
	if self.ClassPanel then
		self.ClassPanel:SetPos(0, prevsize + 10)
		self.ClassPanel:SizeToContents()
		self.ClassPanel:SetWide(self:GetWide())
		self:SetTall(prevsize + 10 + self.ClassPanel:GetTall())
	else
		self:SetTall(prevsize)
	end	
	
	if self:GetTall() > maxCPTall then
		self:SetTall(maxCPTall)
	end
end



function PANEL:GetInfoTable()
	
	local tbl = {
		["ent"] = self.Gear.ent,
		["id"]	= self.Gear.id
	}
	
	// because duplicator shit
	tbl[1] = self.Gear.id
	
	for k, v in pairs(self.Gears) do
		tbl[k+1] = v:GetValue()
	end
	
	for i=2, 10 do
		if not tbl[i] then tbl[i] = 0 end
	end
	
	tbl[11] = (self.DriveMeter and self.DriveMeter:GetValue() or 0)
	
	return tbl
end



function PANEL:Think()
	local selpanel = self:GetParent().SelectPanel
	if self:GetParent() and selpanel then
		local entry = selpanel:GetSelectedEntry()
		if entry and entry != self.Gear then
			self:SetGear(entry)
		end
		
		local ent = GetConVarString("xcfmenu_type")
	
		if ent != self.Gear.ent then
			self:SetGear(self.Gear)
		end
		
	end
end

derma.DefineControl( "XCF_ToolMenuGearPanel", "Menu panel for an XCF gun", PANEL, "DPanel" )
