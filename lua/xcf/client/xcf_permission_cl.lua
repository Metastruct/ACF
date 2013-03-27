// Code modified from the NADMOD client permissions menu, by Nebual
// http://www.facepunch.com/showthread.php?t=1221183


XCF = XCF or {}

local getPanelChecks = function() return {} end



net.Receive("xcf_refreshfriends", function(len)
	//Msg("\ncl refreshfriends\n")
	local perms = net.ReadTable()
	local checks = getPanelChecks()
	
	//PrintTable(perms)
	
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



function XCF.ClientPanel(Panel)
	Panel:ClearControls()
	if !XCF.ClientCPanel then XCF.ClientCPanel = Panel end
	Panel:SetName("XCF Damage Permissions")
	
	local txt = Panel:Help("XCF Damage Permission Panel")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	txt:SetFont("DermaDefaultBold")
	txt:SetAutoStretchVertical(false)
	
	Panel.playerChecks = {}
	local checks = Panel.playerChecks
	
	getPanelChecks = function() return checks end
	
	local Players = player.GetAll()
	if(table.Count(Players) == 1) then
		Panel:Help("No Other Players Are Online")
	else
		for _, tar in pairs(Players) do
			if(IsValid(tar) and tar != LocalPlayer()) then
				local check = Panel:CheckBox(tar:Nick())
				check.steamid = tar:SteamID()
				checks[#checks+1] = check
			end
		end
		local button = Panel:Button("Give Damage Permission")
		button.DoClick = function() XCFApplyPermissions(Panel.playerChecks) end
	end
	
	net.Start("xcf_refreshfriends")
		net.WriteBit(true)
	net.SendToServer(ply)
end



function XCF.SpawnMenuOpen()
	if XCF.ClientCPanel then
		XCF.ClientPanel(XCF.ClientCPanel)
	end
end
hook.Add("SpawnMenuOpen", "XCF.SpawnMenuOpen", XCF.SpawnMenuOpen)



function XCF.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "XCF", "Damage Permission", "Damage Permission", "", "", XCF.ClientPanel)
end
hook.Add("PopulateToolMenu", "XCF.PopulateToolMenu", XCF.PopulateToolMenu)