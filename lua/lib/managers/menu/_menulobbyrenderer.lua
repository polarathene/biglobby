--Loop condition updated to support additional players, replacing value '4' with variable num_player_slots
function MenuLobbyRenderer:open(...)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	MenuLobbyRenderer.super.open(self, ...)
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local scaled_size = safe_rect_pixels
	MenuRenderer._create_framing(self)
	self._main_panel:hide()
	self._player_slots = {}
	self._menu_bg = self._fullscreen_panel:panel({})
	local is_server = Network:is_server()
	local server_peer = is_server and managers.network:session():local_peer() or managers.network:session():server_peer()
	local is_single_player = Global.game_settings.single_player
	local is_multiplayer = not is_single_player
	if not server_peer then
		return
	end
	logger("[MenuLobbyRenderer :open] building _player_slots")
	for i = 1, is_single_player and 1 or num_player_slots do
		logger("[MenuLobbyRenderer :open] adding player_slot: " .. tostring(i))
		local t = {}
		t.player = {}
		t.free = true
		t.kit_slots = {}
		t.params = {}
		for slot = 1, PlayerManager.WEAPON_SLOTS + 3 do
			table.insert(t.kit_slots, slot)
		end
		table.insert(self._player_slots, t)
	end
	logger("[MenuLobbyRenderer :open] done _player_slots")
	if is_server then
		local level = managers.experience:current_level()
		local rank = managers.experience:current_rank()
		logger("[MenuLobbyRenderer :open]")
		self:_set_player_slot(1, {
			name = server_peer:name(),
			peer_id = server_peer:id(),
			level = level,
			rank = rank,
			character = "random"
		})
	end
	logger("[MenuLobbyRenderer :open] _entered_menu")
	self:_entered_menu()
end

--NOT REQUIRED, used for console output debugging
function MenuLobbyRenderer:set_slot_joining(peer, peer_id)
	local peer_id_name = tostring(peer:id()) .. " - " .. tostring(peer:name())
	logger("[MenuLobbyRenderer] SETTING SLOT JOINING, peer: " .. peer_id_name)

	managers.hud:set_slot_joining(peer, peer_id)
	local slot = self._player_slots[peer_id]
	slot.peer_id = peer_id
end
