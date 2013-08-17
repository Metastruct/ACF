local PANEL = {}

function PANEL:Init( )

	self.Selectors = {}
	self.Categories = {}
	
	self.ClassPanel = nil
	
end


/**
	When header is clicked, minimize all other categories.
 */
function PANEL:onHeaderClick(category)
	for k, v in pairs(self.Categories) do
		if v == category then continue end
		if v:GetExpanded() then v:Toggle() end
	end
end



/**
	When an entry selector is clicked, select it and deselect all others.
 */
function PANEL:selectorClick(selector)
	self.tempselected = nil

	local sels, sel = self.Selectors, nil
	for i=1, #sels do
		sel = sels[i]
		if sel.Selected then
			sel:SetFont("DermaDefault")
			sel.Selected = false
		end
	end

	selector.Selected = true
	selector:SetFont("DermaDefaultBold")
	selector:SizeToContents()
	//*
	RunConsoleCommand("xcfmenu_type", selector.Entry.ent)
	RunConsoleCommand("xcfmenu_id", selector.Entry.id)
	RunConsoleCommand("xcfmenu_mdl", selector.Entry.model)
	//*/
end


/**
	Return the selected entry
 */
function PANEL:GetSelectedEntry()
	if self.tempselected then return self.tempselected end

	local sels, sel = self.Selectors, nil
	for i=1, #sels do
		sel = sels[i]
		if sel.Selected then return sel.Entry end
	end
	return nil
end



/**
	Return the selected entry
 */
//TODO: do properly
function PANEL:SetSelectedEntry(temp)
	self.tempselected = temp
end



function PANEL:CreateEntrySelector(entry)
	selector = vgui.Create("DLabel")
	selector.DoClick = function(this) self:selectorClick(this) end
	selector.Entry = entry
	selector:SetText(entry.name)
	selector:SetColor(Color(40,40,40))
	selector:SizeToContents()
	
	self.Selectors[#self.Selectors+1] = selector
	return selector
end

/*
local function sortByName(a, b)
	local startnuma, startnumb 
	startnuma = string.match(a.name, "^(%d+)[^%d]")
	if startnuma then
		startnumb = string.match(b.name, "^(%d+)[^%d]")
		return tonumber(startnuma) < tonumber(startnumb)
	end
	
	return a.name < b.name
end
//*/
local function sortByName(a, b)
	local startnuma, startnumb 
	
	startnuma = string.match(a.name, "(%d+)")
	if not startnuma then return a.name < b.name end
	
	startnumb = string.match(b.name, "(%d+)")
	if not startnumb then return a.name < b.name end
	
	return tonumber(startnuma) < tonumber(startnumb)
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
				id   = <class id>
				model= <model path for the entry>
			}
		}
	}	
 */
function PANEL:SetDataTable(data)
	//PrintTable(data)

	self.Categories = {}
	self.Selectors = {}
	self.ClassPanel = vgui.Create( "DCategoryList", self )

	-- order classes by name
	local ordered = {}
	for k, v in pairs(data) do
		ordered[#ordered+1] = v
	end
	table.sort(ordered, function(a, b) return a.Class.name < b.Class.name end)
	
	local category
	for k, v in pairs(ordered) do
		category = self.ClassPanel:Add(v.Class.name)
		
		-- let's attach extra onHeaderClick functionality to the header!
		local oldclick = category.Header.DoClick
		category.Header.DoClick = function(this) self:onHeaderClick(this:GetParent()) oldclick(this) end
		
		entrylist = vgui.Create("DPanelList", category)
		entrylist:SetAutoSize( true )
		entrylist:SetPadding( 5 )
		entrylist:SetSpacing( 5 )
		entrylist:EnableVerticalScrollbar( false )
		
		-- order entries by name.  this is bad but whatever.
		table.sort(v, sortByName)
		
		local entry
		for i=1, #v do
			entry = v[i]
			entrylist:AddItem(self:CreateEntrySelector(entry))
		end
		
		entrylist:SizeToContents()
		category:SetContents(entrylist)
		category:SetExpanded(false)
		self.Categories[#self.Categories+1] = category
		
		self.ClassPanel:AddItem(category)
		
	end
	
	self:InvalidateLayout()
end



local maxCPTall = surface.ScreenHeight()/2 - 20
//*
function PANEL:PerformLayout()
	if not self.ClassPanel then return end

	self.ClassPanel:SizeToContents()
	/*
	if self.ClassPanel:GetTall() > maxCPTall then
		self.ClassPanel:SetTall(maxCPTall)
	end
	//*/
	self.ClassPanel:SetWide(self:GetWide())
	//self.ClassPanel:SetTall(self:GetTall()/2)
	self:SetSize(self.ClassPanel:GetSize())
end
//*/


function PANEL:OnCursorExited()
	for k, v in pairs(self.Categories) do
		if v:GetExpanded() then v:Toggle() end
	end
end

--[[ Unrequired due to new design
function PANEL:Think()
	local x, y = self:CursorPos()
	local w, h = self:GetSize()
	local curout = x >= 0 and x <= w and y >= 0 and y <= h
	
	if self.curout == curout then return end
	if not curout then
		self:OnCursorExited()
	end
	
	self.curout = curout
end
]]


derma.DefineControl( "XCF_ToolMenuSelectList", "Menu tab for an XCF entity class", PANEL, "DPanel" )
