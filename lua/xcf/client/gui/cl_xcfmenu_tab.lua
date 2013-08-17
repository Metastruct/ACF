local PANEL = {}
local MIN_SELECT_HEIGHT = 20
local MIN_EDIT_HEIGHT = 20

function PANEL:Init( )
	self.SelectPanel = nil
	self.EditPanel = nil
	
	self.SelectContainer = vgui.Create("DScrollPanel", self)
	self.EditContainer = vgui.Create("DScrollPanel", self)
	self.SplitBorder = vgui.Create("DPanel", self)
	self.SplitBorder.Paint = function(this)
		local x, y = this:GetWide(), this:GetTall() - 1
		surface.SetDrawColor( 0, 0, 0, 255 )
		--surface.DrawRect( 0, 0, x, y )
		--surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine(0, 0, x, 0)
		surface.DrawLine(0, y, x, y)
	end
end


function PANEL:SetSelectPanel(panel)
	self.SelectContainer = vgui.Create("DScrollPanel", self)
	self.SelectContainer:AddItem(panel)
	self.SelectPanel = panel
	//panel:SetParent(self)
	self:InvalidateLayout()
end


function PANEL:SetEditPanel(panel)
	self.EditPanel = panel
	panel:SetParent(self)
	self:InvalidateLayout()
end


function PANEL:SetMaxHeight(max)
	if not (max and type(max) == "number") then return end
	max = max - 5
	
	if not (max > 5 + MIN_SELECT_HEIGHT + MIN_EDIT_HEIGHT) then return end
	self.MaxHeight = max
end


function PANEL:PerformLayout()
	local height = 0
	local maxheight = self.MaxHeight or ScrH() * 0.75
	local width = self:GetWide()
	local isSelectValid = IsValid(self.SelectPanel)
	local editHeight = math.Clamp(self.EditPanel:GetTall(), MIN_EDIT_HEIGHT, maxheight - MIN_SELECT_HEIGHT - 10)
	local selectHeight = math.Clamp(isSelectValid and self.SelectPanel:GetTall() or 0, MIN_SELECT_HEIGHT, maxheight - editHeight)
	
	self.SelectContainer:SetPos(0, height)
	self.SelectContainer:SetTall(selectHeight)
	self.SelectContainer:SetWide(width)
	if isSelectValid then self.SelectPanel:SetWide(width) end
	height = height + selectHeight
	
	self.SplitBorder:SetPos(0, height)
	self.SplitBorder:SetTall(5)
	self.SplitBorder:SetWide(width)
	height = height + 5
	
	self.EditPanel:SetPos(0, height)
	self.EditPanel:SetWide(width)
	height = height + editHeight
	
	self:SetTall(height)
	self:SetWide(width)
	self.TabHeight = height
end


function PANEL:GetTall()
	local height = 0
	local maxheight = self.MaxHeight or ScrH() * 0.75
	local width = self:GetWide()
	local isSelectValid = IsValid(self.SelectPanel)
	local editHeight = math.Clamp(self.EditPanel:GetTall(), MIN_EDIT_HEIGHT, maxheight - MIN_SELECT_HEIGHT - 10)
	local selectHeight = math.Clamp(isSelectValid and self.SelectPanel:GetTall() or 0, MIN_SELECT_HEIGHT, maxheight - editHeight)
	
	height = height + selectHeight
	height = height + 5
	height = height + editHeight

	return height
	//return self.TabHeight or 0
end


function PANEL:GetSize()
	return self:GetWide(), self:GetTall()
end

derma.DefineControl( "XCF_ToolMenuTab", "Menu tab for an XCF entity class", PANEL, "DPanel" )
