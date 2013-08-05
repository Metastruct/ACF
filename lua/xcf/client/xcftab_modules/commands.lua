if not XCF.UseXCFTab then return end

local Menu = {}

// the category the menu goes under
Menu.Category = "Settings"

// the name of the item 
Menu.Name = "XCF Config"

// the convar to execute when the player clicks on the tab
Menu.Command = ""


// should this panel refresh when the player opens the menu? 
Menu.ShouldRefresh = false



local CPanel
function Menu.MakePanel(Panel)
	Panel:ClearControls()
	if !CPanel then CPanel = Panel end
	
	
	
	

end

// this function is called when the player opens their spawn menu
function Menu.OnSpawnmenuOpen()
	if Menu.ShouldRefresh and CPanel then
		Menu.MakePanel(CPanel)
	end
	// goes below this
	
	

end


XCF.RegisterToolMenu(Menu)