--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function logger(content, use_chat)
	if log_data then
		if not content then return end
		if use_chat then
			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
		end
		-- if BigLobbyGlobals:Hook() == "pd2hook" then
		-- 	io.stdout:write(content .. "\n")
		-- else
			log(content)
		-- end
	end
end

--Debugging peer_id 4 for peer 5
-- function ClientNetworkSession:on_join_request_reply(reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
-- 	my_peer_id, my_character = unpack(json.decode(my_character))
-- 	logger("[ClientNetworkSession :on_join_request_reply] My Peer ID: " .. tostring(my_peer_id) .. ", my character: " .. tostring(my_character))
-- 	-- if not self._server_peer:begin_ticket_session(auth_ticket) then
-- 	-- 	logger("[ClientNetworkSession :on_join_request_reply] AUTH_HOST_FAILED")
-- 	-- 	self:remove_peer(self._server_peer, 1)
-- 	-- 	cb("AUTH_HOST_FAILED")
-- 	-- 	return
-- 	-- end
-- 	-- logger("[ClientNetworkSession :on_join_request_reply] AUTH_HOST_OK")
--
--
-- 	if not self._server_peer or not self._cb_find_game then
-- 		return
-- 	end
-- 	if self._server_peer:ip() and sender:ip_at_index(0) ~= self._server_peer:ip() then
-- 		--print("[BigLobbyGlobals-ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:ip(), sender:ip_at_index(0))
-- 		return
-- 	end
-- 	self._last_join_request_t = nil
-- 	if SystemInfo:platform() == self._ids_WIN32 then
-- 		if self._server_peer:user_id() and user_id ~= self._server_peer:user_id() then
-- 			--print("[BigLobbyGlobals-ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:user_id(), user_id)
-- 			return
-- 		else
-- 			if sender:protocol_at_index(0) == "STEAM" then
-- 				self._server_protocol = "STEAM"
-- 			else
-- 				self._server_protocol = "TCP_IP"
-- 			end
-- 			print("self._server_protocol", self._server_protocol)
-- 			self._server_peer:set_rpc(sender)
-- 			self._server_peer:set_ip_verified(true)
-- 			Network:set_client(sender)
-- 		end
-- 	else
-- 		self._server_protocol = "TCP_IP"
-- 		self._server_peer:set_rpc(sender)
-- 		self._server_peer:set_ip_verified(true)
-- 		Network:set_client(sender)
-- 	end
--
--
-- 	self:register_local_peer(my_peer_id) --may be bad to set it here, not sure. Could alternative just use `self._local_peer:set_id(id)`
-- 	BigLobbyGlobals:auth_ticket(auth_ticket)
-- 	--BigLobbyGlobals:sender(sender) --not needed anymore
-- 	local Net = _G.LuaNetworking
-- 	logger("[ClientNetworkSession :on_join_request_reply] Sending request for JSON to host")
-- 	Net:SendToPeer(1, "request_json_data", "nothing v" .. tostring(BigLobbyGlobals:version()))
--
-- 	--[[print("[ClientNetworkSession:on_join_request_reply] ", self._server_peer and self._server_peer:user_id(), user_id, sender:ip_at_index(0), sender:protocol_at_index(0))
-- 	if not self._server_peer or not self._cb_find_game then
-- 		return
-- 	end
-- 	if self._server_peer:ip() and sender:ip_at_index(0) ~= self._server_peer:ip() then
-- 		print("[ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:ip(), sender:ip_at_index(0))
-- 		return
-- 	end
-- 	self._last_join_request_t = nil
-- 	if SystemInfo:platform() == self._ids_WIN32 then
-- 		if self._server_peer:user_id() and user_id ~= self._server_peer:user_id() then
-- 			print("[ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:user_id(), user_id)
-- 			return
-- 		else
-- 			if sender:protocol_at_index(0) == "STEAM" then
-- 				self._server_protocol = "STEAM"
-- 			else
-- 				self._server_protocol = "TCP_IP"
-- 			end
-- 			print("self._server_protocol", self._server_protocol)
-- 			self._server_peer:set_rpc(sender)
-- 			self._server_peer:set_ip_verified(true)
-- 			Network:set_client(sender)
-- 		end
-- 	else
-- 		self._server_protocol = "TCP_IP"
-- 		self._server_peer:set_rpc(sender)
-- 		self._server_peer:set_ip_verified(true)
-- 		Network:set_client(sender)
-- 	end
-- 	local cb = self._cb_find_game
-- 	self._cb_find_game = nil
-- 	if reply == 1 then
-- 		self._host_sanity_send_t = TimerManager:wall():time() + self.HOST_SANITY_CHECK_INTERVAL
-- 		Global.game_settings.level_id = tweak_data.levels:get_level_name_from_index(level_index)
-- 		Global.game_settings.difficulty = tweak_data:index_to_difficulty(difficulty_index)
-- 		Global.game_settings.mission = mission
-- 		self._server_peer:set_character(server_character)
-- 		self._server_peer:set_xuid(xuid)
-- 		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
-- 			local xnaddr = managers.network.matchmake:external_address(self._server_peer:rpc())
-- 			self._server_peer:set_xnaddr(xnaddr)
-- 			managers.network.matchmake:on_peer_added(self._server_peer)
-- 		elseif SystemInfo:platform() == Idstring("PS4") then
-- 			managers.network.matchmake:on_peer_added(self._server_peer)
-- 		end
-- 		--LOCAL PEER ASSIGNED PEER ID
-- 		self:register_local_peer(my_peer_id)
-- 		self._local_peer:set_character(my_character)
-- 		self._server_peer:set_id(1)
-- 		if not self._server_peer:begin_ticket_session(auth_ticket) then
-- 			self:remove_peer(self._server_peer, 1)
-- 			cb("AUTH_HOST_FAILED")
-- 			return
-- 		end
-- 		self._server_peer:set_in_lobby_soft(state_index == 1)
-- 		self._server_peer:set_synched_soft(state_index ~= 1)
-- 		if SystemInfo:platform() == Idstring("PS3") then
-- 		end
-- 		self:_chk_send_proactive_outfit_loaded()
-- 		if job_id_index ~= 0 then
-- 			local job_id = tweak_data.narrative:get_job_name_from_index(job_id_index)
-- 			managers.job:activate_job(job_id, job_stage)
-- 			if alternative_job_stage ~= 0 then
-- 				managers.job:synced_alternative_stage(alternative_job_stage)
-- 			end
-- 			if interupt_job_stage_level_index ~= 0 then
-- 				local interupt_level = tweak_data.levels:get_level_name_from_index(interupt_job_stage_level_index)
-- 				managers.job:synced_interupt_stage(interupt_level)
-- 			end
-- 			Global.game_settings.world_setting = managers.job:current_world_setting()
-- 			self._server_peer:verify_job(job_id)
-- 		end
-- 		cb(state_index == 1 and "JOINED_LOBBY" or "JOINED_GAME", level_index, difficulty_index, state_index)
-- 	elseif reply == 2 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("KICKED")
-- 	elseif reply == 0 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("FAILED_CONNECT")
-- 	elseif reply == 3 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("GAME_STARTED")
-- 	elseif reply == 4 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("DO_NOT_OWN_HEIST")
-- 	elseif reply == 5 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("GAME_FULL")
-- 	elseif reply == 6 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("LOW_LEVEL")
-- 	elseif reply == 7 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("WRONG_VERSION")
-- 	elseif reply == 8 then
-- 		self:remove_peer(self._server_peer, 1)
-- 		cb("AUTH_FAILED")
-- 	end]]
-- end

function ClientNetworkSession:on_join_request_reply(reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	if my_character then my_peer_id, my_character = unpack(json.decode(my_character)) end



	print("[ClientNetworkSession:on_join_request_reply] ", self._server_peer and self._server_peer:user_id(), user_id, sender:ip_at_index(0), sender:protocol_at_index(0))
	if not self._server_peer or not self._cb_find_game then
		return
	end
	if self._server_peer:ip() and sender:ip_at_index(0) ~= self._server_peer:ip() then
		print("[ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:ip(), sender:ip_at_index(0))
		return
	end
	self._last_join_request_t = nil
	if SystemInfo:platform() == self._ids_WIN32 then
		if self._server_peer:user_id() and user_id ~= self._server_peer:user_id() then
			print("[ClientNetworkSession:on_join_request_reply] wrong host replied", self._server_peer:user_id(), user_id)
			return
		else
			if sender:protocol_at_index(0) == "STEAM" then
				self._server_protocol = "STEAM"
			else
				self._server_protocol = "TCP_IP"
			end
			print("self._server_protocol", self._server_protocol)
			self._server_peer:set_rpc(sender)
			self._server_peer:set_ip_verified(true)
			Network:set_client(sender)
		end
	else
		self._server_protocol = "TCP_IP"
		self._server_peer:set_rpc(sender)
		self._server_peer:set_ip_verified(true)
		Network:set_client(sender)
	end
	local cb = self._cb_find_game
	self._cb_find_game = nil
	if reply == 1 then
		self._host_sanity_send_t = TimerManager:wall():time() + self.HOST_SANITY_CHECK_INTERVAL
		Global.game_settings.level_id = tweak_data.levels:get_level_name_from_index(level_index)
		Global.game_settings.difficulty = tweak_data:index_to_difficulty(difficulty_index)
		Global.game_settings.mission = mission
		self._server_peer:set_character(server_character)
		self._server_peer:set_xuid(xuid)
		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
			local xnaddr = managers.network.matchmake:external_address(self._server_peer:rpc())
			self._server_peer:set_xnaddr(xnaddr)
			managers.network.matchmake:on_peer_added(self._server_peer)
		elseif SystemInfo:platform() == Idstring("PS4") then
			managers.network.matchmake:on_peer_added(self._server_peer)
		end
		self:register_local_peer(my_peer_id)
		self._local_peer:set_character(my_character)
		self._server_peer:set_id(1)
		if not self._server_peer:begin_ticket_session(auth_ticket) then
			self:remove_peer(self._server_peer, 1)
			cb("AUTH_HOST_FAILED")
			return
		end
		self._server_peer:set_in_lobby_soft(state_index == 1)
		self._server_peer:set_synched_soft(state_index ~= 1)
		if SystemInfo:platform() == Idstring("PS3") then
		end
		self:_chk_send_proactive_outfit_loaded()
		if job_id_index ~= 0 then
			local job_id = tweak_data.narrative:get_job_name_from_index(job_id_index)
			managers.job:activate_job(job_id, job_stage)
			if alternative_job_stage ~= 0 then
				managers.job:synced_alternative_stage(alternative_job_stage)
			end
			if interupt_job_stage_level_index ~= 0 then
				local interupt_level = tweak_data.levels:get_level_name_from_index(interupt_job_stage_level_index)
				managers.job:synced_interupt_stage(interupt_level)
			end
			Global.game_settings.world_setting = managers.job:current_world_setting()
			self._server_peer:verify_job(job_id)
		end
		cb(state_index == 1 and "JOINED_LOBBY" or "JOINED_GAME", level_index, difficulty_index, state_index)
	elseif reply == 2 then
		self:remove_peer(self._server_peer, 1)
		cb("KICKED")
	elseif reply == 0 then
		self:remove_peer(self._server_peer, 1)
		cb("FAILED_CONNECT")
	elseif reply == 3 then
		self:remove_peer(self._server_peer, 1)
		cb("GAME_STARTED")
	elseif reply == 4 then
		self:remove_peer(self._server_peer, 1)
		cb("DO_NOT_OWN_HEIST")
	elseif reply == 5 then
		self:remove_peer(self._server_peer, 1)
		cb("GAME_FULL")
	elseif reply == 6 then
		self:remove_peer(self._server_peer, 1)
		cb("LOW_LEVEL")
	elseif reply == 7 then
		self:remove_peer(self._server_peer, 1)
		cb("WRONG_VERSION")
	elseif reply == 8 then
		self:remove_peer(self._server_peer, 1)
		cb("AUTH_FAILED")
	end
end

function ClientNetworkSession:peer_handshake(name, peer_id, peer_user_id, in_lobby, loading, synched, character, mask_set, xuid, xnaddr)
	logger("[ClientNetworkSession :peer_handshake] name: " .. tostring(name) .. ", peer_id: " .. tostring(peer_id))
	print("ClientNetworkSession:peer_handshake", name, peer_id, peer_user_id, in_lobby, loading, synched, character, mask_set, xuid, xnaddr)
	if self._peers[peer_id] then
		logger("[ClientNetworkSession :peer_handshake] ALREADY HAVE PEER")
		print("ALREADY HAD PEER returns here")
		local peer = self._peers[peer_id]
		if peer:ip_verified() then
			logger("[ClientNetworkSession :peer_handshake] PEER IP VERIFIED")
			self._server_peer:send("connection_established", peer_id)
		end
		return
	end
	local rpc
	if self._server_protocol == "STEAM" then
		rpc = Network:handshake(peer_user_id, nil, "STEAM")
		Network:add_co_client(rpc)
	end
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		local ip = managers.network.matchmake:internal_address(xnaddr)
		rpc = Network:handshake(ip, managers.network.DEFAULT_PORT, "TCP_IP")
		Network:add_co_client(rpc)
	end
	if SystemInfo:platform() ~= self._ids_WIN32 or not peer_user_id then
		peer_user_id = false
	end
	if SystemInfo:platform() == Idstring("WIN32") then
		name = managers.network.account:username_by_id(peer_user_id)
	end
	logger("[ClientNetworkSession :peer_handshake] Adding Peer")
	local id, peer = self:add_peer(name, rpc, in_lobby, loading, synched, peer_id, character, peer_user_id, xuid, xnaddr)
	cat_print("multiplayer_base", "[ClientNetworkSession:peer_handshake]", name, peer_user_id, loading, synched, id, inspect(peer))
	local check_peer = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and peer or nil
	self:chk_send_connection_established(name, peer_user_id, check_peer)
	if managers.trade then
		logger("[ClientNetworkSession :peer_handshake] Handshake Complete? ")
		managers.trade:handshake_complete(peer_id)
	end
end

function ClientNetworkSession:on_peer_synched(peer_id)
	logger("[ClientNetworkSession :on_peer_synched] id: " .. tostring(peer_id))
	local peer = self._peers[peer_id]

	if not peer then
		logger("[ClientNetworkSession :on_peer_synched] Unknown peer")
		cat_error("multiplayer_base", "[ClientNetworkSession:on_peer_synched] Unknown Peer:", peer_id)
		return
	end
	logger("[ClientNetworkSession :on_peer_synched] peer: " .. tostring(peer:name()))
	peer:set_loading(false)
	peer:set_synched(true)
	logger("[ClientNetworkSession :on_peer_synched] Peer sync complete!")
	self:on_peer_sync_complete(peer, peer_id)
end

function ClientNetworkSession:on_peer_requested_info(peer_id)
	local other_peer = self._peers[peer_id]
	if not other_peer then
		return
	end
	logger("[ClientNetworkSession :on_peer_requested_info] I am peer: " .. tostring(self._local_peer:id()) .. " - " .. tostring(self._local_peer:name()))
	logger("[ClientNetworkSession :on_peer_requested_info] for peer: " .. tostring(other_peer:id()) .. " - " .. tostring(other_peer:name()))
	other_peer:set_ip_verified(true)
	self._local_peer:sync_lobby_data(other_peer)
	self._local_peer:sync_data(other_peer)
	other_peer:send("set_loading_state", self._local_peer:loading(), self._load_counter or 1)
	other_peer:send("peer_exchange_info", self._local_peer:id())
end


function ClientNetworkSession:on_peer_save_received(event, event_data)
	log("[ClientNetworkSession :on_peer_save_received]")
	if managers.network:stopping() then
		return
	end
	local packet_index = event_data.index
	local total_nr_packets = event_data.total
	print("[ClientNetworkSession:on_peer_save_received]", packet_index, "/", total_nr_packets)
	local kit_menu = managers.menu:get_menu("kit_menu")
	if not kit_menu or not kit_menu.renderer:is_open() then
		return
	end
	if packet_index == total_nr_packets then
		local is_ready = self._local_peer:waiting_for_player_ready()
		if is_ready then
			kit_menu.renderer:set_slot_ready(self._local_peer, self._local_peer:id())
		else
			kit_menu.renderer:set_slot_not_ready(self._local_peer, self._local_peer:id())
		end
		self._local_peer:set_synched(true)
	else
		local progress_ratio = packet_index / total_nr_packets
		local progress_percentage = math.floor(math.clamp(progress_ratio * 100, 0, 100))
		managers.menu:get_menu("kit_menu").renderer:set_dropin_progress(self._local_peer:id(), progress_percentage, "join")
	end
end


function ClientNetworkSession:chk_send_outfit_loading_status()
	log("[ClientNetworkSession :chk_send_outfit_loading_status] check_me2")

	print("[ClientNetworkSession:chk_send_outfit_loading_status]\n", inspect(self._notify_host_when_outfits_loaded), "\n", "self:_get_peer_outfit_versions_str()", self:_get_peer_outfit_versions_str())
	if self._notify_host_when_outfits_loaded and self._notify_host_when_outfits_loaded.outfit_versions_str == self:_get_peer_outfit_versions_str() and self:are_all_peer_assets_loaded() then
		print("answering to request")
		log("[ClientNetworkSession :chk_send_outfit_loading_status] check_me2 :: local peer_id: " .. tostring(self._local_peer:id()) .. "? answering to request")
		self:send_to_host("set_member_ready", self._local_peer:id(), self._notify_host_when_outfits_loaded.request_id, 3, self._notify_host_when_outfits_loaded.outfit_versions_str)
		self._notify_host_when_outfits_loaded = nil
		return true
	end
end
function ClientNetworkSession:notify_host_when_outfits_loaded(request_id, outfit_versions_str)
	log("[ClientNetworkSession :notify_host_when_outfits_loaded] check_me2.1 :: request_id: " .. tostring(request_id) .. ", outfit_str: " .. tostring(outfit_versions_str))
	print("[ClientNetworkSession:notify_host_when outfits_loaded] request_id", request_id)
	self._notify_host_when_outfits_loaded = {request_id = request_id, outfit_versions_str = outfit_versions_str}
	self:chk_send_outfit_loading_status()
end
function ClientNetworkSession:on_peer_outfit_loaded(peer)
	log("[ClientNetworkSession :on_peer_outfit_loaded] check_me2.2 :: peer: " .. tostring(peer:id()) .. ", peer_id: " .. tostring(peer:id()))
	ClientNetworkSession.super.on_peer_outfit_loaded(self, peer)
	self:_chk_send_proactive_outfit_loaded()
end
function ClientNetworkSession:_chk_send_proactive_outfit_loaded()
	log("[ClientNetworkSession :_chk_send_proactive_outfit_loaded] check_me2.3")
	if not self:server_peer() or not self:server_peer():ip_verified() or self:server_peer():id() == 0 or self._local_peer:id() == 0 then
		log("[ClientNetworkSession :_chk_send_proactive_outfit_loaded] check_me2.3 -- SUM TING WONG")
		return
	end
	local sent = self:chk_send_outfit_loading_status()
	if not sent and self:are_all_peer_assets_loaded() then
		log("[ClientNetworkSession :_chk_send_proactive_outfit_loaded] check_me2.3 :: SENDING, local peer_id: " .. tostring(self._local_peer:id()))
		print("[ClientNetworkSession:_chk_send_proactive_outfit_loaded] sending outfit_ready proactively")
		self:send_to_host("set_member_ready", self._local_peer:id(), 0, 3, "proactive")
	end
end
function ClientNetworkSession:on_set_member_ready(peer_id, ready, state_changed, from_network)
	log("[ClientNetworkSession :on_set_member_ready] check_me2.4 :: peer_id: " .. tostring(peer_id) .. ", state_changed: " .. tostring(state_changed) .. ", from_network: " .. tostring(from_network))
	ClientNetworkSession.super.on_set_member_ready(self, peer_id, ready, state_changed, from_network)
	if from_network and ready then
		self:chk_send_outfit_loading_status()
	end
end
