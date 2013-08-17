local PANEL = {}

function PANEL:Init( )

	self.Categories = {}
	self.Meters = {}
	self.Engine = ACF.Weapons.Mobility["0.25-I1"]
	
	self.ClassPanel = nil
	self.EnginePreview = vgui.Create( "DModelPanel", self )
	self.EnginePreview.LayoutEntity = function() end -- no rotation please ty
	
	self.EnginePreview2 = vgui.Create( "DModelPanel", self )
	self.EnginePreview2.LayoutEntity = function() end -- no rotation please ty
	
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



local function enginePower(eng)
	if eng.iselec then return eng.elecpower*1.34 end
	return 1.34 * (eng.torque * eng.peakmaxrpm) / 9548.8
	//math.Round(math.floor(Table.torque * Table.peakmaxrpm / 9548.8)*1.34)
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
function PANEL:SetEngine(engtable)
	self.Engine = engtable
	
	-- set gun model preview and centre the camera on the gun.
	self.EnginePreview:SetModel(engtable.model)
	self.EnginePreview:SetFOV(45)
	self.EnginePreview2:SetModel(engtable.model)
	self.EnginePreview2:SetFOV(45)
	
	local viewent = self.EnginePreview:GetEntity()
	local boundmin, boundmax = viewent:GetRenderBounds()
	local dist = boundmin:Distance(boundmax)*1.1
	local centre = boundmin + (boundmax - boundmin)/2
	
	self.EnginePreview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.EnginePreview:SetLookAt( centre )
	
	self.EnginePreview2:SetCamPos( centre + Vector( dist, 0, 0 ) )
	self.EnginePreview2:SetLookAt( centre )
	
	
	-- replace gun info panel with info about this gun.
	if self.ClassPanel then 
		self.ClassPanel:Remove()
		self.ClassPanel = nil
	end
	
	self.ClassPanel = vgui.Create( "DCollapsibleCategory", self )
	self.ClassPanel:SetLabel(engtable.name)
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
	label:SetText(tostring(engtable.desc or "Description unavailable!") .. "\n")
	label:SetSize(self:GetWide(), 10)
	label:SizeToContentsY()
	
	entrylist:AddItem(label)
	//*
	-- torque label
	local label = vgui.Create( "DLabel" )
	label:SetText("Torque (N/m):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--torque body
	self.TorqueMeter = self.TorqueMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.TorqueMeter
	label:SetMax(XCF.Maximum and XCF.Maximum.EngineTorque or 3000)
	label:AnimateToValues(0, engtable.torque or 0)
	label:SetTall(15)
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	-- power label
	local label = vgui.Create( "DLabel" )
	label:SetText("Peak Power (HP @ Max Powerband):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--powerperkilo body
	self.PowerMeter = self.PowerMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.PowerMeter
	label:SetMax(XCF.Maximum and XCF.Maximum.EnginePower or 938)
	label:AnimateToValues(0, enginePower(engtable)) // TODO: this
	label:SetTall(15)
	label:SetDecimals(1)
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	
	-- powerperkilo label
	local label = vgui.Create( "DLabel" )
	label:SetText("Power per Weight (Peak HP/kg):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--powerperkilo body
	self.PPKMeter = self.PPKMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.PPKMeter
	label:SetMax(XCF.Maximum and XCF.Maximum.EnginePowerPerKG or 1.45)
	label:AnimateToValues(0, enginePower(engtable) / engtable.weight) // TODO: this
	label:SetTall(15)
	
	entrylist:AddItem(label)
	entrylist:AddItem(spacer)
	
	-- powerband label
	local label = vgui.Create( "DLabel" )
	label:SetText("Powerband (RPM):")
	label:SetFont("DermaDefaultBold")
	label:SetColor(Color(150, 150, 150))
	label:SizeToContents()
	
	entrylist:AddItem(label)
	
	--powerband body
	self.BandMeter = self.BandMeter or vgui.Create( "XCF_ToolMenuMeter" )
	label = self.BandMeter
	label:SetMax(engtable.limitprm or engtable.limitrpm or (XCF.Maximum and XCF.Maximum.EngineRedline or engtable.peakmaxrpm or 13500))
	label:AnimateToValues(engtable.peakminrpm, engtable.peakmaxrpm)
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
	label:SetMax(XCF.Maximum and XCF.Maximum.EngineMass or 2000)
	label:InvertGradient(true)
	label:AnimateToValues(0, tonumber(engtable.weight) or 0)
	label:SetTall(15)
	//*/
	entrylist:AddItem(label)
	entrylist:SizeToContents()
	
	self.ClassPanel:SetContents(entrylist)
	self.ClassPanel:SetExpanded(true)
	
end



local maxCPTall = surface.ScreenHeight()/2 - 20

function PANEL:PerformLayout()
	local wided2 = self:GetWide()/2
	local prevsize = 80
	self.EnginePreview:SetTall(prevsize)
	self.EnginePreview:SetWide(prevsize)
	
	self.EnginePreview2:SetTall(prevsize)
	self.EnginePreview2:SetWide(prevsize)
	
	self.EnginePreview:SetPos((wided2 - prevsize) / 2, 0)
	self.EnginePreview2:SetPos(wided2 + (wided2 - prevsize) / 2, 0)
	
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
	return {
		["ent"] = self.Engine.ent,
		["id"]	= self.Engine.id,
		[1] = self.Engine.id
	}
end



function PANEL:Think()
	if self:GetParent() and self:GetParent().SelectPanel then
		local entry = self:GetParent().SelectPanel:GetSelectedEntry()
		if entry and entry != self.Engine then
			self:SetEngine(entry)
		end
	end
end

derma.DefineControl( "XCF_ToolMenuEnginePanel", "Menu panel for an XCF gun", PANEL, "DPanel" )
