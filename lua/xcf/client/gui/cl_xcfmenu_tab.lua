local PANEL = {}

function PANEL:Init( )
	self.SelectPanel = nil
	self.EditPanel = nil
end


function PANEL:SetSelectPanel(panel)
	self.SelectPanel = panel
	panel:SetParent(self)
	self:InvalidateLayout()
end


function PANEL:SetEditPanel(panel)
	self.EditPanel = panel
	panel:SetParent(self)
	self:InvalidateLayout()
end


function PANEL:PerformLayout()
	local height = 0
	local width = self:GetWide()
	
	if self.SelectPanel then 
		self.SelectPanel:SetPos(0, 0)
		self.SelectPanel:SetWide(width)
		height = self.SelectPanel:GetTall()
	end
	
	if not height == 0 then height = height + 10 end
	
	if self.EditPanel then 
		self.EditPanel:SetPos(0, height)
		self.EditPanel:SetWide(width)
		height = height + self.EditPanel:GetTall()
	end
	
	self:SetTall(height)
	self:SetWide(width)
	self.TabHeight = height
end


function PANEL:GetTall()
	return self.TabHeight or 0
end

derma.DefineControl( "XCF_ToolMenuTab", "Menu tab for an XCF entity class", PANEL, "DPanel" )
