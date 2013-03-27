XCF = XCF or {}

/**
	Base of the inheritance system for this project.
	adapted from	http://lua-users.org/wiki/InheritanceTutorial	, creds to those guys.
	Args;
		baseClass	Table
			the table which a new class should be derived from.
 */
function XCF.inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class, __call = new_class.New }

    function new_class:New()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

	
    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
	else
		new_class.__index = new_class
    end


    function new_class:class()
        return new_class
    end

	
    function new_class:super()
        return baseClass
    end
	
	
	function new_class:instanceof(class)
		if new_class == class then return true end
		if baseClass == nil then return false end
		return baseClass:instanceof(class)
	end
	
	/*
	function new_class:printITree()
		print(new_class)
		if baseClass then baseClass:printITree() end
	end
	//*/

    return new_class, class_mt
end