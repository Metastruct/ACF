
/**
	Given the victimized entity and the damage inflictor, determine if this damage is permitted or not.
	Args;
		Entity	Entity
			The entity which may be damaged.
		Inflictor Player
			The player who owns the object which inflicted the damage.
	Return; Boolean or String
		false if the damage is not permitted, else a string representing the victim's damage model.
//*/
function XCF_Check( Entity, Inflictor )
	
	print("checking ", tostring(Entity), " against player ", tostring(Inflictor), debug.traceback())
	
	if ( IsValid(Entity) ) then
	
		if CPPI and not XCF.DamagePermission(Entity:CPPIGetOwner(), Inflictor, Entity) then print("cppi false") return false end
	
		if ( Entity:GetPhysicsObject():IsValid() and !Entity:IsWorld() and !Entity:IsWeapon() ) then
			local Class = Entity:GetClass()
			if ( Class != "gmod_ghost" and Class != "debris" and Class != "prop_ragdoll" and not string.find( Class , "func_" )  ) then
				if !Entity.ACF then 
					ACF_Activate( Entity )
				elseif Entity.ACF.Mass != Entity:GetPhysicsObject():GetMass() then
					ACF_Activate( Entity , true )
				end
				print("passed as type ", Entity.ACF.Type)
				return Entity.ACF.Type	
			end	
		end
	end
	print("invalid")
	return false
	
end



function XCF_CreateBulletSWEP( BulletData, Swep )

	BulletData = table.Copy(BulletData)
	BulletData.TraceBackComp = Swep.Owner:GetVelocity():Dot(BulletData.Flight:GetNormalized())
	BulletData.Filter = BulletData.Filter or {}
	BulletData.Gun = Swep
	BulletData.Filter[#BulletData.Filter + 1] = Swep.Owner
	
	local BulletData = XCF.Ballistics.Launch(BulletData)
	
	return BulletData
	
end