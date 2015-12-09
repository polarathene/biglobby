--Assigns a free Peer ID to new joining peer
function HostNetworkSession:_get_free_client_id()
	--logger("[HostNetworkSession: _get_free_client_id]")
	local i = 2
	repeat
		if not self._peers[i] then
			local is_dirty = false
			for peer_id, peer in pairs(self._peers) do
				if peer:handshakes()[i] then
					is_dirty = true
				end
			end
			if not is_dirty then
				return i
			end
		end
		i = i + 1
	until i == 7--5
end

--[[
function HostNetworkSession:remove_peer(peer, peer_id, reason)
	print("[HostNetworkSession:remove_peer]", inspect(peer), peer_id, reason)
	HostNetworkSession.super.remove_peer(self, peer, peer_id, reason)
	managers.vote:abort_vote(peer_id)
	if self._dead_con_reports then
		local i = #self._dead_con_reports
		while i > 0 do
			local dead_con_report = self._dead_con_reports[i]
			if dead_con_report.reporter == peer or dead_con_report.reported == peer then
				table.remove(self._dead_con_reports, i)
			end
			i = i - 1
		end
		if not next(self._dead_con_reports) then
			self._dead_con_reports = nil
		end
	end
	if NetworkManager.DROPIN_ENABLED then
		for other_peer_id, other_peer in pairs(self._peers) do
			if other_peer:is_expecting_pause_confirmation(peer_id) then
				self:set_dropin_pause_request(other_peer, peer_id, false)
			end
		end
		if self._local_peer:is_expecting_pause_confirmation(peer_id) then
			self._local_peer:set_expecting_drop_in_pause_confirmation(peer_id, nil)
			self:on_drop_in_pause_request_received(peer_id, "", false)
		end
		for other_peer_id, other_peer in pairs(self._peers) do
			self:chk_initiate_dropin_pause(other_peer)
			self:chk_drop_in_peer(other_peer)
			self:chk_spawn_member_unit(other_peer, other_peer_id)
		end
	end
	local info_msg_type = "kick_peer"
	local info_msg_id
	if reason == "kicked" then
		logger("[HostNetworkSession: remove_peer] KICKED!")
		info_msg_id = 0
	elseif reason == "auth_fail" then
		info_msg_id = 2
	else
		info_msg_id = 1
	end
	for other_peer_id, other_peer in pairs(self._peers) do
		if other_peer:handshakes()[peer_id] == true or other_peer:handshakes()[peer_id] == "asked" or other_peer:handshakes()[peer_id] == "exchanging_info" then
			other_peer:send(info_msg_type, peer_id, info_msg_id)
			other_peer:set_handshake_status(peer_id, "removing")
		end
	end
	if reason ~= "left" and reason ~= "kicked" and reason ~= "auth_fail" then
		peer:send(info_msg_type, peer_id, info_msg_id)
	end
	self:chk_server_joinable_state()
end
]]

function HostNetworkSession:chk_server_joinable_state()
	logger("[HostNetworkSession: chk_server_joinable_state]" .. "\n")
	for peer_id, peer in pairs(self._peers) do
		if peer:force_open_lobby_state() then
			print("force-opening lobby for peer", peer_id)
			logger("[HostNetworkSession: chk_server_joinable_state] peer:force_open_lobby_state()...set server true, peerid: " .. tostring(peer_id) .. "\n")
			managers.network.matchmake:set_server_joinable(true)
			return
		end
	end
	logger("[HostNetworkSession: chk_server_joinable_state] tablesize: " .. tostring(table.size(self._peers)) .. "\n")
	if table.size(self._peers) >= 5 then
		logger("[HostNetworkSession: chk_server_joinable_state] table.size(self._peers) >= 3...set server false" .. "\n")
		managers.network.matchmake:set_server_joinable(false)
		return
	end
	local game_state_name = game_state_machine:last_queued_state_name()
	if BaseNetworkHandler._gamestate_filter.any_end_game[game_state_name] then
		logger("[HostNetworkSession: chk_server_joinable_state] _gamestate_filter.any_end_game...set server false" .. "\n")
		managers.network.matchmake:set_server_joinable(false)
		return
	end
	if not self:_get_free_client_id() then
		logger("[HostNetworkSession: chk_server_joinable_state] _get_free_client_id...set server false" .. "\n")
		managers.network.matchmake:set_server_joinable(false)
		return
	end
	if not self._state:is_joinable(self._state_data) then
		logger("[HostNetworkSession: chk_server_joinable_state] _state:is_joinable...set server false" .. "\n")
		managers.network.matchmake:set_server_joinable(false)
		return
	end
	if NetworkManager.DROPIN_ENABLED then
		if BaseNetworkHandler._gamestate_filter.lobby[game_state_name] then
			logger("[HostNetworkSession: chk_server_joinable_state] DROPIN_ENABLED/_gamestate_filter.lobby...set server true" .. "\n")
			managers.network.matchmake:set_server_joinable(true)
			return
		elseif managers.groupai and not managers.groupai:state():chk_allow_drop_in() or not Global.game_settings.drop_in_allowed then
			logger("[HostNetworkSession: chk_server_joinable_state] DROPIN_ENABLED/managers.groupai...set server false" .. "\n")
			managers.network.matchmake:set_server_joinable(false)
			return
		end
	elseif not BaseNetworkHandler._gamestate_filter.lobby[game_state_name] then
		logger("[HostNetworkSession: chk_server_joinable_state] ._gamestate_filter.lobby...set server false" .. "\n")
		managers.network.matchmake:set_server_joinable(false)
		return
	end
	logger("[HostNetworkSession: chk_server_joinable_state] all clear...set server true" .. "\n")
	managers.network.matchmake:set_server_joinable(true)
end



--do I need this?
function HostNetworkSession:remove_peer(peer, peer_id, reason)
	print("[HostNetworkSession:remove_peer]", inspect(peer), peer_id, reason)
	logger("[HostNetworkSession :remove_peer] removing peer: " .. tostring(peer_id) .. ", reason: " .. tostring(reason))
	HostNetworkSession.super.remove_peer(self, peer, peer_id, reason)
	managers.vote:abort_vote(peer_id)
	if self._dead_con_reports then
		local i = #self._dead_con_reports
		while i > 0 do
			local dead_con_report = self._dead_con_reports[i]
			if dead_con_report.reporter == peer or dead_con_report.reported == peer then
				table.remove(self._dead_con_reports, i)
			end
			i = i - 1
		end
		if not next(self._dead_con_reports) then
			self._dead_con_reports = nil
		end
	end
	if NetworkManager.DROPIN_ENABLED then
		for other_peer_id, other_peer in pairs(self._peers) do
			if other_peer:is_expecting_pause_confirmation(peer_id) then
				self:set_dropin_pause_request(other_peer, peer_id, false)
			end
		end
		if self._local_peer:is_expecting_pause_confirmation(peer_id) then
			self._local_peer:set_expecting_drop_in_pause_confirmation(peer_id, nil)
			self:on_drop_in_pause_request_received(peer_id, "", false)
		end
		for other_peer_id, other_peer in pairs(self._peers) do
			self:chk_initiate_dropin_pause(other_peer)
			self:chk_drop_in_peer(other_peer)
			self:chk_spawn_member_unit(other_peer, other_peer_id)
		end
	end
	local info_msg_type = "kick_peer"
	local info_msg_id
	if reason == "kicked" then
		info_msg_id = 0
	elseif reason == "auth_fail" then
		info_msg_id = 2
	else
		info_msg_id = 1
	end
	for other_peer_id, other_peer in pairs(self._peers) do
		if other_peer:handshakes()[peer_id] == true or other_peer:handshakes()[peer_id] == "asked" or other_peer:handshakes()[peer_id] == "exchanging_info" then
			other_peer:send(info_msg_type, peer_id, info_msg_id)
			other_peer:set_handshake_status(peer_id, "removing")
			logger("[HostNetworkSession: remove_peer] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", other_peer: " .. tostring(other_peer:id()) .. " - " .. tostring(other_peer:name()) .. ", handshake status: " .. tostring(other_peer:handshakes()[peer_id]))
		end
	end
	if reason ~= "left" and reason ~= "kicked" and reason ~= "auth_fail" then
		peer:send(info_msg_type, peer_id, info_msg_id)
		logger("[HostNetworkSession: remove_peer] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. "not left/kicked/auth_fail, lost connection? info_msg_type: " .. tostring(info_msg_type) .. ", info_msg_id: " .. tostring(info_msg_id))
	end
	logger("[HostNetworkSession: remove_peer] self:chk_server_joinable_state()")
	self:chk_server_joinable_state()
end

function HostNetworkSession:on_remove_peer_confirmation(sender_peer, removed_peer_id)
	logger("[HostNetworkSession :remove_peer] removing peer: " .. tostring(removed_peer_id) .. ", sender_peer: " .. tostring(sender_peer:id()))
	print("[HostNetworkSession:on_remove_peer_confirmation]", sender_peer:id(), removed_peer_id)
	if sender_peer:handshakes()[removed_peer_id] ~= "removing" then
		print("peer should not remove. ignoring.")
		return
	end
	sender_peer:set_handshake_status(removed_peer_id, nil)
	logger("[HostNetworkSession: on_remove_peer_confirmation] self:chk_server_joinable_state()")
	self:chk_server_joinable_state()
	self:check_start_game_intro()
end

function HostNetworkSession:add_peer(name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)
	id = id or self:_get_free_client_id()
	if not id then
		return
	end
	name = name--name or "Player " .. tostring(id)
	local peer
	--character = "jacket"
	id, peer = HostNetworkSession.super.add_peer(self, name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)
	self:chk_server_joinable_state()
	return id, peer
end



--below troubleshooting connection to peers
function HostNetworkSession:on_peer_save_received(event, event_data)
	logger("[HostNetworkSession: on_peer_save_received]")
	if managers.network:stopping() then
		return
	end
	local peer = self:peer_by_ip(event_data.ip_address)
	if not peer then
		logger("[HostNetworkSession: on_peer_save_received] A nonregistered peer confirmed save packet.")
		Application:error("[HostNetworkSession:on_peer_save_received] A nonregistered peer confirmed save packet.")
		return
	end
	if event_data.index then
		local packet_index = event_data.index
		local total_nr_packets = event_data.total
		if packet_index == total_nr_packets then logger("[HostNetworkSession: on_peer_save_received] 100% packets loaded! is_playing:" .. tostring(BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]) .. " - " .. tostring(BaseNetworkHandler._gamestate_filter.any_ingame[game_state_machine:last_queued_state_name()])) end
		local progress_ratio = packet_index / total_nr_packets
		local progress_percentage = math.floor(math.clamp(progress_ratio * 100, 0, 100))
		local is_playing = BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
		logger("[HostNetworkSession: on_peer_save_received] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", progress: " .. tostring(progress_percentage))
		if is_playing then
			managers.menu:update_person_joining(peer:id(), progress_percentage)
		elseif BaseNetworkHandler._gamestate_filter.any_ingame[game_state_machine:last_queued_state_name()] then
			managers.menu:get_menu("kit_menu").renderer:set_dropin_progress(peer:id(), progress_percentage, "join")
		end
		self:send_to_peers_synched_except(peer:id(), "dropin_progress", peer:id(), progress_percentage)
	else
		logger("******************************* [HostNetworkSession :on_peer_save_received] setting synched peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()))
		cat_print("multiplayer_base", "[HostNetworkSession:on_peer_save_received]", peer, peer:id())
		peer:set_synched(true)
		peer:send("set_peer_synched", 1)
		for old_peer_id, old_peer in pairs(self._peers) do
			if old_peer ~= peer and old_peer:synched() then
				logger("******************************* [HostNetworkSession :on_peer_save_received] set_peer_synched - peer sends to old peer, old_peer: " .. tostring(old_peer:id()) .. " - " .. tostring(old_peer:name()))
				peer:send("set_peer_synched", old_peer_id)
			end
		end
		for _, old_peer in pairs(self._peers) do
			if old_peer ~= peer then
				logger("******************************* [HostNetworkSession :on_peer_save_received] set_peer_synched - old peer sends to new peer, old_peer: " .. tostring(old_peer:id()) .. " - " .. tostring(old_peer:name()))
				old_peer:send_after_load("set_peer_synched", peer:id())
			end
		end
		if NetworkManager.DROPIN_ENABLED then
			for other_peer_id, other_peer in pairs(self._peers) do
				if other_peer_id ~= peer:id() and other_peer:expecting_dropin() then
					logger("-=-=-=-=-=-=-=-=-=-=[HostNetworkSession: on_peer_save_received] asking")
					self:set_dropin_pause_request(peer, other_peer_id, "asked")
				end
			end
			for old_peer_id, old_peer in pairs(self._peers) do
				if old_peer_id ~= peer:id() and old_peer:is_expecting_pause_confirmation(peer:id()) then
					self:set_dropin_pause_request(old_peer, peer:id(), false)
				end
			end
			if self._local_peer:is_expecting_pause_confirmation(peer:id()) then
				self._local_peer:set_expecting_drop_in_pause_confirmation(peer:id(), nil)
				self:on_drop_in_pause_request_received(peer:id(), peer:name(), false)
			end
		end
		for other_peer_id, other_peer in pairs(self._peers) do
			self:chk_spawn_member_unit(other_peer, other_peer_id)
		end
		self:on_peer_sync_complete(peer, peer:id())
	end
end
function HostNetworkSession:chk_initiate_dropin_pause(dropin_peer)
	logger("[HostNetworkSession: chk_initiate_dropin_pause]")
	print("[HostNetworkSession:chk_initiate_dropin_pause]", dropin_peer:id())
	if not dropin_peer:expecting_pause_sequence() then
		print("not expecting")
		return
	end
	if not self:chk_peer_handshakes_complete(dropin_peer) then
		logger("[HostNetworkSession: chk_initiate_dropin_pause] " .. "misses handshakes")
		print("misses handshakes")
		return
	end
	if not self:all_peers_done_loading_outfits() then
		logger("[HostNetworkSession: chk_initiate_dropin_pause] " .. "peers still streaming outfits")
		print("peers still streaming outfits")
		return
	end
	if not dropin_peer:other_peer_outfit_loaded_status() then
		logger("[HostNetworkSession: chk_initiate_dropin_pause] " .. "dropin peer has not loaded outfits")
		print("dropin peer has not loaded outfits")
		return
	end
	for peer_id, peer in pairs(self._peers) do
		local is_expecting = peer:is_expecting_pause_confirmation(dropin_peer:id())
		if is_expecting then
			logger("[HostNetworkSession: chk_initiate_dropin_pause] peer: " .. tostring(peer_id) .. " is still to confirm, is_expecting: " .. tostring(is_expecting))
			print(" peer", peer_id, "is still to confirm", is_expecting)
			return
		end
	end
	for other_peer_id, other_peer in pairs(self._peers) do
		if other_peer_id ~= dropin_peer:id() and not other_peer:is_expecting_pause_confirmation(dropin_peer:id()) then
			logger("-=-=-=-=-=-=-=-=-=-=[HostNetworkSession: chk_initiate_dropin_pause] asking, " .. tostring(dropin_peer:id()) .. " - " .. tostring(dropin_peer:name()))
			self:set_dropin_pause_request(other_peer, dropin_peer:id(), "asked")
		end
	end
	if not self._local_peer:is_expecting_pause_confirmation(dropin_peer:id()) then
		logger("[HostNetworkSession: chk_initiate_dropin_pause] is_expecting_pause_confirmation")
		self._local_peer:set_expecting_drop_in_pause_confirmation(dropin_peer:id(), "paused")
		self:on_drop_in_pause_request_received(dropin_peer:id(), dropin_peer:name(), true)
	end
	dropin_peer:set_expecting_pause_sequence(nil)
	dropin_peer:set_expecting_dropin(true)
	return true
end


--not sure how useful these are below
function HostNetworkSession:set_peer_loading_state(peer, state, load_counter)
	logger("[HostNetworkSession: set_peer_loading_state] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", state: " .. tostring(state) .. ", counter: " .. tostring(load_counter))
	print("[HostNetworkSession:set_peer_loading_state]", peer:id(), state, load_counter)
	if load_counter ~= self._load_counter then
		Application:error("wrong load counter", self._load_counter)
		if not state then
			if Global.load_start_menu_lobby then
				self:send_ok_to_load_lobby()
			else
				self:send_ok_to_load_level()
			end
		end
		return
	end
	HostNetworkSession.super.set_peer_loading_state(self, peer, state)
	peer:set_loading(state)
	if Global.load_start_menu_lobby then
		return
	end
	if not state then
		logger("[HostNetworkSession: set_peer_loading_state] performing send_after_load()")
		for other_peer_id, other_peer in pairs(self._peers) do
			if other_peer ~= peer and peer:handshakes()[other_peer_id] == true then
				peer:send_after_load("set_member_ready", other_peer_id, other_peer:waiting_for_player_ready() and 1 or 0, 1, "")
			end
		end
		peer:send_after_load("set_member_ready", self._local_peer:id(), self._local_peer:waiting_for_player_ready() and 1 or 0, 1, "")
		if self._local_peer:is_outfit_loaded() then
			peer:send_after_load("set_member_ready", self._local_peer:id(), 100, 2, "")
		end
		self:chk_request_peer_outfit_load_status()
		if self._local_peer:loaded() and NetworkManager.DROPIN_ENABLED then
			if self._state.on_peer_finished_loading then
				self._state:on_peer_finished_loading(self._state_data, peer)
			end
			peer:set_expecting_pause_sequence(true)
			local dropin_pause_ok = self:chk_initiate_dropin_pause(peer)
			if dropin_pause_ok then
				self:chk_drop_in_peer(peer)
			else
				print(" setting set_expecting_pause_sequence", peer:id())
			end
		end
	end
end


function HostNetworkSession:on_peer_connection_established(sender_peer, introduced_peer_id)
logger("\n&&&&&&& [HostNetworkSession: on_peer_connection_established] start\n")
logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] sender_peer: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()) .. "\n")
if introduced_peer_id and managers and managers.network and managers.network:session() and managers.network:session():peer(introduced_peer_id) then
	local introduced_peer_name = managers.network:session():peer(introduced_peer_id):name()
	logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] introduced_peer_id: " .. tostring(introduced_peer_id) .. " - " .. tostring(introduced_peer_name) .. "\n")
else
	logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] introduced_peer_id/managers.network:session() is nil?" .. "\n")
end
		--print("status:", sender_peer:handshakes()[introduced_peer_id], self._peers[introduced_peer_id]:handshakes()[sender_peer:id()])
		if sender_peer:handshakes()[introduced_peer_id] == "asked" then
			logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] HANDSHAKE EXCHANGING INFO! asked -> exchanging_info, introduced_peer status: " .. tostring(managers.network:session():peer(introduced_peer_id):handshakes()[sender_peer:id()]) .. "\n")
			sender_peer:set_handshake_status(introduced_peer_id, "exchanging_info")
			local introduced_peer = self._peers[introduced_peer_id]
			if introduced_peer:handshakes()[sender_peer:id()] == "exchanging_info" then
				sender_peer:send("peer_exchange_info", introduced_peer_id)
				introduced_peer:send("peer_exchange_info", sender_peer:id())
			end
			return
		elseif sender_peer:handshakes()[introduced_peer_id] == "exchanging_info" then
			logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] HANDSHAKE COMPLETE! - exchanging_info -> true" .. "\n")
			sender_peer:set_handshake_status(introduced_peer_id, true)
		else
			logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] PEER NOT ASKED HANDSHAKE! IGNORING! handshake status: " .. tostring(sender_peer:handshakes()[introduced_peer_id]) .. "\n")
			print("peer was not asked. ignoring.")
			return
		end
		if self._state.on_handshake_confirmation then
			self._state:on_handshake_confirmation(self._state_data, sender_peer, introduced_peer_id)
		end
		if sender_peer:loaded() then
			logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] set_member_ready for peer: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()) .. "\n")
			sender_peer:send("set_member_ready", introduced_peer_id, self._peers[introduced_peer_id]:waiting_for_player_ready() and 1 or 0, 1, "")
		end
		self:chk_initiate_dropin_pause(sender_peer)
		if self._peers[introduced_peer_id] then
			self:chk_initiate_dropin_pause(self._peers[introduced_peer_id])
		end
		logger("&&&&&&& [HostNetworkSession: on_peer_connection_established] end\n\n")
end

function HostNetworkSession:set_game_started(state)
	logger("[HostNetworkSession :set_game_started] state: " .. tostring(state))
	self._game_started = state
	self._state_data.game_started = state
	if state then
		self:set_state("in_game")
	end
end
