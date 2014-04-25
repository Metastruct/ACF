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

local HTML = {}

print(file.Exists("includes/modules/markdown.lua","LUA"))

if not markdown and file.Exists("includes/modules/markdown.lua","LUA") then
	require('markdown')
else
	Error("markdown module not found, aborting creating XCF wiki!")
	return 
end




local name, repo = "nrlulz", "ACF"




local pagelistRegex = 
// div id most closely containing the page list
'<div id="wiki%-content" class="has_rightbar">' ..
// containing div class
'%s*<div class="markdown%-body">' .. 
// the list within
'%s*<ul>(.-)</ul>'..
// class-closing div
'%s*</div>'

local linklistRegexGlobal = 
// get partial url in the listed links
'<a href="(.-)">'

local extractPagenameRegex = 
'/.-/.-/wiki/(.*)'


local function wikiPagesFailed(callback)
	callback()
end


local function wikiPagesSuccess(html, callback)
	
	local linklist = string.match(html, pagelistRegex)

	if linklist then
		print("got links!")
		local links = {}
		
		for link in string.gmatch(linklist, linklistRegexGlobal) do
			links[#links+1] = string.match(link, extractPagenameRegex) or "Home"
		end
		//PrintTable(links)
		callback(links)
	else
		wikiPagesFailed(callback)
	end
	
end


GitRC = GitRC or {}
local pagelist = "https://github.com/%s/%s/wiki/_pages"
function GitRC.GetWikiPages(name, repo, callback)
	http.Fetch(string.format(pagelist, name, repo), 
		function(html) 	wikiPagesSuccess(html, callback) end,
		function() 		wikiPagesFailed(callback) end
	)	
end



local DefaultPages = {
"Advanced-Armour",
"Basic-Armour",
"Intermediate-Armour",
"Mobility-Basics",
"Shell-library",
"Home"
}

// TODO: more advanced sorting (grouping tut series together) OR tree structure in sidebar
local function pageSort(a, b)
	return a < b
end


local StartPage = "Home"
local Link = "http://raw.github.com/wiki/%s/%s/"

local function WikiPageListCallback(Pages)
	if not Pages then Pages = DefaultPages end

	table.sort(Pages, pageSort)
	
	for i=1, #Pages do
		local mdlink = string.format(Link, name, repo)..Pages[i]..".md"
		
		local function MDToHTML( Src )
			local html = markdown(Src)
			HTML[string.gsub(Pages[i], "[-_]", " ")] = '<body bgcolor="#f0f0f0"><font face="Helvetica" color="#0f0f0f">' .. html .. "</font></body>"
		end

		local function Wiki_Receive( Src )
			coroutine.resume( coroutine.create( MDToHTML ),  Src )
		end
		http.Fetch( mdlink, Wiki_Receive, print)
	end
end

GitRC.GetWikiPages(name, repo, WikiPageListCallback)


local Wiki 
function WikiOpen()
	if Wiki then 
		Wiki:SetVisible(true)
	else 
		Wiki = vgui.Create("XCF_Wiki")
		Wiki:SetList(HTML, StartPage)
	end
end

concommand.Add("xcf_wiki_open",function() 
	WikiOpen()
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
