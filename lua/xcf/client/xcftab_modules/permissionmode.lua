if not XCF.UseXCFTab then return end


local Menu = {}

// the category the menu goes under
Menu.Category = "Settings"


// the name of the item 
Menu.Name = "Permission Mode"

// the convar to execute when the player clicks on the tab
Menu.Command = ""



local Permissions = {}

local PermissionModes = {}
local CurrentPermission = "default"
local DefaultPermission = "build"
local list 

net.Receive("xcf_refreshpermissions", function(len)
	
	PermissionModes = net.ReadTable()
	CurrentPermission = net.ReadString() 
	DefaultPermission = net.ReadString()
	
	Permissions:Update()
	
end)





function Menu.MakePanel(Panel)

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
		
		//Permissions:Update()
	end
	Panel:AddItem(list)
	Panel:AddItem(txt)
	

	local button = Panel:Button("Set Permission Mode")
	button.DoClick = function()  
		local mode = list:GetLine(list:GetSelectedLine()):GetValue(1)
		RunConsoleCommand("xcf_setpermissionmode",mode) 

		Permissions:Update()

	end
	
	local button2 = Panel:Button("Set Default Permission Mode")
	button2.DoClick = function()  
		local mode = list:GetLine(list:GetSelectedLine()):GetValue(1)
		RunConsoleCommand("xcf_setdefaultpermissionmode",mode) 
		Permissions:Update()
	end
	
	

	Panel:AddItem(button)
	Panel:AddItem(button2)
	
	else
		Panel:Help("You are not an admin!")
	end
end


function Permissions:Update()

	if not list then return end
	
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


hook.Add("SpawnMenuOpen", "XCF.SpawnMenuOpen", function()
	net.Start("xcf_refreshpermissions")
		net.WriteBit(true)	
	net.SendToServer()
end) 



XCF.RegisterToolMenu(Menu)
