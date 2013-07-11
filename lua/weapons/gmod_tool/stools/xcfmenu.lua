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
	TOOL.AllowedTypes["acf_ammo"] 		= true
	TOOL.AllowedTypes["acf_engine"] 	= true
	TOOL.AllowedTypes["acf_gearbox"] 	= true



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
	
	net.Start("xcfmenu_transmit")
		net.WriteTable(info)
	net.SendToServer()
	
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
	
	
	local translateEntToType = 
	{
		["acf_gun"] = "Guns",
		["acf_ammo"] = "Ammo",
		["acf_engine"] = "Mobility",
		["acf_gearbox"] = "Mobility"
	}
	
	
	util.AddNetworkString("xcfmenu_transmit")
	net.Receive("xcfmenu_transmit", function(len, ply)
		
		if not (IsValid(ply) and ply:IsPlayer()) then return end
		
		local now = CurTime()
		print(now - lastreceive, delay)
		if (now - lastreceive < delay) then lastreceive = now return end
		lastreceive = now
		
		local trace = util.TraceLine(util.GetPlayerTrace(ply))
		
		if not (trace.Entity:IsValid() or trace.Entity:IsWorld()) then return false end
	
		local infotable = net.ReadTable()
	
		//PrintTable(infotable)
	
		local Type = infotable["ent"]	-- entity class
		local Id = infotable["id"]		-- acf short id for desired class
		
		if not XCF.TOOL.AllowedTypes[string.lower(Type)] then 	-- no naughtiness thanks
			ply:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", "You aren't allowed to spawn '" .. Type .. "' with this tool!", "NOTIFY_ERROR" ) )
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
			local success, Feedback
			if ( trace.Entity:GetClass() == Type and trace.Entity.CanUpdate ) then
				table.insert(ArgTable,1,ply)
				success, Feedback = trace.Entity:Update( ArgTable )
			else
				local Ent = DupeClass.Func(ply, unpack(ArgTable))		--Using the Duplicator entity register to find the right factory function
				if IsValid(Ent) then
					Ent:Activate()
					Ent:GetPhysicsObject():Wake()
      
					//print(Type, Id)
					//PrintTable(infotable)
					
					local enttype = translateEntToType[Type]
	  
      				undo.Create( ACF.Weapons[enttype][Id]["ent"] )
        				undo.AddEntity( Ent )
        				undo.SetPlayer( ply )
      				undo.Finish()
				end
			end
			
			if Feedback then
				ply:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", Feedback, "NOTIFY_ERROR" ) )
			end
				
			return true
		else
			ply:SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", "Couldn't spawn your '" .. Type .. "' because it's not recognized by the GMod duplicator!", "NOTIFY_ERROR" ) )
			error("XCFTOOL: Didn't find entity duplicator records for \"" .. Type .. "\"!")
		end
		
	end)

end



function TOOL:LeftClick( trace )

	//print("CLIENT=", CLIENT, "SERVER=", SERVER)

	if (CLIENT) then
		
		self:TransmitSelection()
		return true
	
	end
	
	self.LastClick = trace

end



function TOOL:RightClick( trace )

	if !(trace.Entity && trace.Entity:IsValid()) then return false end

	if (CLIENT) then return true end
	
	if self:GetOwner():KeyDown( IN_USE ) then
	
		if (self:GetStage() == 0) and trace.Entity.IsMaster then
			self.Master = trace.Entity
			self:SetStage(1)
			return true
		elseif self:GetStage() == 1 then
			local Error = self.Master:Unlink( trace.Entity )
			if !Error then
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('Unlink Succesful', NOTIFY_GENERIC, 7);" )
			elseif Error != nil then
				self:GetOwner():SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", tostring(Error), "NOTIFY_ERROR" ) )
			else
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('Unlink Failed', NOTIFY_GENERIC, 7);" )
			end
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
			local Error = self.Master:Link( trace.Entity )
			if !Error then
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('Link Succesful', NOTIFY_GENERIC, 7);" )
			elseif Error != nil then
				self:GetOwner():SendLua( string.format( "GAMEMODE:AddNotify(%q,%s,7)", tostring(Error), "NOTIFY_ERROR" ) )
			else
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('Link Failed', NOTIFY_GENERIC, 7);" )
			end
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



function TOOL:UpdateGhostXCF( ent, player )

	if not CLIENT then return end

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if (trace.Entity && XCF.TOOL.AllowedTypes[trace.Entity:GetClass()] || trace.Entity:IsPlayer()) then
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



function TOOL:Think()

	if CLIENT then	
		if not self.GhostEntity then
			local info = self:GetSelection()
			local gun = info.id
			gun = ACF.Weapons.Guns[gun]
			
			if not gun then
				gun = {model = "models/machinegun/machinegun_127mm.mdl"}
			end
			
			self:MakeGhostEntity( gun.model, Vector(0,0,0), Angle(0,0,0) )
			//print(self.GhostEntity)
		end
	
		self:UpdateGhostXCF( self.GhostEntity, self:GetOwner() )
	end
	
end


