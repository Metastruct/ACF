if not XCF.UseXCFTab then return end

local Menu = {}

// the category the menu goes under
Menu.Category = "Home"

// the name of the item 
Menu.Name = "XCF Wiki"

// the convar to execute when the player clicks on the tab
Menu.Command = ""

// should this panel refresh when the player opens the menu? 
Menu.ShouldRefresh = false

HTML = {}
Wiki = {}

print(file.Exists("includes/modules/markdown.lua","LUA"))

if not markdown and file.Exists("includes/modules/markdown.lua","LUA") then
	require('markdown')
else
	Error("markdown module not found, aborting creating XCF wiki!")
	return 
end


local Pages = {
"Advanced-Armour",
"Basic-Armour",
"Intermediate-Armour",
"Mobility-Basics",
"Shell-library",
"Home"
}

local StartPage = "Home"





local Link = "http://raw.github.com/wiki/nrlulz/ACF/"


for i=1, #Pages do
	local mdlink = Link..Pages[i]..".md"
	
	local function MDToHTML( Src )
		local html = markdown(Src)
		HTML[Pages[i]] = " <body bgcolor=\"#ffffff\"> "..html.." </body>"
	end

	local function Wiki_Receive( Src )
		coroutine.resume( coroutine.create( MDToHTML ),  Src )
	end
	http.Fetch( mdlink, Wiki_Receive, print)
end


function Wiki:Open()

	if self.frame then
		self.frame:SetVisible(!self.frame:IsVisible())
		return
	end

	self.frame = vgui.Create('DFrame')
	self.frame:SetSize(680, 470)
	self.frame:Center()
	self.frame:SetTitle('XCF Wiki')
	self.frame:SetSizable(false)
	self.frame:MakePopup()
	self.frame:SetDeleteOnClose(false)


	self.modelview = vgui.Create('DModelPanel', self.frame)
	self.modelview:SetSize(160, 160)
	self.modelview:SetPos(20, 30)
	self.modelview:SetModel( "models/engines/v6large.mdl" )
	self.modelview.LayoutEntity = function() end 
	self.modelview:SetFOV( 45 )		
		local viewent = self.modelview:GetEntity()
		local boundmin, boundmax = viewent:GetRenderBounds()
		local dist = boundmin:Distance(boundmax)*1.1
		local centre = boundmin + (boundmax - boundmin)/2
	self.modelview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.modelview:SetLookAt( centre )
	

	self.close = vgui.Create('DButton', self.frame)
	self.close:SetSize(70, 20)
	self.close:SetPos(580, 440)
	self.close:SetText('Close')
	self.close.DoClick = function() self.frame:SetVisible(false) end

	self.html = vgui.Create('DHTML', self.frame)
	self.html:SetSize(450, 400)
	self.html:SetPos(200, 30)
	self.html:SetHTML("Fetching Info....")

	
	self.tree = vgui.Create('DTree', self.frame)
	self.tree:SetSize(160, 230)
	self.tree:SetPos(20, 200)

	
	for k,v in pairsByKeys(HTML) do
		
		local node = self.tree:AddNode(string.Replace(k,"-"," "))
		node.DoClick = function() 
			Wiki.html:SetHTML(v) 
			
			
			Wiki.modelview:SetModel( "models/engines/v6large.mdl" )
			Wiki.modelview:SetFOV( 45 )
			
			local viewent = Wiki.modelview:GetEntity()
			local boundmin, boundmax = viewent:GetRenderBounds()
			local dist = boundmin:Distance(boundmax)*1.1
			local centre = boundmin + (boundmax - boundmin)/2
	
			Wiki.modelview:SetCamPos( centre + Vector( 0, dist, 0 ) )
			Wiki.modelview:SetLookAt( centre )
		
		end
		if k == StartPage then
			Wiki.html:SetHTML(v) 
		end
	end
end

concommand.Add("xcf_wiki_open",function() 
	Wiki:Open()
end)



local CPanel
function Menu.MakePanel(Panel)
	Panel:ClearControls()
	if !CPanel then CPanel = Panel end
	
	Panel:Help("XCF Wiki")
	Panel:Button("Open Wiki", "xcf_wiki_open")
	
end

// this function is called when the player opens their spawn menu
function Menu.OnSpawnmenuOpen()
	if Menu.ShouldRefresh and CPanel then
		Menu.MakePanel(CPanel)
	end
	// goes below this


end


XCF.RegisterToolMenu(Menu)