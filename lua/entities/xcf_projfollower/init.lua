
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
PrecacheParticleSystem( "Rocket Motor" )

function ENT:Initialize()

	self.toFollow = nil
	self.SpecialDamage = true
	self.Owner = self:GetOwner()
	self.ThinkDelay = 0.01
	
end




local nullhit = {Damage = 0, Overkill = 0, Loss = 0, Kill = false}
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )	-- Followers need to survive for as long as the projectile does.
	return table.Copy(nullhit)
end




function ENT:RegisterTo(bullet)
	self.toFollow = bullet
	
	self.Model = "models/missiles/aim54.mdl"
	self:SetModel( Model(self.Model) )
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
	local phys = self:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetMass( bullet.Mass or bullet.RoundMass or 100 ) 
	end 
	
	self.lastPos = bullet.Pos
	self.lastForward = bullet.Forward
	
	local Time = CurTime()
	
	//self:NextThink( Time + self.ThinkDelay )
	self:Think()
	
end




function ENT:Think()
 	
	local newpos, newforward
	if self.toFollow then
		if not XCF.Projectiles[self.toFollow.Index] then
			self.toFollow = nil
			self:Remove()
			return
		end
		
		newpos = self.toFollow.Pos
		self:SetPos(newpos)
		newforward = self.toFollow.Forward
		self:SetAngles(newforward:Angle())
	end
	
	debugoverlay.Line( self.lastPos, newpos, 20, Color(0, 255, 255), false )
	if newforward then debugoverlay.Line( newpos, newpos + newforward * 100, 20, Color(255, 0, 0), false ) end
	
	self.lastPos = newpos
	self.lastForward = newforward
	
	//self:NextThink( CurTime() + self.ThinkDelay )
end

