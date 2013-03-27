include("xcf/client/gui/cl_xcfmenu_meter.lua")

local PANEL = {}

AccessorFunc( PANEL, "Dragging", "Dragging" )
AccessorFunc( PANEL, "lockv1", "LockToLeft" )


local oldinit = XCF_ToolMenuMeter.Init or Error("couldn't find the meter paint")
function PANEL:Init()
	oldinit(self)
	self.lockv1 = true
end


function PANEL:OnMousePressed( mcode )

	self:SetDragging( true )
	self:MouseCapture( true )
	
	local x, y = self:CursorPos()
	self:OnCursorMoved( x, y )
	
end


function PANEL:OnMouseReleased( mcode )

	self:SetDragging( false )
	self:MouseCapture( false )

end


function PANEL:OnCursorMoved(x, y)
	
	if !self.Dragging then return end
	
	if self.lockv1 then
		local w, h = self:GetSize()
		
		local diff = self.Max - self.Min
		local scale = diff / w
		
		local x = math.Clamp( x, 0, w )
		x = x * scale
		x = x + self.Min
		self:SetValue( x )
		
		self:UpdateConVar()
		self:InvalidateLayout()
	end
	-- TODO if needed: multi-value clicking
	
end


function PANEL:GetValue()
	if self.Value1 == 0 then return math.Round(self.Value2, self.Decimals) end
	return math.Round(self.Value1, self.Decimals)
end


function PANEL:SetConVar(cvar)
	if cvar then
		self.cvar = cvar
		local cval = GetConVarNumber(cvar)
		if cval then
			self:SetValue(cval)
		end
		//self:UpdateConVar()
		
		-- callback for cvar change
		local func = nil
		local this = self
		
		func = function( cvar, old, new )
			if this and this:Valid() then	
				local new = tonumber(new)
				if new then
					this:SetValue(new)
				end
			else -- need to remove callback manually
				local callbacks = cvars.GetConVarCallbacks(cvar)
				for k, v in pairs(callbacks) do
					if v == func then 
						callbacks[k] = nil
					end
				end
			end
		end
		
		cvars.AddChangeCallback( cvar, func )
		
	else
		self.cvar = nil
		self.cval = nil
	end
end


function PANEL:UpdateConVar()
	if self.cvar then
		RunConsoleCommand(self.cvar, tostring(self:GetValue()))
	end
end


local oldpaint	 = XCF_ToolMenuMeter.Paint or Error("couldn't find the meter paint")
local bullet	 = Material("icon16/bullet_white.png")
local bulx, buly = 16, 16

function PANEL:Paint()
	oldpaint(self)
	local diff = self.Max - self.Min
	
	local barTopPos = self:GetWide() * (self:GetValue() - self.Min) / diff
	local ycen = self:GetTall() / 2
	
	surface.SetMaterial( bullet )
	surface.SetDrawColor( Color(255, 255, 255, 255) )
	surface.DrawTexturedRect( barTopPos - bulx/2, ycen - buly/2, bulx, buly )
end


derma.DefineControl( "XCF_ToolMenuMeterSlider", "A coloured number meter slider", PANEL, "XCF_ToolMenuMeter" )
