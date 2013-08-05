local DontUse = true

if DontUse then return end

if not XCF.UseXCFTab then return end

local Menu = {}

// the category the menu goes under
Menu.Category = "Settings"

// the name of the item 
Menu.Name = "Test"

// the convar to execute when the player clicks on the tab
Menu.Command = ""

// true if the panel is admin only
Menu.AdminOnly = true

// should this panel refresh when the player opens the menu? 
Menu.ShouldRefresh = false



local CPanel
function Menu.MakePanel(Panel)
	Panel:ClearControls()
	
	if !CPanel then CPanel = Panel end
	
	
	if self.AdminOnly and LocalPlayer():IsAdmin() then
	
	

	
	else
		Panel:Help("You are not an admin!")
	end
end

// this function is called when the player opens their spawn menu
function Menu.OnSpawnmenuOpen()
	if self.ShouldRefresh and CPanel then
		self.MakePanel(CPanel)
	end
	// goes below this
	


end


XCF.RegisterToolMenu(Menu)