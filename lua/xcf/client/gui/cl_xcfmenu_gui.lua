local this, PANEL = nil, {}
include("xcf/client/gui/cl_xcfmenu_tab.lua")

function PANEL:Init( )

	this = self.Panel
	
	self.Tabs = vgui.Create( "DPropertySheet", self )
	
	
	-- gun selection tab
	self.GunTab = vgui.Create("XCF_ToolMenuTab")
	local gunselect = vgui.Create("XCF_ToolMenuSelectList")
	gunselect:SetDataTable(XCF.GunsByClass)
	self.GunTab:SetSelectPanel(gunselect)
	
	local gunview = vgui.Create("XCF_ToolMenuGunPanel")
	self.GunTab:SetEditPanel(gunview)
	
	
	-- engine selection tab
	self.EngineTab = vgui.Create("XCF_ToolMenuTab")
	local engselect = vgui.Create("XCF_ToolMenuSelectList")
	engselect:SetDataTable(XCF.EnginesByClass)
	self.EngineTab:SetSelectPanel(engselect)
	
	local engview = vgui.Create("XCF_ToolMenuEnginePanel")
	self.EngineTab:SetEditPanel(engview)
	
	
	-- gearbox selection tab
	self.GearTab = vgui.Create("XCF_ToolMenuTab")
	local gearselect = vgui.Create("XCF_ToolMenuSelectList")
	gearselect:SetDataTable(XCF.GearboxesByClass)
	self.GearTab:SetSelectPanel(gearselect)
	
	local gearview = vgui.Create("XCF_ToolMenuGearPanel")
	self.GearTab:SetEditPanel(gearview)
	
	
	-- ammo selection tab
	self.AmmoTab = vgui.Create("XCF_ToolMenuTab")
	local ammoselect = vgui.Create("XCF_ToolMenuSelectList")
	ammoselect:SetDataTable(XCF.GunsByClass)
	self.AmmoTab:SetSelectPanel(ammoselect)
	
	local ammoview = vgui.Create("XCF_ToolMenuAmmoPanel")
	self.AmmoTab:SetEditPanel(ammoview)
	
	
	self.Tabs:AddSheet( "Guns", 	self.GunTab,	nil, false, false, "Cannons and friends" )
	self.Tabs:AddSheet( "Ammo", 	self.AmmoTab,	nil, false, false, "Gun food" )
	self.Tabs:AddSheet( "Engines",	self.EngineTab,	nil, false, false, "For if you like to move things" )
	self.Tabs:AddSheet( "Gearbox",	self.GearTab,	nil, false, false, "Attach engines to wheels with these!" )
	//self.Tabs:AddSheet( "Rockets",	self.GunTab,	nil, false, false, "These things ain't for space." )
	//self.Tabs:AddSheet( "Bombs",	self.GunTab,	nil, false, false, "Indiscriminate liberation" )

	self:InvalidateLayout()
	
end


function PANEL:PerformLayout()
	
	-- min resolution X x 720
	self.Tabs:SetSize(self:GetWide(), 720)
	self:SetTall(720)
	
end


derma.DefineControl( "XCF_ToolMenu", "Menu for XCF", PANEL, "DPanel" )