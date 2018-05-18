TOOL.Category		= "Construction"
TOOL.Name			= "#ACFMenu (XCF)"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "Guns"
TOOL.ClientConVar[ "id" ] = "12.7mmMG"
TOOL.ClientConVar[ "mdl" ] = "models/machinegun/machinegun_127mm.mdl"

TOOL.ClientConVar[ "data1" ] = "12.7mmMG"
TOOL.ClientConVar[ "data2" ] = "AP"
TOOL.ClientConVar[ "data3" ] = 0
TOOL.ClientConVar[ "data4" ] = 0
TOOL.ClientConVar[ "data5" ] = 0
TOOL.ClientConVar[ "data6" ] = 0
TOOL.ClientConVar[ "data7" ] = 0
TOOL.ClientConVar[ "data8" ] = 0
TOOL.ClientConVar[ "data9" ] = 0
TOOL.ClientConVar[ "data10" ] = 0

cleanup.Register( "xcfmenu" )



XCF = XCF or {}
XCF.TOOL = TOOL



if CLIENT then

	language.Add( "Tool.xcfmenu.name", "Armoured Combat Framework (XCF)" )
	language.Add( "Tool.xcfmenu.desc", "Engines, guns, missiles and bombs!" )
	language.Add( "Tool.xcfmenu.0", "Left click to spawn the entity of your choice, Right click to link an entity to another (+Use to unlink)" )
	language.Add( "Tool.xcfmenu.1", "Right click to link the selected sensor to a pod" )

	/*------------------------------------
		BuildCPanel
	------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
		XCF.GUI = vgui.Create("XCF_ToolMenu")
		//XCF.TOOL.GUI:SetTool(XCF.TOOL)
		CPanel:AddPanel(XCF.GUI)
	end

end

-- list of entity classes this tool is allowed to spawn.
TOOL.AllowedTypes = {}
TOOL.AllowedTypes["acf_gun"] 		= true
TOOL.AllowedTypes["acf_rack"] 		= true
TOOL.AllowedTypes["acf_ammo"] 		= true
TOOL.AllowedTypes["acf_engine"] 	= true
TOOL.AllowedTypes["acf_gearbox"] 	= true
TOOL.AllowedTypes["acf_fueltank"] 	= true


local translateEntToType =
{
	["acf_gun"] = "Guns",
	["acf_rack"] = "Guns",
	["acf_ammo"] = "Ammo",
	["acf_engine"] = "Mobility",
	["acf_gearbox"] = "Mobility",
	["acf_fueltank"] = "Mobility"
}

local getModelTable = table.Inherit({}, translateEntToType)	-- god DAMMIT fervy
getModelTable["acf_fueltank"] = "FuelTanks"



function TOOL:GetSelection()
	if SERVER then return end

	local gui = XCF.GUI.Tabs
	if not gui then error("Didn't find tool GUI") return end

	local tab = gui:GetActiveTab():GetPanel().EditPanel or error("Didn't find edit panel")
	return tab:GetInfoTable()
end



function TOOL:TransmitSelection()

	local info = self:GetSelection()
	if not info then error("Didn't get selection table from tool.") return end

	self.tosend = info

end



if SERVER then

	local function toCmdFormat(infotable)
		local ret = {}
		local maxi = 0
		for k, v in pairs(infotable) do
			if type(k) != "number" then continue end
			ret[k] = v
			if v and v != 0 and maxi < k then
				maxi = k
			end
		end

		for i=1, maxi do
			if not ret[i] then ret[i] = 0 end
		end

		return ret
	end

	local lastreceive = CurTime()
	local delay = 0.1


	util.AddNetworkString("xcfmenu_transmit")
	net.Receive("xcfmenu_transmit", function(len, ply)

		if not (IsValid(ply) and ply:IsPlayer()) then return end

		local now = CurTime()
		//print(now - lastreceive, delay)
		if (now - lastreceive < delay) then lastreceive = now return end
		lastreceive = now

		local trace = util.TraceLine(util.GetPlayerTrace(ply))

		if not (trace.Entity:IsValid() or trace.Entity:IsWorld()) then return false end

		local infotable = net.ReadTable()

		local Type = infotable["ent"]	-- entity class
		local Id = infotable["id"]		-- acf short id for desired class

		if not XCF.TOOL.AllowedTypes[string.lower(Type)] then 	-- no naughtiness thanks
			ply:SendLua( string.format( "GAMEMODE:AddNotify(%q,NOTIFY_ERROR,7)", "You aren't allowed to spawn '" .. Type .. "' with this tool!" ) )
			return false
		end

		local SpawnPos = trace.HitPos
		local DupeClass = duplicator.FindEntityClass( Type )
		if ( DupeClass ) then
			-- set up the spawn pos and angle
			local ArgTable = {}
				ArgTable[2] = trace.HitNormal:Angle():Up():Angle()
				ArgTable[1] = trace.HitPos + trace.HitNormal*32

			-- set up any required special info
			//local ArgList = list.Get("ACFCvars")
			local ArgList = toCmdFormat(infotable)
			for Number, Key in pairs( ArgList ) do 		--Reading the list packaged with the ent to see what client CVar it needs
				ArgTable[ Number+2 ] = Key
			end


			-- check if we're updating an existing entity or making a new one
			if ( trace.Entity:GetClass() == Type and trace.Entity.CanUpdate ) then
				table.insert(ArgTable,1,ply)
				status, Feedback = trace.Entity:Update( ArgTable )
				ACF_SendNotify( ply, status, Feedback )
			else
				local Ent, reason = DupeClass.Func(ply, unpack(ArgTable))		--Using the Duplicator entity register to find the right factory function
				if IsValid(Ent) then
					Ent:Activate()
					Ent:GetPhysicsObject():Wake()
					local enttype = translateEntToType[Type]

      				undo.Create( ACF.Weapons[enttype][Id]["ent"] )
        				undo.AddEntity( Ent )
        				undo.SetPlayer( ply )
      				undo.Finish()
				elseif not Ent then
					ACF_SendNotify( ply, Ent, reason )
				end
			end


			return true
		else
			ply:SendLua( string.format( "GAMEMODE:AddNotify(%q,NOTIFY_ERROR,7)", "Couldn't spawn your '" .. Type .. "' because it's not recognized by the GMod duplicator!" ) )
			error("XCFTOOL: Didn't find entity duplicator records for \"" .. Type .. "\"!")
		end

	end)

end



function TOOL:LeftClick( trace )

	if CLIENT and IsFirstTimePredicted() then

		self:TransmitSelection()
		return true

	end

	self.LastClick = trace

end



function TOOL:RightClick( trace )

	if !(trace.Entity && trace.Entity:IsValid()) then return false end

	if (CLIENT) then return true end

	local ply = self:GetOwner()

	if ply:KeyDown( IN_USE ) then

		if (self:GetStage() == 0) and trace.Entity.IsMaster then
			self.Master = trace.Entity
			self:SetStage(1)
			return true
		elseif self:GetStage() == 1 then
			local status, Feedback = self.Master:Unlink( trace.Entity )
			ACF_SendNotify( ply, status, Feedback )

			self:SetStage(0)
			self.Master = nil
			return true
		else
			return false
		end

	else

		if (self:GetStage() == 0) and trace.Entity.IsMaster then
			self.Master = trace.Entity
			self:SetStage(1)
			return true
		elseif self:GetStage() == 1 then
			local status, Feedback = self.Master:Link( trace.Entity )
			ACF_SendNotify( ply, status, Feedback )

			self:SetStage(0)
			self.Master = nil
			return true
		else
			return false
		end

	end

end



function TOOL:Reload( trace )

	// TODO: "reset" functionality

end



function TOOL:UpdateGhostXCF( ent, player, info )

	if not CLIENT then return end

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end

	if (trace.Entity && trace.Entity:GetClass() == info.ent || trace.Entity:IsPlayer()) then
		ent:SetNoDraw( true )
		return
	end

	local angle = trace.HitNormal:Angle():Up():Angle()
	local pos = trace.HitPos + trace.HitNormal*32

	ent:SetPos( pos )
	ent:SetAngles( angle )
	ent:SetNoDraw( false )

	local mdl = self:GetClientInfo("mdl")
	if not mdl then
		ent:SetNoDraw( true )
	else
		ent:SetNoDraw( false )
	end

	if not (ent:GetModel() == mdl) then
		ent:SetModel(mdl)
	end

end



local DEFAULTMODEL = "models/machinetype/machinetype_127mm.mdl"
function TOOL:Think()

	if CLIENT then
		local info = self:GetSelection()

		if not self.GhostEntity then
			--[[
			local mdltbl = ACF.Weapons[getModelTable[info.ent] or "Guns"]
			local type = mdltbl[info.id] or mdltbl[info[2] ]

			if not (type and type.model) then
				type = {model = "models/machinetype/machinetype_127mm.mdl"}
			end
			]]--
			local mdlvar = self:GetClientInfo("mdl")
			self:MakeGhostEntity( util.IsValidModel(mdlvar) and mdlvar or DEFAULTMODEL, Vector(0,0,0), Angle(0,0,0) )
			if self.GhostEntity then
				self.GhostEntity:SetNoDraw( false )
			end
		end

		self:UpdateGhostXCF( self.GhostEntity, self:GetOwner(), info )
	end

	if self.tosend then
		net.Start("xcfmenu_transmit")
			net.WriteTable(self.tosend)
		net.SendToServer()

		self.tosend = nil
	end
end


