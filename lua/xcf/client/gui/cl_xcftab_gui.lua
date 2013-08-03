// main switch for the XCF Tab
XCF.UseXCFTab = false
// In Development


// use this in any files related to the XCF Tab
if not XCF.UseXCFTab then return end


// XCF Tab gui !!! -- wrex

function XCF.GunPanel(Panel)
	Panel:ClearControls()
	
	-- gun selection tab
	local GunTab = vgui.Create("XCF_ToolMenuTab")
	local gunselect = vgui.Create("XCF_ToolMenuSelectList")

	gunselect:SetDataTable(XCF.GunsByClass)
	GunTab:SetSelectPanel(gunselect)
	
	local gunview = vgui.Create("XCF_ToolMenuGunPanel")
	GunTab:SetEditPanel(gunview)
	
	Panel.Tab = GunTab 
	
	Panel:AddPanel(GunTab)
	
end

function XCF.EnginePanel(Panel)
	Panel:ClearControls()
	
	-- engine selection tab
	local EngineTab = vgui.Create("XCF_ToolMenuTab")
	
	local engselect = vgui.Create("XCF_ToolMenuSelectList")
	engselect:SetDataTable(XCF.EnginesByClass)
	
	EngineTab:SetSelectPanel(engselect)
	
	local engview = vgui.Create("XCF_ToolMenuEnginePanel")
	EngineTab:SetEditPanel(engview)
	
	Panel.Tab = EngineTab // for the stool
	
	Panel:AddPanel(EngineTab)

end

function XCF.AmmoPanel(Panel)
	Panel:ClearControls()

	-- ammo selection tab
	local AmmoTab = vgui.Create("XCF_ToolMenuTab")
	local ammoselect = vgui.Create("XCF_ToolMenuSelectList")
	ammoselect:SetDataTable(XCF.GunsByClass)
	AmmoTab:SetSelectPanel(ammoselect)
	
	local ammoview = vgui.Create("XCF_ToolMenuAmmoPanel")
	AmmoTab:SetEditPanel(ammoview)
	
		
	Panel.Tab = AmmoTab // for the stool
	
	Panel:AddPanel(AmmoTab)
end

function XCF.GearboxPanel(Panel)
	Panel:ClearControls()

	-- gearbox selection tab
	local GearTab = vgui.Create("XCF_ToolMenuTab")
	local gearselect = vgui.Create("XCF_ToolMenuSelectList")
	gearselect:SetDataTable(XCF.GearboxesByClass)
	GearTab:SetSelectPanel(gearselect)
	
	local gearview = vgui.Create("XCF_ToolMenuGearPanel")
	GearTab:SetEditPanel(gearview)
	
	Panel.Tab = GearTab // for the stool
	
	Panel:AddPanel(GearTab)
	
end


local InvokeXCFTool = false
local function AddToolTab()

	

	spawnmenu.AddToolTab("XCF","XCF")  

	spawnmenu.AddToolCategory("XCF","Settings","Settings")
	spawnmenu.AddToolCategory("XCF","Mobility","Mobility")
	spawnmenu.AddToolCategory("XCF","Weapons", "Weapons" )

	//spawnmenu.AddToolMenuOption("XCF", "Weapons",  "Guns", 		"Guns", 	  InvokeXCFTool and "gmod_tool xcfmenu" or "", "", XCF.GunPanel)
	//spawnmenu.AddToolMenuOption("XCF", "Weapons",  "Ammo", 		"Ammo", 	  InvokeXCFTool and "gmod_tool xcfmenu" or "", "", XCF.AmmoPanel)
	//spawnmenu.AddToolMenuOption("XCF", "Mobility", "Engines", 	"Engines",    InvokeXCFTool and "gmod_tool xcfmenu" or "", "", XCF.EnginePanel)
	//spawnmenu.AddToolMenuOption("XCF", "Mobility", "Gearboxes", "Gearboxes",  InvokeXCFTool and "gmod_tool xcfmenu" or "", "", XCF.GearboxPanel)

end

// XCF Tab Modules
local tfiles,_ = file.Find("xcf/client/gui/xcftab_modules/*lua", "LUA")
for _,file in pairs(tfiles) do
	include("xcf/client/gui/xcftab_modules/"..file)
end


hook.Add("AddToolMenuTabs", "XCFAddMenuTabs", AddToolTab);