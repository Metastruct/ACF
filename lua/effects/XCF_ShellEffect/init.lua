
function EFFECT:Init( data )

	//if not data.BulletData then error("No bulletdata attached to effect data!\n") return end

	self.CreateTime = CurTime()
	self.LastThink = self.CreateTime
	
	self:SetModel("models/munitions/round_100mm_shot.mdl") 
	
end



function EFFECT:Config(Bullet)

	self.Bullet = Bullet
		
	if Bullet.Tracer and Bullet.Tracer != 0 then
		Bullet.Tracer = ParticleEmitter( Bullet.Pos )
		Bullet.Color = Bullet.Color or Color(255, 255, 255)
	end
		
	Bullet.Effect = self.Entity
		
	self:SetPos( Bullet.Pos )	--Moving the effect to the calculated position
	self:SetAngles( Bullet.Flight:Angle() )

end




function EFFECT:Update(diffs)
	
	local Bullet = self.Bullet
	if not Bullet then self:Remove() error("Tried to update effect without a bullet table!") end
	
	local balls = XCF.Ballistics or error("Couldn't find the Ballistics library!")
	
	if not diffs.UpdateType then self:Remove() error("Received bullet update with no UpdateType!") end
	local Hit = diffs.UpdateType
	
	if Hit == balls.HIT_END then		--Bullet has reached end of flight, remove old effect
		self:HitEnd()
	elseif Hit == balls.HIT_PENETRATE then		--Bullet penetrated, don't remove old effect
		self:HitPierce()
	elseif Hit == balls.HIT_RICOCHET then		--Bullet ricocheted, don't remove old effect
		self:HitRicochet()
	end	
	
end




//TODO: remove need for this function
local function copyForRoundFuncs(bullet)
	local ret = table.Copy(bullet)
	ret.SimPos = bullet.Pos
	ret.SimFlight = bullet.Flight
	ret.RoundMass = bullet.ProjMass
	return ret
end


function EFFECT:HitEnd()
	print("effect hit end")
	if self.hasHitEnd then return end
	self.hasHitEnd = true
	local bullet = self.Bullet
	self:Remove()
	if bullet then
		bullet = copyForRoundFuncs(bullet)
		ACF.RoundTypes[bullet.Type]["endeffect"](self, bullet)
	end
end


function EFFECT:HitPierce()
	print("effect hit pierce")
	local bullet = self.Bullet
	if bullet then
		bullet = copyForRoundFuncs(bullet)
		ACF.RoundTypes[bullet.Type]["pierceeffect"](self, bullet)
	end
end


function EFFECT:HitRicochet()
	print("effect hit rico")
	local bullet = self.Bullet
	if bullet then
		bullet = copyForRoundFuncs(bullet)
		ACF.RoundTypes[bullet.Type]["ricocheteffect"](self, bullet)
	end
end




function EFFECT:Think()
	local curtime = CurTime()
	//print("think: " .. tostring(self.Bullet.Type))
	if self.CreateTime < curtime - 30 then	//TODO: check for bullet existence like below
		self:Remove()
		return false
	end
	
	self:ApplyMovement( self.Bullet )
	self.LastThink = curtime
	return true
	
end 




function EFFECT:ApplyMovement( Bullet )
	//*
	self:SetPos( Bullet.Pos )									--Moving the effect to the calculated position
	self:SetAngles( Bullet.Flight:Angle() )
	
	if Bullet.Tracer and Bullet.Tracer != 0 then
		local DeltaTime = CurTime() - self.LastThink
		local DeltaPos = Bullet.Flight*DeltaTime
		local Length =  math.max(DeltaPos:Length()*2,1)
		for i=1, 5 do
			local Light = Bullet.Tracer:Add( "sprites/light_glow02_add.vmt", Bullet.Pos - (DeltaPos*i/5) )
			if (Light) then		
				Light:SetAngles( Bullet.Flight:Angle() )
				Light:SetVelocity( Bullet.Flight:GetNormalized() )
				Light:SetColor( Bullet.Color.x, Bullet.Color.y, Bullet.Color.z )
				Light:SetDieTime( 0.1 )
				Light:SetStartAlpha( 255 )
				Light:SetEndAlpha( 155 )
				Light:SetStartSize( 5*Bullet.Caliber )
				Light:SetEndSize( 1 )
				Light:SetStartLength( Length )
				Light:SetEndLength( 1 )
			end
			local Smoke = Bullet.Tracer:Add( "particle/smokesprites_000"..math.random(1,9), Bullet.Pos - (DeltaPos*i/5) )
			if (Smoke) then		
				Smoke:SetAngles( Bullet.Flight:Angle() )
				--Smoke:SetVelocity( Vector(0,0,0) )
				Smoke:SetColor( 200 , 200 , 200 )
				Smoke:SetDieTime( 1.2 )
				Smoke:SetStartAlpha( 10 )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 1 )
				Smoke:SetEndSize( Length/400*Bullet.Caliber )
				Smoke:SetRollDelta( 0.1 )
				Smoke:SetAirResistance( 100 )
				--Smoke:SetGravity( VectorRand()*5 )
				--Smoke:SetCollide( 0 )
				--Smoke:SetLighting( 0 )
			end
		end
	end
	//*/
end




function EFFECT:Render()  

	local Bullet = self.Bullet
	
	if (Bullet) then
		self.Entity:SetModelScale( Bullet.Caliber * 0.1 , 0 )
		self.Entity:DrawModel()       // Draw the model. 
	end
	
end 