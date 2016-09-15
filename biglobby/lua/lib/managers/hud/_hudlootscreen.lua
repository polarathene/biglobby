-- TODO: Can possibly wrap the function, undo the call we're fixing and reapply it?
function HUDLootScreen:init(hud, workspace, saved_lootdrop, saved_selected, saved_chosen, saved_setup)
	local num_player_slots = BigLobbyGlobals:num_player_slots()




	-- Original Code --
	self._backdrop = MenuBackdropGUI:new(workspace)
	self._backdrop:create_black_borders()
	self._active = false
	self._hud = hud
	self._workspace = workspace
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	self._background_layer_safe = self._backdrop:get_new_background_layer()
	self._background_layer_full = self._backdrop:get_new_background_layer()
	self._foreground_layer_safe = self._backdrop:get_new_foreground_layer()
	self._foreground_layer_full = self._backdrop:get_new_foreground_layer()
	self._baselayer_two = self._backdrop:get_new_base_layer()
	self._backdrop:set_panel_to_saferect(self._background_layer_safe)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_safe)
	self._callback_handler = {}
	local lootscreen_string = managers.localization:to_upper_text("menu_l_lootscreen")
	local loot_text = self._foreground_layer_safe:text({
		name = "loot_text",
		text = lootscreen_string,
		align = "center",
		vertical = "top",
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	self:make_fine_text(loot_text)
	local bg_text = self._background_layer_full:text({
		text = loot_text:text(),
		h = 90,
		align = "left",
		vertical = "top",
		font_size = massive_font_size,
		font = massive_font,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.4
	})
	self:make_fine_text(bg_text)
	local x, y = managers.gui_data:safe_to_full_16_9(loot_text:world_x(), loot_text:world_center_y())
	bg_text:set_world_left(loot_text:world_x())
	bg_text:set_world_center_y(loot_text:world_center_y())
	bg_text:move(-13, 9)
	local icon_path, texture_rect = tweak_data.hud_icons:get_icon_data("downcard_overkill_deck")
	self._downcard_icon_path = icon_path
	self._downcard_texture_rect = texture_rect
	self._hud_panel = self._foreground_layer_safe:panel()
	self._hud_panel:set_y(25)
	self._hud_panel:set_h(self._hud_panel:h() - 25 - 150)
	self._peer_data = {}
	self._peers_panel = self._hud_panel:panel({})
	-- End Original Code --



	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for i = 1, num_player_slots do
		self:create_peer(self._peers_panel, i)
	end




	-- Original Code --
	self._num_visible = 1
	self:set_num_visible(self:get_local_peer_id())
	if saved_setup then
		for _, setup in ipairs(saved_setup) do
			self:make_cards(setup.peer, setup.max_pc, setup.left_card, setup.right_card)
		end
	end
	self._lootdrops = self._lootdrops or {}
	if saved_lootdrop then
		for _, lootdrop in ipairs(saved_lootdrop) do
			self:make_lootdrop(lootdrop)
		end
	end
	if saved_selected then
		for peer_id, selected in pairs(saved_selected) do
			self:set_selected(peer_id, selected)
		end
	end
	if saved_chosen then
		for peer_id, card_id in pairs(saved_chosen) do
			self:begin_choose_card(peer_id, card_id)
		end
	end
	local local_peer_id = self:get_local_peer_id()
	local panel = self._peers_panel:child("peer" .. tostring(local_peer_id))
	local peer_info_panel = panel:child("peer_info")
	local peer_name = peer_info_panel:child("peer_name")
	local experience = (managers.experience:current_rank() > 0 and managers.experience:rank_string(managers.experience:current_rank()) .. "-" or "") .. managers.experience:current_level()
	peer_name:set_text(tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()) .. " (" .. experience .. ")")
	self:make_fine_text(peer_name)
	peer_name:set_right(peer_info_panel:w())
	if managers.experience:current_rank() > 0 then
		peer_info_panel:child("peer_infamy"):set_visible(true)
		peer_info_panel:child("peer_infamy"):set_right(peer_name:x())
		peer_info_panel:child("peer_infamy"):set_top(peer_name:y())
	else
		peer_info_panel:child("peer_infamy"):set_visible(false)
	end
	panel:set_alpha(1)
	peer_info_panel:show()
	panel:child("card_info"):hide()
	-- End Original Code --
end


function HUDLootScreen:set_num_visible(peers_num)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	self._num_visible = math.max(self._num_visible, peers_num)
	for i = 1, num_player_slots do
		self._peers_panel:child("peer" .. i):set_visible(i <= self._num_visible)
	end
	self._peers_panel:set_h(self._num_visible * 110)
	self._peers_panel:set_center_y(self._hud_panel:h() * 0.5)

	-- TODO: Is this console code useful for reworking the UI layout?
	if managers.menu:is_console() and self._num_visible >= 4 then
		self._peers_panel:move(0, 30)
	end
end


function HUDLootScreen:clear_other_peers(peer_id)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	peer_id = peer_id or self:get_local_peer_id()
	for i = 1, num_player_slots do
		if i ~= peer_id then
			self:remove_peer(i)
		end
	end
end


function HUDLootScreen:check_all_ready()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	local ready = true
	for i = 1, num_player_slots do
		if self._peer_data[i].active and ready then
			ready = self._peer_data[i].ready
		end
	end
	return ready
end


function HUDLootScreen:update(t, dt)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for peer_id = 1, num_player_slots do
		if self._peer_data[peer_id].wait_t then
			self._peer_data[peer_id].wait_t = math.max(self._peer_data[peer_id].wait_t - dt, 0)
			local panel = self._peers_panel:child("peer" .. tostring(peer_id))
			local card_info_panel = panel:child("card_info")
			local main_text = card_info_panel:child("main_text")
			main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen", {
				time = math.ceil(self._peer_data[peer_id].wait_t)
			}))
			local _, _, _, hh = main_text:text_rect()
			main_text:set_h(hh + 2)
			if self._peer_data[peer_id].wait_t == 0 then
				main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen_suspense"))
				local joker = self._peer_data[peer_id].joker
				local steam_drop = self._peer_data[peer_id].steam_drop
				local effects = self._peer_data[peer_id].effects
				panel:child("card" .. self._peer_data[peer_id].selected):animate(callback(self, self, "flipcard"), steam_drop and 5.5 or 2.5, callback(self, self, "show_item"), peer_id, effects)
				self._peer_data[peer_id].wait_t = false
			end
		end
	end
end
