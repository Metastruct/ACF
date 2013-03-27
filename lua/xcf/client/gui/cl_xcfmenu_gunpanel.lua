local PANEL = {}

function PANEL:Init( )

	self.Categories = {}
	self.Gun = ACF.Weapons.Guns["12.7mmMG"]
	
	self.ClassPanel = nil
	self.GunPreview = vgui.Create( "DModelPanel", self )
	self.GunPreview.LayoutEntity = function() end -- no rotation please ty
	
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
function PANEL:SetGun(guntable)
	self.Categories = {}
	self.Gun = guntable
	
	-- set gun model preview and centre the camera on the gun.
	self.GunPreview:SetModel(guntable.model)
	self.GunPreview:SetFOV(45)
	local viewent = self.GunPreview:GetEntity()
	local boundmin, boundmax = viewent:GetRenderBounds()
	local dist = boundmin:Distance(boundmax)*1.5
	local centre = boundmin + (boundmax - boundmin)/2
	dist = dist < 70 and 70 or dist
	
	self.GunPreview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.GunPreview:SetLookAt( centre )
	
	
	-- replace gun info panel with info about this gun.
	if self.ClassPanel then 
		self.ClassPanel:Remove()
		self.ClassPanel = nil
	end
	
	self.ClassPanel = vgui.Create( "DCollapsibleCategory", self )
	self.ClassPanel:SetLabel(guntable.name)
	self.ClassPanel.Header.DoClick = function() end
		
	local entrylist = vgui.Create("DPanelList", category)
	entrylist:SetAutoSize( true )
	entrylist:SetPadding( 5 )
	entrylist:EnableVerticalScrollbar( false )
	
	-- label spam below; gun description text
	
	local spacer = vgui.Create( "DPanel" )
	spacer:SetSize(5, 5)
	spacer.Paint = function() end
	
	-- description header
	local label = vgui.Create( "DLabel" )
	label:SetText("Description:")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--description body
	label = vgui.Create( "DLabel" )
	label:SetColor(Color(40, 40, 40))
	label:SetWrap(true)
	label:SetAutoStretchVertical( true )
	label:SetText(tostring(guntable.desc) or "Description unavailable!")
	label:SetSize(self:GetWide(), 10)
	label:SizeToContentsY()
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	-- caliber label
	local label = vgui.Create( "DLabel" )
	label:SetText("Caliber (mm):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--caliber body
	
	self.CaliberMeter = self.CaliberMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.CaliberMeter
	label:SetMax(203)  // todo: programmatically
	label:AnimateToValues(0, (tonumber(guntable.caliber) or 0) * 10)
	label:SetTall(15)
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	/*
	label = vgui.Create( "DLabel" )
	label:SetColor(Color(40, 40, 40))
	label:SetText((tonumber(guntable.caliber) or 0) * 10 .. " mm\n")
	label:SizeToContents()
	
	entrylist:AddItem(label)
	//*/
	
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
	label:SetMax(10280)  // todo: programmatically
	label:InvertGradient(true)
	label:AnimateToValues(0, tonumber(guntable.weight) or 0)
	label:SetTall(15)
	
	entrylist:AddItem(label)
	/*
	label = vgui.Create( "DLabel" )
	label:SetColor(Color(40, 40, 40))
	label:SetText((tonumber(guntable.weight) or 0) .. " kg\n")
	label:SizeToContents()
	
	entrylist:AddItem(label)
	//*/
	entrylist:SizeToContents()
	
	self.ClassPanel:SetContents(entrylist)
	self.ClassPanel:SetExpanded(true)
	
end



local maxCPTall = surface.ScreenHeight()/2 - 20

function PANEL:PerformLayout()
	self.GunPreview:SetTall(80)
	self.GunPreview:SetWide(self:GetWide())
	
	if self.ClassPanel then
		self.ClassPanel:SetPos(0, 90)
		self.ClassPanel:SizeToContents()
		self.ClassPanel:SetWide(self:GetWide())
		self:SetTall(90 + self.ClassPanel:GetTall())
	else
		self:SetTall(80)
	end	
	
	if self:GetTall() > maxCPTall then
		self:SetTall(maxCPTall)
	end
end



function PANEL:GetInfoTable()
	return {
		["ent"] = self.Gun.ent,
		["id"]	= self.Gun.id,
		[1] = self.Gun.id
	}
end



function PANEL:Think()
	if self:GetParent() and self:GetParent().SelectPanel then
		local entry = self:GetParent().SelectPanel:GetSelectedEntry()
		if entry and entry != self.Gun then
			self:SetGun(entry)
		end
		
		local ent = GetConVarString("xcfmenu_type")
	
		if ent != self.Gun.ent then
			self:SetGun(self.Gun)
		end
	end
end

derma.DefineControl( "XCF_ToolMenuGunPanel", "Menu panel for an XCF gun", PANEL, "DPanel" )
