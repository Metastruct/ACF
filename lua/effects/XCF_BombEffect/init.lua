
local DEFAULTMODEL = "models/missiles/micro.mdl"


function EFFECT:Init( data )

	//if not data.BulletData then error("No bulletdata attached to effect data!\n") return end

	self.CreateTime = SysTime()
	self.LastThink = self.CreateTime
	
	self:SetModel("models/missiles/micro.mdl") 
	
end




function EFFECT:Config(bomb)

	self.bomb = bomb
		
	bomb.Effect = self.Entity
		
	local rkclass = ACF.Weapons.Guns[bomb.Id]
		
	self:SetModel(rkclass and rkclass.round and rkclass.round.model or DEFAULTMODEL) 
	--print("bombmodel", rkclass and rkclass.round and rkclass.round.model or DEFAULTMODEL)
	--printByName(bomb)
		
	self:SetPos( bomb.Pos )	--Moving the effect to the calculated position
	self:SetAngles( bomb.Flight:Angle() )

end




function EFFECT:Update(diffs)
	
	if not IsValid(self) then return false end
	
	local bomb = self.bomb
	if not bomb then self:Remove() error("Tried to update effect without a bomb table!") end
	
	local balls = XCF.Ballistics or error("Couldn't find the Ballistics library!")
	
	if not diffs.UpdateType then self:Remove() error("Received bomb update with no UpdateType!") end
	local Hit = diffs.UpdateType
	
	if Hit == balls.HIT_END then		--bomb has reached end of flight, remove old effect
		self:HitEnd()
	elseif Hit == balls.HIT_PENETRATE then		--bomb penetrated, don't remove old effect
		self:HitPierce()
	elseif Hit == balls.HIT_RICOCHET then		--bomb ricocheted, don't remove old effect
		self:HitRicochet()
	end	
	
end




//TODO: remove need for this function
local function copyForRoundFuncs(bomb)
	local ret = table.Copy(bomb)
	ret.SimPos = bomb.Pos
	ret.SimFlight = bomb.Flight
	ret.RoundMass = bomb.ProjMass
	return ret
end


local function mergeCopiedRoundBack(bomb, original)
	bomb.SimPos = nil
	bomb.SimFlight = nil
	bomb.ProjMass = bomb.RoundMass
	bomb.RoundMass = nil
	
	table.Merge(original, bomb)
end


function EFFECT:HitEnd()
	//print("hit end")
	if self.hasHitEnd then return end
	self.hasHitEnd = true
	
	local bomb = self.bomb
	self:Remove()
	if bomb then
		bomb = copyForRoundFuncs(bomb)
		ACF.RoundTypes[bomb.Type]["endeffect"](self, bomb)
		mergeCopiedRoundBack(bomb, self.bomb)
	end
end


function EFFECT:HitPierce()
	//print("hit pierce")
	local bomb = self.bomb
	if bomb then
		bomb = copyForRoundFuncs(bomb)
		ACF.RoundTypes[bomb.Type]["pierceeffect"](self, bomb)
		mergeCopiedRoundBack(bomb, self.bomb)
	end
end


function EFFECT:HitRicochet()
	//print("hit rico")
	local bomb = self.bomb
	if bomb then
		bomb = copyForRoundFuncs(bomb)
		ACF.RoundTypes[bomb.Type]["ricocheteffect"](self, bomb)
		mergeCopiedRoundBack(bomb, self.bomb)
	end
end




function EFFECT:Think()
	local systime = SysTime()
	//print("think: " .. tostring(self.Bullet.Type))
	if self.CreateTime < systime - 30 then	//TODO: check for bullet existence like below
		self:Remove()
		return false
	end
	
	self:ApplyMovement( self.bomb )
	self.LastThink = systime
	return true
	
end 




function EFFECT:ApplyMovement( bomb )

	self:SetPos( bomb.Pos )									--Moving the effect to the calculated position
	self:SetAngles( bomb.Forward:Angle() )

end




function EFFECT:Render()  

	local bomb = self.bomb
	
	if (bomb) then
		//self.Entity:SetModelScale( bomb.Caliber * 0.1 , 0 )
		self.Entity:DrawModel()       // Draw the model. 
	end
	
end 