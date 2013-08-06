if not XCF.UseXCFTab then return end

local Menu = {}

// the category the menu goes under
Menu.Category = "Home"

// the name of the item 
Menu.Name = "Changelog"

// the convar to execute when the player clicks on the tab
Menu.Command = ""


// should this panel refresh when the player opens the menu? 
Menu.ShouldRefresh = false


// how many commits should be shown
local LogAmount = 50



local LogAddress = "https://api.github.com/repos/nrlulz/ACF/commits?per_page="..LogAmount


local CPanel
function Menu.MakePanel(Panel)
	Panel:ClearControls()
	if !CPanel then CPanel = Panel end
	
	local tree = vgui.Create("DTree")
	tree:SetSize(Panel:GetWide(),Panel:GetTall())
	tree:AddNode("Test")
	Panel:AddItem(tree)
	
	
	
	--local html = vgui.Create("DTextEntry")
	--html:SetSize(Panel:GetWide(), 200)
	--Panel:AddItem(html)
	

end

// this function is called when the player opens their spawn menu
function Menu.OnSpawnmenuOpen()
	if Menu.ShouldRefresh and CPanel then
		Menu.MakePanel(CPanel)
	end
	// goes below this
	
	

end


XCF.RegisterToolMenu(Menu)