bkin_bl__menu = bkin_bl__menu or class()
bkin_bl__menu.menu_id = "bkin_bl__menu"
bkin_bl__menu.mod_path = ModPath
bkin_bl__menu._data_path = SavePath .. "bkin_bl__settings.json"
bkin_bl__menu._data = bkin_bl__menu._data or {}


function bkin_bl__menu:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		local json_enc = json.encode( self._data )

		-- Prevents BLT crash bug when trying to parse empty brackets [], empty braces {} are fine though
		file:write( json_enc ~= "[]" and json_enc or "{}" )
		file:close()
	end
end


function bkin_bl__menu:Load()
	if self._loaded then return self._data end

	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
	self._loaded = true;

	return self._data;
end


if not bkin_bl__menu_setup then
	bkin_bl__menu_setup = true
	bkin_bl__menu:Load()

	bkin_bl__menu._data.bkin_bl__set_size = bkin_bl__menu._data.bkin_bl__set_size or 8
end


Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit__bkin_bl", function( loc )
	loc:load_localization_file(bkin_bl__menu.mod_path .. "l10n/en.json")
end)


Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus__bkin_bl", function( menu_manager, nodes )
	MenuHelper:NewMenu( bkin_bl__menu.menu_id )
end)


Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus__bkin_bl", function( menu_manager, nodes )

	--Updates data for saving to file after user changes value
	MenuCallbackHandler.bkin_bl__set_size__clbk = function(self, item)
		local num = math.floor(item:value())
		item:set_value(num) -- Update the slider display to avoid floating point numbers
		bkin_bl__menu._data.bkin_bl__set_size = num -- Update so it can be saved
		Global.num_players_settings = num -- The variable that BigLobby references
		bkin_bl__menu:Save()
	end

	MenuHelper:AddSlider({
    id = "bkin_bl__set_size",
    title = "bkin_bl__set_size__title",
    desc = "bkin_bl__set_size__desc",
    callback = "bkin_bl__set_size__clbk",
    value = bkin_bl__menu._data.bkin_bl__set_size,
    min = 4,
    max = 128,
    step = 1,
    show_value = true,
    menu_id = bkin_bl__menu.menu_id
})

	--Some localized keys/values are generated from game data dynamically rather than predefined in json
	LocalizationManager:add_localized_strings(bkin_bl__menu._localized_strings)
end)


Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus__bkin_bl", function(menu_manager, nodes)
	nodes[bkin_bl__menu.menu_id] = MenuHelper:BuildMenu( bkin_bl__menu.menu_id )
	MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu, bkin_bl__menu.menu_id, "bkin_bl__menu__title", "bkin_bl__menu__desc", 1 )
end)
