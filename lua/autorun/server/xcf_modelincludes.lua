if not SERVER then return end

--[[
-- FFARs
resource.AddFile("models/missiles/ffar_40mm.mdl")
resource.AddSingleFile("materials/models/missiles/launcher7_40mm.vmt")
resource.AddSingleFile("models/missiles/hydra40_ambient.vtf")
resource.AddSingleFile("models/missiles/hydra40_norm.vtf")

resource.AddFile("models/missiles/ffar_40mm_closed.mdl")

resource.AddFile("models/missiles/ffar_70mm.mdl")
resource.AddFile("models/missiles/ffar_70mm_closed.mdl")


-- Racks
resource.AddFile("models/missiles/launcher7_40mm.mdl")
resource.AddSingleFile("materials/models/missiles/launcher7_40mm.vmt")
resource.AddSingleFile("materials/models/missiles/launcher7_40mm_dull.vmt")
resource.AddSingleFile("models/missiles/launcher7_40mm_skin1.vtf")
resource.AddSingleFile("models/missiles/launcher7_40mm_norm.vtf")

resource.AddFile("models/missiles/launcher7_70mm.mdl")
]]--
resource.AddWorkshop("168183029")	-- woot!

print("XCF client resources added to download list.")