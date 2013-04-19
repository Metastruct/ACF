
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
	
	if ( IsValid(Entity) ) then
	
		if CPPI and not XCF.DamagePermission(Entity:CPPIGetOwner(), Inflictor, Entity) then return false end
	
		if ( Entity:GetPhysicsObject():IsValid() and !Entity:IsWorld() and !Entity:IsWeapon() ) then
			local Class = Entity:GetClass()
			if ( Class != "gmod_ghost" and Class != "debris" and Class != "prop_ragdoll" and not string.find( Class , "func_" )  ) then
				if !Entity.ACF then 
					ACF_Activate( Entity )
				elseif Entity.ACF.Mass != Entity:GetPhysicsObject():GetMass() then
					ACF_Activate( Entity , true )
				end
				return Entity.ACF.Type	
			end	
		end
	end
	return false
	
end



function XCF_CreateBulletSWEP( BulletData, Swep )
	
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimt then
		ACF.CurBulletIndex = 1
	end
	
	local cvarGrav = GetConVar("sv_gravity")
	BulletData["Accel"] = Vector(0,0,cvarGrav:GetInt()*-1)			--Those are BulletData settings that are global and shouldn't change round to round
	BulletData["LastThink"] = SysTime()
	BulletData["FlightTime"] = 0
	BulletData["TraceBackComp"] = 0
	local gun = BulletData["Gun"]
	if gun and gun:IsValid() then											--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		BulletData["TraceBackComp"] = Swep.Owner:GetVelocity():Dot(BulletData["Flight"]:GetNormalized())
		if gun.sitp_inspace then
			BulletData["Accel"] = Vector(0, 0, 0)
			BulletData["DragCoef"] = 0
		end
	end
	BulletData["Filter"] = { gun, Swep.Owner }
	BulletData["Index"] = ACF.CurBulletIndex
		
	ACF.Bullet[ACF.CurBulletIndex] = table.Copy(BulletData)		--Place the bullet at the current index pos
	ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
	ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	
end