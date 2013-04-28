
function net.WriteVectorDouble(vec)
	net.WriteDouble(vec.x)
	net.WriteDouble(vec.y)
	net.WriteDouble(vec.z)
end


function net.ReadVectorDouble()
	local x = net.ReadDouble()
	local y = net.ReadDouble()
	local z = net.ReadDouble()
	
	return Vector(x, y, z)
end


local XCFDebug = false
function xcf_dbgprint(...)
	if XCFDebug then
		print(...)
	end
end


concommand.Add( "xcf_debugprint", function(ply, cmd, args, str)
	if not args[1] then ply:PrintMessage(HUD_PRINTCONSOLE,
		"\"xcf_debugprint\" = " .. XCFDebug ..
		"\n - Toggles XCF debug console messages")
		return
	end
	
	XCFDebug = (tonumber(args[1]) == 1) and true or false
end)