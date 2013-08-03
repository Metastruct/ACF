-- Code modified from the NADMOD client permissions menu, by Nebual
-- http://www.facepunch.com/showthread.php?t=1221183
if not XCF.UseXCFTab then return end

local Menu = {}

// the category the menu goes under
Menu.Category = "Settings"


// the name of the item 
Menu.Name = "Damage Permissions"

// description that people see when they hover over the item
Menu.Description = "Managing Client Damage Permissions"

// the convar to run when the item is clicked on
Menu.Command = ""


local ClientCPanel

local getPanelChecks = function() return {} end


net.Receive("xcf_refreshfriends", function(len)

	local perms = net.ReadTable()
	local checks = getPanelChecks()
		
	for k, check in pairs(checks) do
		if perms[check.steamid] then
			check:SetChecked(true)
		else
			check:SetChecked(false)
		end
	end
		
end)
	 
net.Receive("xcf_refreshfeedback", function(len)
	local success = net.ReadBit()
	local str, notify
		
	if success then
		str = "Successfully updated your XCF damage permissions!"
		notify = "NOTIFY_GENERIC"
	else
		str = "Failed to update your XCF damage permissions."
		notify = "NOTIFY_ERROR"
	end
		
	GAMEMODE:AddNotify(str, notify, 7)
		
end)



local function XCFApplyPermissions(checks)
	perms = {}
		
	for k, check in pairs(checks) do
		if not check.steamid then Error("Encountered player checkbox without an attached SteamID!") end
		perms[check.steamid] = check:GetChecked()
	end
		
	net.Start("xcf_dmgfriends")
		net.WriteTable(perms)
	net.SendToServer()
end



function Menu.MakePanel(Panel)
	Panel:ClearControls()
	if !ClientCPanel then ClientCPanel = Panel end
	Panel:SetName("XCF Damage Permissions")
		
	local txt = Panel:Help("XCF Damage Permission Panel")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	txt:SetFont("DermaDefaultBold")
	txt:SetAutoStretchVertical(false)

	local txt = Panel:Help("These preferences are only active during Build mode.")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	txt:SetAutoStretchVertical(false)
		
	Panel.playerChecks = {}
	local checks = Panel.playerChecks
		
	getPanelChecks = function() return checks end
		
	local Players = player.GetAll()
	for _, tar in pairs(Players) do
		if(IsValid(tar)) then
			local check = Panel:CheckBox(tar:Nick())
			check.steamid = tar:SteamID()
			--if tar == LocalPlayer() then check:SetChecked(true) end
			checks[#checks+1] = check
		end
	end
	local button = Panel:Button("Give Damage Permission")
	button.DoClick = function() XCFApplyPermissions(Panel.playerChecks) end
		
	net.Start("xcf_refreshfriends")
		net.WriteBit(true)
	net.SendToServer(ply)
end



hook.Add("SpawnMenuOpen", "XCF.SpawnMenuOpen", function()
	if ClientCPanel then
		Menu.MakePanel(ClientCPanel)
	end
end)


XCF.RegisterToolMenu(Menu)

