local PANEL = {}


function PANEL:Init()
	self.Label1 = vgui.Create("DLabel", self)
	self.Label1:SetFont("DermaDefaultBold")
	self.Label1:SetText("0")
	
	self.Label2 = vgui.Create("DLabel", self)
	self.Label2:SetFont("DermaDefaultBold")
	self.Label2:SetText("1")
	
	self.Max = 1
	self.Min = 0
	
	self.Value1 = 0
	self.VisVal1 = 0
	
	self.Value2 = 1
	self.VisVal2 = 1
	
	self.Decimals = 2
	self.InvertGrad = false
	self.LastPaint = RealTime()
end


function PANEL:InvertGradient(bool)
	if bool == nil then 
		self.InvertGrad = not self.InvertGrad
	else
		self.InvertGrad = bool
	end
end


-- animate the meter to the value within abs(currentfraction - numfraction) seconds
function PANEL:AnimateToValues(num1, num2)
	num1 = num1 or self.Value1
	num2 = num2 or self.Value2
	
	local val1, val2 = self.Value1, self.Value2
	self:SetValues(num1, num2)
	self.VisVal1 = val1
	self.VisVal2 = val2
end


function PANEL:SetValue(num)
	self:SetValues(0, num)
end


-- set current value
function PANEL:SetValues(num1, num2)
	if num1 > num2 then
		local temp = num2
		num2 = num1
		num1 = temp
	end

	num1 = math.Clamp(num1, self.Min, self.Max)
	num2 = math.Clamp(num2, self.Min, self.Max)
	
	self.Value1 = num1
	self.Value2 = num2
	
	self.VisVal1 = num1
	self.VisVal2 = num2
	
	self:InvalidateLayout()
end


-- set current max number
function PANEL:SetMax(num)
	if num <= self.Min then return end
	self.Max = tonumber(num) or 1
	
	self.Value1 = self.Value1 > self.Max and self.Max or self.Value1
	self.Value2 = self.Value2 > self.Max and self.Max or self.Value2
	
	self:InvalidateLayout()
end


-- set current max number
function PANEL:SetMin(num)
	if num >= self.Min then return end
	self.Min = tonumber(num) or 0
	
	self.Value1 = self.Value1 < self.Min and self.Min or self.Value1
	self.Value2 = self.Value2 < self.Min and self.Min or self.Value2
	
	self:InvalidateLayout()
end


function PANEL:SetExtents(min, max)
	self:SetMin(min)
	self:SetMax(max)
end


-- set number of decimal places on number label
function PANEL:SetDecimals(num)
	self.Decimals = tonumber(num) or 0
end


-- move label to the appropriate place and colour it so it can be read
local colOnBG = Color(255, 255, 255)
local colOnBar = Color(0, 0, 0)

local function posColLabel(label, barTopPos, invdir, barSize)
	local textWide = label:GetWide()
	
	if (textWide + 4 > barSize) then
		if invdir then
			label:SetPos(barTopPos - (textWide + 2), 0)
			label:SetColor(colOnBG)
		else
			label:SetPos(barTopPos + 2, 0)
			label:SetColor(colOnBG)
		end
	else
		if invdir then
			label:SetPos(barTopPos + 2, 0)
			label:SetColor(colOnBar)
		else
			label:SetPos(barTopPos - (textWide + 2), 0)
			label:SetColor(colOnBar)
		end
	end
end


-- move label to the appropriate place and colour it so it can be read
/*
function PANEL:PerformLayout()

	local x, y = self:GetSize()
	
	self.Label1:SetText(tostring(math.Round(self.Value1, self.Decimals)))
	self.Label1:SetTall(y)
	self.Label1:SizeToContentsX()
	
	self.Label2:SetText(tostring(math.Round(self.Value2, self.Decimals)))
	self.Label2:SetTall(y)
	self.Label2:SizeToContentsX()
	
	local barTopPos = x * self.VisFraction1
	posColLabel(self.Label1, barTopPos, true)
	
	barTopPos = x * self.VisFraction2
	posColLabel(self.Label2, barTopPos)
	
	if self.VisFraction1 == 0 then
		self.Label1:SetVisible(false)
	elseif self.Label1:LocalToScreen(self.Label1:GetWide(), 0) > self.Label2:LocalToScreen(0, 0) then -- elseif label1 overlaps with label2
		self.Label1:SetVisible(false)
	else
		self.Label1:SetVisible(true)
	end
	
end
//*/
function PANEL:PerformLayout()

	local x, y = self:GetSize()
	
	self.Label1:SetText(tostring(math.Round(self.Value1, self.Decimals)))
	self.Label1:SetTall(y)
	self.Label1:SizeToContentsX()
	
	self.Label2:SetText(tostring(math.Round(self.Value2, self.Decimals)))
	self.Label2:SetTall(y)
	self.Label2:SizeToContentsX()
	
	local diff = self.Max - self.Min
	
	local point0
	if self.Min < 0 then
		point0 = -self.Min / diff
	else
		point0 = 0
	end
	
	point0 = point0 * x
	
	local barTopPos = x * (self.VisVal1 - self.Min) / diff
	local barSize = math.abs(barTopPos - point0)
	posColLabel(self.Label1, barTopPos, true, barSize)
	
	barTopPos = x * (self.VisVal2 - self.Min) / diff
	barSize = math.abs(barTopPos - point0)
	posColLabel(self.Label2, barTopPos, false, barSize)
	
	if self.VisVal1 == 0 then
		self.Label1:SetVisible(false)
	elseif self.Label1:LocalToScreen(self.Label1:GetWide(), 0) > self.Label2:LocalToScreen(0, 0) then -- elseif label1 overlaps with label2
		self.Label1:SetVisible(math.abs(self.VisVal1) > math.abs(self.VisVal2))
	else
		self.Label1:SetVisible(true)
	end
	
	if self.VisVal2 == 0 then
		self.Label2:SetVisible(false)
	elseif self.Label1:LocalToScreen(self.Label1:GetWide(), 0) > self.Label2:LocalToScreen(0, 0) then -- elseif label1 overlaps with label2
		self.Label2:SetVisible(math.abs(self.VisVal2) >= math.abs(self.VisVal1))
	else
		self.Label2:SetVisible(true)
	end
	
end


-- draw the coloured rectangles
function PANEL:Paint()

	local time = RealTime()
	
	local diff = self.Max - self.Min
	
	if not (self.Value1 == self.VisVal1) then
		self.VisVal1 = math.Approach(self.VisVal1, self.Value1, (time - self.LastPaint) * diff)
		self:InvalidateLayout()
	end
	
	if not (self.Value2 == self.VisVal2) then
		self.VisVal2 = math.Approach(self.VisVal2, self.Value2, (time - self.LastPaint) * diff)
		self:InvalidateLayout()
	end
	
	local x, y = self:GetSize()
	local num1 = self.VisVal1 / diff
	local num2 = self.VisVal2 / diff
	
	surface.SetDrawColor(Color(60, 60, 60))
	surface.DrawRect( 0, 0, x, y )
	
	local n2mn1 = math.abs(num2 - num1)
	local col 
	if self.InvertGrad then
		col = (1 - n2mn1) * 120
	else
		col = n2mn1 * 120
	end
	
	local point0
	if self.Min < 0 then
		point0 = -self.Min / diff
	else
		point0 = 0
	end
	
	local f1 = (self.VisVal1 - self.Min) / diff
	local f2 = (self.VisVal2 - self.Min) / diff
	
	surface.SetDrawColor(HSVToColor( col, 1, 1 ))
	surface.DrawRect( x*f1, 0, x * (f2 - f1), y )

	surface.SetDrawColor(Color( 255, 255, 255 ))
	surface.DrawLine(x*point0, 0, x*point0, y)
	
	surface.SetDrawColor(Color(180, 180, 180))
	surface.DrawOutlinedRect( 0, 0, x, y )
	
	self.LastPaint = time
	
end


derma.DefineControl( "XCF_ToolMenuMeter", "A coloured number meter", PANEL, "DPanel" )
