
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
	self.BulletData = {}
	/*
	self.BulletData["BoomPower"] = 1.1482702255375
	self.BulletData["Caliber"] = 5
	self.BulletData["CasingMass"] = 2.8123940540182
	self.BulletData["Detonated"] = false
	self.BulletData["DragCoef"] = 0.00050152961261861
	self.BulletData["FillerMass"] = 1.0756992655375
	self.BulletData["FrAera"] = 19.635
	self.BulletData["Id"] = "50mmC"
	self.BulletData["KETransfert"]	=	0.1
	self.BulletData["LimitVel"]	=	100
	self.BulletData["MuzzleVel"]	=	197.29856160907
	self.BulletData["PenAera"]	=	12.562505640641
	self.BulletData["ProjLength"]	=	52.69
	self.BulletData["ProjMass"]	=	3.9150230626424
	self.BulletData["PropLength"]	=	2.31
	self.BulletData["PropMass"]	=	0.07257096
	self.BulletData["Ricochet"]	=	60
	self.BulletData["RoundVolume"]	=	1079.925
	self.BulletData["ShovePower"]	=	0.1
	self.BulletData["SlugCaliber"]	=	1.0956039717407
	self.BulletData["SlugDragCoef"]	=	0.0035007885725462
	self.BulletData["SlugMV"]	=	3233.5674148753
	self.BulletData["SlugMass"]	=	0.02692974308675
	self.BulletData["SlugPenAera"]	=	0.95112671226363
	self.BulletData["SlugRicochet"]	=	500
	self.BulletData["Tracer"]	=	1
	self.BulletData["Type"]	=	"HEAT"
	self.BulletData["Crate"] = -1
	self.BulletData["InvalidateTraceback"]			= true
	//*/

self.BulletData["BoomPower"]			= 0.98255158122041
self.BulletData["Caliber"]			= 5
self.BulletData["CasingMass"]			= 2.6050961123304

self.BulletData["Detonated"]			= false
self.BulletData["DragCoef"]			= 0.00054572613655341
self.BulletData["FillerMass"]			= 0.96527278084591

self.BulletData["FrAera"]			= 19.635
self.BulletData["Id"]			= "50mmC"
self.BulletData["KETransfert"]			= 0.1
self.BulletData["LimitVel"]			= 100
self.BulletData["MuzzleVel"]			= 100.42419639755
self.BulletData["PenAera"]			= 12.562505640641


self.BulletData["ProjLength"]			= 61.400001525879
self.BulletData["ProjMass"]			= 3.5979585152375
self.BulletData["PropLength"]			= 0.55000001192093
self.BulletData["PropMass"]			= 0.017278800374508
self.BulletData["Ricochet"]			= 60
self.BulletData["RoundVolume"]			= 1216.3882801947
self.BulletData["ShovePower"]			= 0.1
self.BulletData["SlugCaliber"]			= 1.1009099135806
self.BulletData["SlugDragCoef"]			= 0.003450235271917
self.BulletData["SlugMV"]			= 3656.0900686825
self.BulletData["SlugMass"]			= 0.027589622061193
self.BulletData["SlugPenAera"]			= 0.95897059965937
self.BulletData["SlugRicochet"]			= 500
self.BulletData["Tracer"]			= 1
self.BulletData["Type"]			= "HEAT"
	self.BulletData["InvalidateTraceback"]			= true
	
	self:UpdateFakeCrate()
end
