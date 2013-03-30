//ACF.Bullet = {}
//ACF.CurBulletIndex = 0
//ACF.BulletIndexLimt = 1000  --The maximum number of bullets in flight at any one time

if not XCF or not XCF.Ballistics then include("xcf/server/xcf_ballistics_sv.lua") end
local balls = XCF.Ballistics

function ACF_CreateBullet( BulletData )
	
	//error("Called old function ACF_CreateBullet - converting to XCF ballistics!")
	balls.Launch(BulletData)
	
end

function ACF_ManageBullets()

	error("Called old function ACF_ManageBullets - converting to XCF ballistics!")
	
end
//hook.Add("Think", "ACF_ManageBullets", ACF_ManageBullets)

function ACF_RemoveBullet( Index )
	
	//error("Called old function ACF_RemoveBullet - converting to XCF ballistics!")
	balls.RemoveProj(Index)

end

function ACF_CalcBulletFlight( Index, Bullet, BackTraceOverride )
	
	error("Called old function ACF_CalcBulletFlight - converting to XCF ballistics!")
	
end

function ACF_DoBulletsFlight( Index, Bullet )

	error("Called old function ACF_DoBulletsFlight - converting to XCF ballistics!")
	
end

function ACF_BulletClient( Index, Bullet, Type, Hit, HitPos )

	error("Called old function ACF_BulletClient - converting to XCF ballistics!")

end

function ACF_BulletWorldImpact( Bullet, Index, HitPos, HitNormal )
	--You overwrite this with your own function, defined in the ammo definition file
	error("Called old function ACF_BulletWorldImpact - converting to XCF ballistics!")
end

function ACF_BulletPropImpact( Bullet, Index, Target, HitNormal, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
	error("Called old function ACF_BulletPropImpact - converting to XCF ballistics!")
end

function ACF_BulletEndFlight( Bullet, Index, HitPos )
	--You overwrite this with your own function, defined in the ammo definition file
	error("Called old function ACF_BulletEndFlight - converting to XCF ballistics!")
end

