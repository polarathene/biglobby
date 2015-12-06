function HostStateInLobby:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	--[[local num_player_slots = 3--BigLobbyGlobals:num_player_slots() - 1
	if peer_name == "Pola" then
		num_player_slots =  BigLobbyGlobals:num_player_slots() - 1
	end]]

	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1

	logger("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	logger("[HostStateInLobby: on_join_request_received] PEER: " .. tostring(peer_name))
	print("HostStateInLobby:on_join_request_received peer_level", peer_level, join_attempt_identifier, gameversion)
	if SystemInfo:platform() == Idstring("WIN32") then
		peer_name = peer_name or managers.network.account:username_by_id(sender:ip_at_index(0))
		logger("[HostStateInLobby: on_join_request_received] Assigning Peer Name:" .. tostring(peer_name))
	end
	if self:_has_peer_left_PSN(peer_name) then
		print("this CLIENT has left us from PSN, ignore his request", peer_name)
		return
	end
	local my_user_id = data.local_peer:user_id() or ""
	if self:_is_kicked(data, peer_name, sender) then
		print("YOU ARE IN MY KICKED LIST", peer_name)
		logger("[HostStateInLobby: on_join_request_received] You're kicked mate")
		self:_send_request_denied(sender, 2, my_user_id)
		return
	end
	if peer_level < Global.game_settings.reputation_permission then
		logger("[HostStateInLobby: on_join_request_received] Level too low!")
		self:_send_request_denied(sender, 6, my_user_id)
		return
	end
	if gameversion ~= -1 and gameversion ~= managers.network.matchmake.GAMEVERSION then
		logger("[HostStateInLobby: on_join_request_received] Bad game version!")
		self:_send_request_denied(sender, 7, my_user_id)
		return
	end
	if data.wants_to_load_level then
		logger("[HostStateInLobby: on_join_request_received] want_to_load_level")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	end
	if not managers.network:session():local_peer() then
		logger("[HostStateInLobby: on_join_request_received] local_peer")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	end
	logger("[HostStateInLobby: on_join_request_received] Check for old_peer")
	local old_peer = data.session:chk_peer_already_in(sender)
	if old_peer then --and not peer_name=="Gary" then
		if join_attempt_identifier ~= old_peer:join_attempt_identifier() then
			data.session:remove_peer(old_peer, old_peer:id(), "lost")
			self:_send_request_denied(sender, 0, my_user_id)
		end
		logger("[HostStateInGame: on_join_request_received] Oh no!, Peer ID: " .. tostring(old_peer:id()) .. " - Peer Name: " .. tostring(old_peer:name()))
		return
	end
	if table.size(data.peers) >= num_player_slots then
		logger("[HostStateInLobby: on_join_request_received] Server is full")
		print("server is full")
		self:_send_request_denied(sender, 5, my_user_id)
		return
	end
	print("[HostStateInLobby:on_join_request_received] new peer accepted", peer_name)
	local character = managers.network:session():check_peer_preferred_character(client_preferred_character)
	local xnaddr = ""
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		xnaddr = managers.network.matchmake:external_address(sender)
	end
	local new_peer_id, new_peer
	new_peer_id, new_peer = data.session:add_peer(peer_name, nil, true, false, false, nil, character, sender:ip_at_index(0), xuid, xnaddr)
	if not new_peer_id then
		print("there was no clean peer_id")
		logger("[HostStateInLobby: on_join_request_received] No Clean Peer ID!")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	end
	new_peer:set_dlcs(dlcs)
	new_peer:set_xuid(xuid)
	new_peer:set_join_attempt_identifier(join_attempt_identifier)
	local new_peer_rpc
	if managers.network:protocol_type() == "TCP_IP" then
		new_peer_rpc = managers.network:session():resolve_new_peer_rpc(new_peer, sender)
	else
		new_peer_rpc = sender
	end
	new_peer:set_rpc(new_peer_rpc)
	new_peer:set_ip_verified(true)
	Network:add_client(new_peer:rpc())
	logger("[HostStateInLobby: on_join_request_received] Verifying")
	if not new_peer:begin_ticket_session(auth_ticket) and not peer_name=="Gary" then
		logger("[HostStateInLobby: on_join_request_received] Verification Failed")
		data.session:remove_peer(new_peer, new_peer:id(), "auth_fail")
		self:_send_request_denied(sender, 8, my_user_id)
		return
	end
	logger("[HostStateInLobby: on_join_request_received] Verified")
	local ticket = new_peer:create_ticket()
	new_peer:set_entering_lobby(true)
	local level_index = tweak_data.levels:get_index_from_level_id(Global.game_settings.level_id)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local job_id_index = 0
	local job_stage = 0
	local alternative_job_stage = 0
	local interupt_job_stage_level_index = 0
	if managers.job:has_active_job() then
		job_id_index = tweak_data.narrative:get_index_from_job_id(managers.job:current_job_id())
		job_stage = managers.job:current_stage()
		alternative_job_stage = managers.job:alternative_stage() or 0
		local interupt_stage_level = managers.job:interupt_stage()
		interupt_job_stage_level_index = interupt_stage_level and tweak_data.levels:get_index_from_level_id(interupt_stage_level) or 0
	end
	local server_xuid = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and managers.network.account:player_id() or ""
	new_peer:send("join_request_reply", 1, new_peer_id, character, level_index, difficulty_index, 1, data.local_peer:character(), my_user_id, Global.game_settings.mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, server_xuid, ticket)
	new_peer:send("set_loading_state", false, data.session:load_counter())
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		new_peer:send("request_player_name_reply", managers.network:session():local_peer():name())
	end
	managers.vote:sync_server_kick_option(new_peer)
	self:_introduce_new_peer_to_old_peers(data, new_peer, false, peer_name, new_peer:character(), "remove", new_peer:xuid(), new_peer:xnaddr())
	self:_introduce_old_peers_to_new_peer(data, new_peer)
	self:on_handshake_confirmation(data, new_peer, 1)
	managers.network:session():local_peer():sync_lobby_data(new_peer)
	logger("[HostStateInLobby: on_join_request_received] Done")
end
