function TeamLoadoutItem:init(panel, text, i)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	TeamLoadoutItem.super.init(self, panel, text, i)
	self._player_slots = {}
	local quarter_width = self._panel:w() / num_player_slots--4
	local slot_panel
	for i = 1, num_player_slots do
		local old_right = slot_panel and slot_panel:right() or 0
		slot_panel = self._panel:panel({
			x = old_right,
			y = 0,
			w = quarter_width,
			h = self._panel:h(),
			valign = "grow"
		})
		self._player_slots[i] = {}
		self._player_slots[i].panel = slot_panel
		self._player_slots[i].outfit = {}
		local kit_menu = managers.menu:get_menu("kit_menu")
		if kit_menu then
			local kit_slot = kit_menu.renderer:get_player_slot_by_peer_id(i)
			if kit_slot then
				local outfit = kit_slot.outfit
				local character = kit_slot.params and kit_slot.params.character
				if outfit and character then
					self:set_slot_outfit(i, character, outfit)
				end
			end
		end
	end
end

function TeamLoadoutItem:reduce_to_small_font()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	TeamLoadoutItem.super.reduce_to_small_font(self)
	for i = 1, num_player_slots do
		if self._player_slots[i].box then
			self._player_slots[i].box:create_sides(self._player_slots[i].panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end
end


--[[
function MissionBriefingGui:init(saferect_ws, fullrect_ws, node)
	self._ready_up_counter = 0
	self._force_ready_threshold = 5

	self._safe_workspace = saferect_ws
	self._full_workspace = fullrect_ws
	self._node = node
	self._fullscreen_panel = self._full_workspace:panel():panel()
	self._panel = self._safe_workspace:panel():panel({
		w = self._safe_workspace:panel():w() / 2,
		layer = 6
	})
	self._panel:set_right(self._safe_workspace:panel():w())
	self._panel:set_top(165 + tweak_data.menu.pd2_medium_font_size)
	self._panel:grow(0, -self._panel:top())
	self._ready = managers.network:session():local_peer():waiting_for_player_ready()
	local ready_text = self:ready_text()
	self._ready_button = self._panel:text({
		name = "ready_button",
		text = ready_text,
		align = "right",
		vertical = "center",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3,
		layer = 2,
		blend_mode = "add",
		rotation = 360
	})
	local _, _, w, h = self._ready_button:text_rect()
	self._ready_button:set_size(w, h)
	if not managers.menu:is_pc_controller() then
	end
	self._ready_tick_box = self._panel:bitmap({
		name = "ready_tickbox",
		texture = "guis/textures/pd2/mission_briefing/gui_tickbox",
		layer = 2
	})
	self._ready_tick_box:set_rightbottom(self._panel:w(), self._panel:h())
	self._ready_tick_box:set_image(self._ready and "guis/textures/pd2/mission_briefing/gui_tickbox_ready" or "guis/textures/pd2/mission_briefing/gui_tickbox")
	self._ready_button:set_center_y(self._ready_tick_box:center_y())
	self._ready_button:set_right(self._ready_tick_box:left() - 5)
	local big_text = self._fullscreen_panel:text({
		name = "ready_big_text",
		text = ready_text,
		h = 90,
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.4,
		layer = 1,
		rotation = 360
	})
	local _, _, w, h = big_text:text_rect()
	big_text:set_size(w, h)
	local x, y = managers.gui_data:safe_to_full_16_9(self._ready_button:world_right(), self._ready_button:world_center_y())
	big_text:set_world_right(x)
	big_text:set_world_center_y(y)
	big_text:move(13, -3)
	big_text:set_layer(self._ready_button:layer() - 1)
	if MenuBackdropGUI then
		MenuBackdropGUI.animate_bg_text(self, big_text)
	end
	WalletGuiObject.set_wallet(self._safe_workspace:panel(), 10)
	self._node:parameters().menu_component_data = self._node:parameters().menu_component_data or {}
	self._node:parameters().menu_component_data.asset = self._node:parameters().menu_component_data.asset or {}
	self._node:parameters().menu_component_data.loadout = self._node:parameters().menu_component_data.loadout or {}
	local asset_data = self._node:parameters().menu_component_data.asset
	local loadout_data = self._node:parameters().menu_component_data.loadout
	if not managers.menu:is_pc_controller() then
		local prev_page = self._panel:text({
			name = "tab_text_0",
			y = 0,
			w = 0,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			text = managers.localization:get_default_macro("BTN_BOTTOM_L"),
			vertical = "top"
		})
		local _, _, w, h = prev_page:text_rect()
		prev_page:set_size(w, h + 10)
		prev_page:set_left(0)
		self._prev_page = prev_page
	end
	self._items = {}
	self._description_item = DescriptionItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_description")), 1, self._node:parameters().menu_component_data.saved_descriptions)
	table.insert(self._items, self._description_item)
	self._assets_item = AssetsItem:new(self._panel, managers.preplanning:has_current_level_preplanning() and managers.localization:to_upper_text("menu_preplanning") or utf8.to_upper(managers.localization:text("menu_assets")), 2, {}, nil, asset_data)
	table.insert(self._items, self._assets_item)
	self._new_loadout_item = NewLoadoutTab:new(self._panel, managers.localization:to_upper_text("menu_loadout"), 3, loadout_data)
	table.insert(self._items, self._new_loadout_item)
	if not Global.game_settings.single_player then
		self._team_loadout_item = TeamLoadoutItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_team_loadout")), 4)
		table.insert(self._items, self._team_loadout_item)
	end
	if tweak_data.levels[Global.level_data.level_id].music ~= "no_music" then
		self._jukebox_item = JukeboxItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_jukebox")), Global.game_settings.single_player and 4 or 5)
		table.insert(self._items, self._jukebox_item)
	end
	local max_x = self._panel:w()
	if not managers.menu:is_pc_controller() then
		local next_page = self._panel:text({
			name = "tab_text_" .. tostring(#self._items + 1),
			y = 0,
			w = 0,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			text = managers.localization:get_default_macro("BTN_BOTTOM_R"),
			vertical = "top"
		})
		local _, _, w, h = next_page:text_rect()
		next_page:set_size(w, h + 10)
		next_page:set_right(self._panel:w())
		self._next_page = next_page
		max_x = next_page:left() - 5
	end
	self._reduced_to_small_font = not managers.menu:is_pc_controller()
	self:chk_reduce_to_small_font()
	self._selected_item = 0
	self:set_tab(self._node:parameters().menu_component_data.selected_tab, true)
	local box_panel = self._panel:panel()
	box_panel:set_shape(self._items[self._selected_item]:panel():shape())
	BoxGuiObject:new(box_panel, {
		sides = {
			1,
			1,
			2,
			1
		}
	})
	if managers.assets:is_all_textures_loaded() or #managers.assets:get_all_asset_ids(true) == 0 then
		self:create_asset_tab()
	end
	self._items[self._selected_item]:select(true)
	self._enabled = true
	self:flash_ready()
end



function MissionBriefingGui:on_ready_pressed(ready)
	--gtrace("lolololololololololololololololololol")
	logger("lolololololololololololololololololol" .. "\n")
	if not managers.network:session() then
		return
	end
	local ready_changed = true
	if ready ~= nil then
		ready_changed = self._ready ~= ready
		self._ready = ready
	else
		self._ready = not self._ready
	end
	logger("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" .. "\n")
	managers.network:session():local_peer():set_waiting_for_player_ready(self._ready)
	managers.network:session():chk_send_local_player_ready()
	managers.network:session():on_set_member_ready(managers.network:session():local_peer():id(), self._ready, ready_changed, false)
	local ready_text = self:ready_text()
	self._ready_button:set_text(ready_text)
	self._fullscreen_panel:child("ready_big_text"):set_text(ready_text)
	self._ready_tick_box:set_image(self._ready and "guis/textures/pd2/mission_briefing/gui_tickbox_ready" or "guis/textures/pd2/mission_briefing/gui_tickbox")
	logger("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" .. "\n")
	if ready_changed then
		if self._ready then
			if managers.menu:active_menu() and managers.menu:active_menu().logic and managers.menu:active_menu().logic:selected_node() then
				local item = managers.menu:active_menu().logic:selected_node():item("choose_jukebox_your_choice")
				if item then
					item:set_icon_visible(false)
				end
			end
			managers.menu_component:post_event("box_tick")
		else
			managers.menu_component:post_event("box_untick")
		end
	end
logger("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" .. "\n")
if Network:is_server() then
	local all_synced = true
	for _, peer in pairs(managers.network:session():peers()) do
		if not peer:synched() then
			all_synced = false
		end
	end

	if all_synced then
		logger("1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq" .. "\n")
		self._ready_up_counter = self._ready_up_counter + 1
		logger("2qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq" .. "\n")
		if self._ready_up_counter > self._ready_up_threshold then
			logger("3qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq" .. "\n")
			managers.network:session():spawn_players()
		end
	end
end

end
]]


--Force ready script
orig_MissionBriefingGui = orig_MissionBriefingGui or {}
orig_MissionBriefingGui.init = orig_MissionBriefingGui.init or MissionBriefingGui.init

function MissionBriefingGui.init(self, ...)
    orig_MissionBriefingGui.init(self, ...)
    self._ready_up_counter = 0
     --1 is host readies up, 2 is host and one other, 3 is host and two others
    self._force_ready_threshold = 5
end

orig_MissionBriefingGui.on_ready_pressed = orig_MissionBriefingGui.on_ready_pressed or MissionBriefingGui.on_ready_pressed

function MissionBriefingGui.on_ready_pressed(self, ...)
    orig_MissionBriefingGui.on_ready_pressed(self, ...)

    if Network:is_server() then
		for k, peer in pairs(managers.network:session():peers()) do
			if not peer:loaded() then
				logger("))))))))))))))))PEER: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. " IS NOT LOADED!")
            end
            if not peer:synched() then
				logger("((((((((((((((((PEER: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. " IS NOT SYNCHED!")
				peer:set_synched(true) --TODO: you shouldn't do this normally, this is for testing to force the synced property...but should sync properly!
            end
        end
        for k, peer in pairs(managers.network:session():peers()) do
            if not peer:synched() then
            	return
            end
        end
        self._ready_up_counter = self._ready_up_counter + 1
        if self._ready_up_counter > self._force_ready_threshold then
            managers.network:session():spawn_players()
        end
    end
end
