include("xcf/client/cl_xcfmenu_ammopanel.lua")

local function dolayout(frame)
	if not frame.Content then return end
	
	local sx, sy = frame:GetSize()
	frame.ContentX = sx - frame.PaddingX*2
	frame.ContentY = sy - frame.PaddingY*2 - frame.TopBarHeight
	
	if frame.ContentX <= 100 then
		frame.ContentX = 100
		frame:SetWide(frame.ContentX + frame.PaddingX*2)
	end
	
	if frame.ContentY <= 10 then
		frame.ContentY = 10
		frame:SetWide(frame.ContentY + frame.PaddingY*2 + frame.TopBarHeight)
	end
	
	frame.Content:SetPos(frame.PaddingX, frame.PaddingY + frame.TopBarHeight)
	frame.Content:SetSize(frame.ContentX, frame.ContentY)
	
	frame:SetFocusTopLevel(true)
end


local function Cmds(ply,command,args)

	self = vgui.Create("DFrame")
	self:SetSizable(true)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 20
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self:SetSize(self.WindowX, self.WindowY)
	self:SetTitle("testing testing")
	
	-- ammo selection tab
	self.AmmoTab = vgui.Create("XCF_ToolMenuTab", self)
	local ammoselect = vgui.Create("XCF_ToolMenuSelectList")
	//ammoselect:SetDataTable(XCF.GunsByClass)
	ammoselect:SetDataTable(XCF.GunsByClass)
	self.AmmoTab:SetSelectPanel(ammoselect)
	
	local ammoview = vgui.Create("XCF_ToolMenuAmmoPanel")
	self.AmmoTab:SetEditPanel(ammoview)
	ammoview:SetGunAmmo(ACF.Weapons.Guns["200mmM"], "HEAT")
	
	self.Content = self.AmmoTab
	
	local oldlayout = self.PerformLayout
	self.PerformLayout = function(frame) oldlayout(frame) dolayout(frame) end
	
	self:SetSize(300, 800)
	self:Center()
	self:SetFocusTopLevel(true)
	self:MakePopup()
	
end

concommand.Add("test_me_some_derma_son", Cmds)