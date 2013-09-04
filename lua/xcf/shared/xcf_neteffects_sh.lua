// netfx info consistent across both states

XCF = XCF or {}
XCF.NetFX = XCF.NetFX or {}
local this = XCF.NetFX
this.AmmoUIDs = this.AmmoUIDs or {}

this.Strings = {
	SEND 		= "xcfSndPrj",
	SENDUID		= "xcfSndID",
	END			= "xcfNdPrj",
	ENDQUIET	= "xcfNdPrjQ",
	ALTER		= "xcfEdtPrj",
	AMMOREG		= "xcfMoRg",
	AMMODEREG	= "xcfMoDrg"
}

if SERVER and not this.StrNetted then
	for k, v in pairs(this.Strings) do
		--print("NetStr:", k, v)
		util.AddNetworkString(v)
	end
	this.StrNetted = true
end