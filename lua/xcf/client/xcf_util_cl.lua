

/**
	Creates and returns a clientside effect.
	Credit to Silverlan @ FP for the approach and code;
		http://facepunch.com/showthread.php?t=1251520&p=39805135&viewfull=1#post39805135
		
	Args;
		name	String
			The effect's classname
		date	CEffectData
			The effectdata to init the effect with.
	Return;	CLuaEffect
		The created effect
//*/

local req = false
local effect
function util.ClientsideEffect(name, data)
    req = true
    util.Effect(name, data)
    req = false
    local ent = effect
    effect = nil
    return ent
end
 
hook.Add("OnEntityCreated","cluaeffect",function(ent)
    if(req) then effect = ent end
end)




local function recvSmokeWind(len)
	XCF.SmokeWind = net.ReadFloat()
end
net.Receive("xcf_smokewind", recvSmokeWind)