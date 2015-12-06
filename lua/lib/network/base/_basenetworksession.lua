function BaseNetworkSession:amount_of_players()
	logger("[BaseNetworkSession: amount_of_players()]")
	return table.size(self._peers_all)
end

function BaseNetworkSession:peers()
	return self._peers
end
function BaseNetworkSession:all_peers()
	return self._peers_all
end

function BaseNetworkSession:add_peer(name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)
	--logger("$$$$$$$$$$$$$$$$$$$$" .. tostring(name) .. " - " .. tostring(id))
	logger("[BaseNetworkSession: add_peer]")
	print("[BaseNetworkSession:add_peer]", name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)
	local peer = NetworkPeer:new(name, rpc, id, loading, synched, in_lobby, character, user_id)
	peer:set_xuid(xuid)
	peer:set_xnaddr(xnaddr)
	if SystemInfo:platform() == Idstring("WIN32") then
		logger("[BaseNetworkSession: add_peer] Steam32!")
		Steam:set_played_with(peer:user_id())
	end
	self._peers[id] = peer
	self._peers_all[id] = peer
	logger("[BaseNetworkSession: add_peer] Added to _peers/all, on_peer_added")
	managers.network:on_peer_added(peer, id)
	if synched then
		logger("[BaseNetworkSession: add_peer] on_peer_sync_complete")
		self:on_peer_sync_complete(peer, id)
	end
	if rpc then
		logger("[BaseNetworkSession: add_peer] rpc")
		self:remove_connection_from_trash(rpc)
		self:remove_connection_from_soft_remove_peers(rpc)
	end
	logger("[BaseNetworkSession: add_peer] end")
	return id, peer
end

function BaseNetworkSession:on_peer_sync_complete(peer, peer_id)
	if not self._local_peer then
		return
	end
	if not peer:ip_verified() then
		return
	end
	if peer:ip_verified() then
		logger("[BaseNetworkSession: on_peer_sync_complete] peer ip is verified, syncing data. Peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()))
		self._local_peer:sync_lobby_data(peer)
		self._local_peer:sync_data(peer)
	end
	self:_update_peer_ready_gui(peer)
	if Network:is_server() then
		self:check_start_game_intro()
	end
end

function BaseNetworkSession:chk_send_connection_established(name, user_id, peer)
	logger("[BaseNetworkSession: chk_send_connection_established]")
	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
		peer = self:peer_by_name(name)
		if not peer then
			print("[BaseNetworkSession:chk_send_connection_established] no peer yet", name)
			return
		end
		local connection_info = managers.network.matchmake:get_connection_info(name)
		if not connection_info then
			print("[BaseNetworkSession:chk_send_connection_established] no connection_info yet", name)
			return
		end
		if connection_info.dead then
			if peer:id() ~= 1 then
				print("[BaseNetworkSession:chk_send_connection_established] reporting dead connection", name)
				if self._server_peer then
					self._server_peer:send_queued_load("report_dead_connection", peer:id())
				end
			end
			return
		end
		local rpc = Network:handshake(connection_info.external_ip, connection_info.port, "TCP_IP")
		peer:set_rpc(rpc)
		Network:add_co_client(rpc)
		self:remove_connection_from_trash(rpc)
		self:remove_connection_from_soft_remove_peers(rpc)
	else
		peer = peer or self:peer_by_user_id(user_id)
		if not peer then
			print("[BaseNetworkSession:chk_send_connection_established] no peer yet", user_id)
			return
		end
		if not peer:rpc() then
			print("[BaseNetworkSession:chk_send_connection_established] no rpc yet", user_id)
			return
		end
	end
	print("[BaseNetworkSession:chk_send_connection_established] success", name or "", user_id or "", peer:id())
	if self._server_peer then
		self._server_peer:send("connection_established", peer:id())
	end
end

function BaseNetworkSession:_on_peer_removed(peer, peer_id, reason)
	logger("[BaseNetworkSession: _on_peer_removed] peer_id: " .. tostring(peer_id) .. " - " .. tostring(peer:name()) .. ", reason: " .. tostring(reason))
	if managers.player then
		managers.player:peer_dropped_out(peer)
	end
	if managers.menu_scene then
		managers.menu_scene:set_lobby_character_visible(peer_id, false)
	end
	local lobby_menu = managers.menu:get_menu("lobby_menu")
	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:remove_player_slot_by_peer_id(peer, reason)
	end
	local kit_menu = managers.menu:get_menu("kit_menu")
	if kit_menu and kit_menu.renderer:is_open() then
		kit_menu.renderer:remove_player_slot_by_peer_id(peer, reason)
	end
	if managers.menu_component then
		managers.menu_component:on_peer_removed(peer, reason)
	end
	if managers.chat then
		if reason == "left" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_left", {
				name = peer:name()
			}))
		elseif reason == "kicked" then
			logger("PEER IS GETTING KICKED~~~~~")
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_kicked", {
				name = peer:name()
			}))
		elseif reason == "auth_fail" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_failed", {
				name = peer:name()
			}))
		else
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_lost", {
				name = peer:name()
			}))
		end
	end
	managers.blackmarket:check_frog_1()
	print("Someone left", peer:name(), peer_id)
	local player_left = false
	local player_character
	if managers.criminals then
		player_character = managers.criminals:character_name_by_peer_id(peer_id)
		if player_character then
			player_left = true
			print("Player left")
		end
	end
	local member_unit = peer:unit()
	local member_downed = alive(member_unit) and member_unit:movement():downed()
	local member_health = 1
	local member_dead = managers.trade and managers.trade:is_peer_in_custody(peer_id)
	local hostages_killed = 0
	local respawn_penalty = 0
	if member_dead and player_character and managers.trade then
		hostages_killed = managers.trade:hostages_killed_by_name(player_character)
		respawn_penalty = managers.trade:respawn_delay_by_name(player_character)
	elseif alive(member_unit) then
		local criminal_record = managers.groupai:state():criminal_record(member_unit:key())
		if criminal_record then
			hostages_killed = criminal_record.hostages_killed
			respawn_penalty = criminal_record.respawn_penalty
		end
	end
	if player_left then
		local mugshot_id = managers.criminals:character_data_by_peer_id(peer_id).mugshot_id
		local mugshot_data = managers.hud:_get_mugshot_data(mugshot_id)
		member_health = mugshot_data and mugshot_data.health_amount or 1
	end
	local member_used_deployable = peer:used_deployable() or false
	local member_used_cable_ties = peer:used_cable_ties() or 0
	local member_used_body_bags = peer:used_body_bags()
	peer:unit_delete()
	local peer_ident = SystemInfo:platform() == Idstring("WIN32") and peer:user_id() or peer:name()
	if Network:is_server() then
		self:check_start_game_intro()
	end
	if Network:multiplayer() then
		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") or SystemInfo:platform() == Idstring("PS4") then
			managers.network.matchmake:on_peer_removed(peer)
		end
		if Network:is_client() then
			if player_left then
				managers.criminals:on_peer_left(peer_id)
				managers.criminals:remove_character_by_peer_id(peer_id)
				managers.trade:replace_player_with_ai(player_character, player_character)
			end
		elseif Network:is_server() then
			managers.network.matchmake:set_num_players(self:amount_of_players())
			Network:remove_client(peer:rpc())
			if player_left then
				managers.achievment:set_script_data("cant_touch_fail", true)
				managers.criminals:on_peer_left(peer_id)
				managers.criminals:remove_character_by_peer_id(peer_id)
				local unit = managers.groupai:state():spawn_one_teamAI(true, player_character)
				self._old_players[peer_ident] = {
					t = Application:time(),
					member_downed = member_downed,
					health = member_health,
					used_deployable = member_used_deployable,
					used_cable_ties = member_used_cable_ties,
					used_body_bags = member_used_body_bags,
					member_dead = member_dead,
					hostages_killed = hostages_killed,
					respawn_penalty = respawn_penalty
				}
				local trade_entry = managers.trade:replace_player_with_ai(player_character, player_character)
				if unit then
					if trade_entry then
						unit:brain():set_active(false)
						unit:base():set_slot(unit, 0)
						unit:base():unregister()
					elseif member_downed then
						unit:character_damage():force_bleedout()
					end
				else
					managers.trade:remove_from_trade(player_character)
				end
			end
			local deployed_equipment = World:find_units_quick("all", 14, 25, 26)
			for _, equipment in ipairs(deployed_equipment) do
				if equipment:base() and equipment:base().server_information then
					local server_information = equipment:base():server_information()
					if server_information and server_information.owner_peer_id == peer_id then
						equipment:set_slot(0)
					end
				end
			end
		else
			print("Tried to remove client when neither server or client")
			Application:stack_dump()
		end
	end
end

function BaseNetworkSession:on_peer_kicked(peer, peer_id, message_id)
	logger("[BaseNetworkSession: on_peer_kicked] Kicked!")
	if peer ~= self._local_peer then
		if message_id == 0 then
			local ident = self._ids_WIN32 == SystemInfo:platform() and peer:user_id() or peer:name()
			self._kicked_list[ident] = true
		end
		local reason = "kicked"
		if message_id == 1 then
			reason = "removed_dead"
		elseif message_id == 2 or message_id == 3 then
			reason = "auth_fail"
		end
		self:remove_peer(peer, peer_id, reason)
	else
		if message_id == 1 then
			Global.on_remove_peer_message = "dialog_remove_dead_peer"
		elseif message_id == 2 then
			Global.on_remove_peer_message = "dialog_authentication_fail"
		elseif message_id == 3 then
			Global.on_remove_peer_message = "dialog_authentication_host_fail"
		elseif message_id == 4 then
			Global.on_remove_peer_message = "dialog_cheated_host"
		end
		print("IVE BEEN KICKED!")
		if self:_local_peer_in_lobby() then
			print("KICKED FROM LOBBY")
			managers.menu:on_leave_lobby()
			managers.menu:show_peer_kicked_dialog()
		else
			print("KICKED FROM INGAME")
			managers.network.matchmake:destroy_game()
			managers.network.voice_chat:destroy_voice()
			if game_state_machine:current_state().on_kicked then
				game_state_machine:current_state():on_kicked()
			end
		end
	end
end

--below functions check for what might be network problem?
function BaseNetworkSession:on_network_stopped()
	logger("#############[BaseNetworkSession: on_network_stopped]")
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	--for k = 1, 4 do
	for k = 1, num_player_slots do
		self:on_drop_in_pause_request_received(k, nil, false)
		local peer = self:peer(k)
		if peer then
			peer:unit_delete()
		end
	end
	if self._local_peer then
		self:on_drop_in_pause_request_received(self._local_peer:id(), nil, false)
	end
end
function BaseNetworkSession:_has_client(peer)
	logger("#############[BaseNetworkSession: _has_client] num_peers(): " .. tostring(Network:clients():num_peers() - 1))
	for i = 0, Network:clients():num_peers() - 1 do
		if Network:clients():ip_at_index(i) == peer:ip() then
			return true
		end
	end
	return false
end
function BaseNetworkSession:on_peer_loading(peer, state)
	logger("@@@@@@@@@@@@[BaseNetworkSession: on_peer_loading]")
	cat_print("multiplayer_base", "[BaseNetworkSession:on_peer_loading]", inspect(peer), state)
	if Network:is_server() and not state then
		if not self:_has_client(peer) then
			Network:remove_co_client(peer:rpc())
			Network:add_client(peer:rpc())
		end
		if not NetworkManager.DROPIN_ENABLED then
			peer:on_sync_start()
			peer:chk_enable_queue()
			Network:drop_in(peer:rpc())
		end
	end
	if state and peer == self._server_peer then
		cat_print("multiplayer_base", "  SERVER STARTED LOADING", peer, peer:id())
		if self._local_peer:in_lobby() then
			local lobby_menu = managers.menu:get_menu("lobby_menu")
			if lobby_menu and lobby_menu.renderer:is_open() then
				lobby_menu.renderer:set_server_state("loading")
			end
			if managers.menu_scene then
				managers.menu_scene:set_server_loading()
			end
			if managers.menu_component then
				managers.menu_component:set_server_info_state("loading")
			end
		end
	end
end

function BaseNetworkSession:_get_peer_outfit_versions_str()
	logger("@@@@@@@@@@@@[BaseNetworkSession: _get_peer_outfit_versions_str]")
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	local outfit_versions_str = ""
	for peer_id = 1, num_player_slots do
		local peer
		if peer_id == self._local_peer:id() then
			peer = self._local_peer
		else
			peer = self._peers[peer_id]
		end
		if peer and peer:waiting_for_player_ready() then
			outfit_versions_str = outfit_versions_str .. tostring(peer_id) .. "-" .. peer:outfit_version() .. "."
		end
	end
	return outfit_versions_str
end

--delete all below
--[[
function BaseNetworkSession:on_load_complete(simulation)
	logger("[BaseNetworkSession: on_load_complete] simulation: " .. tostring(simulation))
	print("[BaseNetworkSession:on_load_complete]")
	if not simulation then
		self._local_peer:set_loading(false)
		for peer_id, peer in pairs(self._peers) do
			if peer:ip_verified() then
				peer:send("set_loading_state", false, self._load_counter)
			end
		end
	end
	if not setup.IS_START_MENU then
		if SystemInfo:platform() == Idstring("PS3") then
			PSN:set_online_callback(callback(self, self, "ps3_disconnect"))
		elseif SystemInfo:platform() == Idstring("PS4") then
			PSN:set_online_callback(callback(self, self, "ps4_disconnect"))
		end
	end
end
]]

function BaseNetworkSession:on_set_member_ready(peer_id, ready, state_changed, from_network)
	logger("[BaseNetworkSession :on_set_member_ready] peer_id: " .. tostring(peer_id) .. " - " .. tostring(ready) .. " - " .. tostring(state_changed))
	local peer = self:peer(peer_id)
	local kit_menu = managers.menu:get_menu("kit_menu")
	if kit_menu and kit_menu.renderer:is_open() then
		if ready then
			logger("[BaseNetworkSession :on_set_member_ready] slot_ready ")
			kit_menu.renderer:set_slot_ready(peer, peer_id)
		else
			logger("[BaseNetworkSession :on_set_member_ready] slot_not_ready ")
			kit_menu.renderer:set_slot_not_ready(peer, peer_id)
		end
	end
end

function BaseNetworkSession:spawn_players(is_drop_in)
	logger("[BaseNetworkSession :spawn_players] is_drop_in: " .. tostring(is_drop_in))
	if not managers.network:has_spawn_points() then
		return
	end
	if not self._spawn_point_beanbag then
		self:_create_spawn_point_beanbag()
	end
	logger("[BaseNetworkSession :spawn_players] is_server()")
	if Network:is_server() then
		if not self._local_peer then
			return
		end
		local id = self:_get_next_spawn_point_id()
		logger("[BaseNetworkSession :spawn_players] is_server() - iteration")
		for _, peer in pairs(self._peers) do
			logger("[BaseNetworkSession :spawn_players] is_server() - iteration, peer: " .. tostring(peer:id()))
			local character = peer:character()
			if character ~= "random" then
				peer:spawn_unit(self:_get_next_spawn_point_id(), is_drop_in, character)
			end
		end
		local local_character = self._local_peer:character()
		logger("[BaseNetworkSession :spawn_players] is_server() - spawn_unit()")
		self._local_peer:spawn_unit(id, false, local_character ~= "random" and local_character)
		logger("[BaseNetworkSession :spawn_players] is_server() - iteration2")
		for _, peer in pairs(self._peers) do
			logger("[BaseNetworkSession :spawn_players] is_server() - iteration2, peer: " .. tostring(peer:id()))
			local character = peer:character()
			if character == "random" then
				peer:spawn_unit(self:_get_next_spawn_point_id(), is_drop_in)
			end
		end
		logger("[BaseNetworkSession :spawn_players] is_server() - set_game_started()")
		self:set_game_started(true)
	end
	managers.groupai:state():fill_criminal_team_with_AI(is_drop_in)
end


function BaseNetworkSession:_update_peer_ready_gui(peer)
	logger("!!!!!![BaseNetworkSession :_update_peer_ready_gui] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", ready?: " .. tostring(peer:waiting_for_player_ready()))
	if not peer:synched() or not peer:is_streaming_complete() then
		logger("!!!!!![BaseNetworkSession :_update_peer_ready_gui] fail, peer:synched(): " .. tostring(peer:synched()) .. ", streaming_complete(): " .. tostring(peer:is_streaming_complete()))
		return
	end
	local kit_menu = managers.menu:get_menu("kit_menu")
	if kit_menu and kit_menu.renderer:is_open() then
		if peer:waiting_for_player_ready() then
			kit_menu.renderer:set_slot_ready(peer, peer:id())
		else
			kit_menu.renderer:set_slot_not_ready(peer, peer:id())
		end
	end
end
