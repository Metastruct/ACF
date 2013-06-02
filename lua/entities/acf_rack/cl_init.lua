-- cl_init.lua

ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()
    Wire_Render(self)
end