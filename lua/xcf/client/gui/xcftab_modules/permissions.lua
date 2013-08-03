-- Code modified from the NADMOD client permissions menu, by Nebual
-- http://www.facepunch.com/showthread.php?t=1221183
 
if not XCF.UseXCFTab then return end

XCF = XCF or {}
XCF.Permissions = {}

local getPanelChecks = function() return {} end

local PermissionModes = {}
local CurrentPermission = "default"
local DefaultPermission = "build"

net.Receive("xcf_refreshfriends", function(len)
	--Msg("\ncl refreshfriends\n")
	local perms = net.ReadTable()
	local checks = getPanelChecks()
	
	--PrintTable(perms)
	
	for k, check in pairs(checks) do
		if perms[check.steamid] then
			check:SetChecked(true)
		else
			check:SetChecked(false)
		end
	end
	
end)
 

 
 
net.Receive("xcf_refreshpermissions", function(len)
	
	PermissionModes = net.ReadTable()
	CurrentPermission = net.ReadString() 
	DefaultPermission = net.ReadString()
	
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

local function XCFChangePermissions(mode,default)

	net.Start("xcf_changepermissions")
	

		net.WriteString(mode or CurrentPermission)
		net.WriteString(default or DefaultPermission)

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


local list 
function XCF.AdminPanel(Panel)

	if LocalPlayer():IsAdmin() then

	net.Start("xcf_refreshpermissions")
		net.WriteBit(true)	
	net.SendToServer()

	Panel:ClearControls()
	
	if not PermissionModes then return end
	
	if !XCF.AdminCPanel then XCF.AdminCPanel = Panel end
	
	Panel:SetName("Permission Modes")
	
	local pmhelp = Panel:Help("Change Permission Mode")
	pmhelp:SetContentAlignment( TEXT_ALIGN_CENTER )
	pmhelp:SetAutoStretchVertical(false)
	pmhelp:SetFont("DermaDefaultBold")
	pmhelp:SizeToContents()


	list = vgui.Create("DListView")
	list:AddColumn("Mode")
	list:AddColumn("Active")
	list:AddColumn("Map Default")
	list:SetMultiSelect(false)
	list:SetSize(30,100)

	for permission,desc in pairs(PermissionModes) do
		list:AddLine(permission, "", "")
	end
	
	
	for id,line in pairs(list:GetLines()) do
		if line:GetValue(1) == CurrentPermission then
			list:GetLine(id):SetValue(2,"Yes")
		end
		if line:GetValue(1) == DefaultPermission then
			list:GetLine(id):SetValue(3,"Yes")
		end
	end

	local txt = Panel:Help(PermissionModes[CurrentPermission] or "")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	txt:SetAutoStretchVertical(false)
	txt:SizeToContents()
	
	list.OnRowSelected = function(panel, line)
		
		txt:SetText(PermissionModes[panel:GetLine(line):GetValue(1)] or "")
		txt:SetContentAlignment( TEXT_ALIGN_CENTER )
		txt:SetAutoStretchVertical(false)
		txt:SizeToContents()
		
		//XCF.Permissions:Update()
	end
	Panel:AddItem(list)
	Panel:AddItem(txt)
	

	
	
	local button = Panel:Button("Apply Permission Mode")
	button.DoClick = function()  
		local mode = list:GetLine(list:GetSelectedLine()):GetValue(1)
		XCFChangePermissions(mode,nil)
		CurrentPermission = mode
		XCF.Permissions:Update()

	end
	
	local button2 = Panel:Button("Set Default Permission Mode")
	button2.DoClick = function()  
		local default = list:GetLine(list:GetSelectedLine()):GetValue(1)
		XCFChangePermissions(nil,default)
		DefaultPermission = default
		XCF.Permissions:Update()
	end
	
	

	Panel:AddItem(button)
	Panel:AddItem(button2)
	
	else
		Panel:Help("You are not an admin!")
	end
end


function XCF.Permissions:Update()

	net.Start("xcf_refreshpermissions")
		net.WriteBit(true)	
	net.SendToServer()
	
	for id,line in pairs(list:GetLines()) do
		if line:GetValue(1) == CurrentPermission then
			list:GetLine(id):SetValue(2,"Yes")
		else
			list:GetLine(id):SetValue(2,"")
		end
		if line:GetValue(1) == DefaultPermission then
			list:GetLine(id):SetValue(3,"Yes")
		else
			list:GetLine(id):SetValue(3,"")
		end
	end
	
end



function XCF.SpawnMenuOpen()
	if XCF.ClientCPanel then
		XCF.ClientPanel(XCF.ClientCPanel)
	end
	
	net.Start("xcf_refreshpermissions")
		net.WriteBit(true)	
	net.SendToServer()
end
hook.Add("SpawnMenuOpen", "XCF.SpawnMenuOpen", XCF.SpawnMenuOpen)




function XCF.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("XCF", "Settings", "Client", "Client", "", "", XCF.ClientPanel)
	spawnmenu.AddToolMenuOption("XCF", "Settings", "Admin", "Admin", "", "", XCF.AdminPanel)
end
hook.Add("PopulateToolMenu", "XCF.PopulateToolMenu", XCF.PopulateToolMenu)
