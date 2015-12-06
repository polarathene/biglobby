function HostStateInGame:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	--[[local num_player_slots = 3--BigLobbyGlobals:num_player_slots() - 1
	if peer_name == "Pola" then
		num_player_slots =  BigLobbyGlobals:num_player_slots() - 1
	end]]

	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1

	logger("[HostStateInGame: on_join_request_received] PEER: " .. tostring(peer_name) .. ", gversion: " .. tostring(gameversion))
	--print("[HostStateInGame:on_join_request_received]", data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, sender:ip_at_index(0))
	local my_user_id = data.local_peer:user_id() or ""
	if SystemInfo:platform() == Idstring("WIN32") then
		logger("THIS GOT TRIGGERED!")
		peer_name = peer_name or managers.network.account:username_by_id(sender:ip_at_index(0)) or peer_name
	end
	logger("[HostStateInGame: on_join_request_received] Still here?  PEER: " .. tostring(peer_name))
	if self:_has_peer_left_PSN(peer_name) then
		logger("[HostStateInGame: on_join_request_received] What? This shouldn't happen")
		--print("this CLIENT has left us from PSN, ignore his request", peer_name)
		return
	elseif not self:_is_in_server_state() then
		logger("[HostStateInGame: on_join_request_received] is_in_server_state")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	elseif not NetworkManager.DROPIN_ENABLED or not Global.game_settings.drop_in_allowed then
		logger("[HostStateInGame: on_join_request_received] dropin_enabled/allowed is false!")
		self:_send_request_denied(sender, 3, my_user_id)
		return
	elseif managers.groupai and not managers.groupai:state():chk_allow_drop_in() then
		logger("[HostStateInGame: on_join_request_received] No AI!")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	elseif self:_is_kicked(data, peer_name, sender) then
		logger("[HostStateInGame: on_join_request_received] SOMEBODY IS KICKED!")
		--print("YOU ARE IN MY KICKED LIST", peer_name)
		self:_send_request_denied(sender, 2, my_user_id)
		return
	elseif peer_level < Global.game_settings.reputation_permission then
		logger("[HostStateInGame: on_join_request_received] Level too low!")
		self:_send_request_denied(sender, 6, my_user_id)
		return
	elseif gameversion ~= -1 and gameversion ~= managers.network.matchmake.GAMEVERSION then
		logger("[HostStateInGame: on_join_request_received] Bad gameversion!")
		self:_send_request_denied(sender, 7, my_user_id)
		return
	elseif data.wants_to_load_level then
		logger("[HostStateInGame: on_join_request_received] want_to_load_level")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	elseif not managers.network:session():local_peer() then
		logger("[HostStateInGame: on_join_request_received] Not local peer!")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	end
	logger("[HostStateInGame: on_join_request_received] Made it this far!")
	local old_peer = data.session:chk_peer_already_in(sender)
	if old_peer then
		if join_attempt_identifier ~= old_peer:join_attempt_identifier() then
			data.session:remove_peer(old_peer, old_peer:id(), "lost")
			self:_send_request_denied(sender, 0, my_user_id)
		end
		logger("[HostStateInGame: on_join_request_received] Oh no!, Peer ID: " .. tostring(old_peer:id()) .. " - Peer Name: " .. tostring(old_peer:name()))
		return
	end
	logger("PEERS TABLE SIZE: " .. tostring(table.size(data.peers)) .. ", num_slots: " .. tostring(num_player_slots))
	if num_player_slots <= table.size(data.peers) then
		logger("[HostStateInGame: on_join_request_received] server is full, num_slots: " .. tostring(num_player_slots))

		self:_send_request_denied(sender, 5, my_user_id)
		return
	end
	local character = managers.network:session():check_peer_preferred_character(client_preferred_character)
	local xnaddr = ""
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		xnaddr = managers.network.matchmake:external_address(sender)
	end
	logger("[HostStateInGame: on_join_request_received] Add PEER")
	local new_peer_id, new_peer
	peer_name = peer_name
	--character = "bonnie" --can delete not required? forces all player to be bonnie, no masks show
	new_peer_id, new_peer = data.session:add_peer(peer_name, nil, false, false, false, nil, character, sender:ip_at_index(0), xuid, xnaddr)
	logger("[HostStateInGame: on_join_request_received] Add PEER called/finished")
	if not new_peer_id then
		--print("there was no clean peer_id")
		logger("[HostStateInGame: on_join_request_received] there was no clean peer_id")
		self:_send_request_denied(sender, 0, my_user_id)
		return
	end
	logger("[HostStateInGame: on_join_request_received] checkpoint")
	new_peer:set_dlcs(dlcs)
	new_peer:set_xuid(xuid)
	new_peer:set_join_attempt_identifier(join_attempt_identifier)
	local new_peer_rpc
	if managers.network:protocol_type() == "TCP_IP" then
		new_peer_rpc = managers.network:session():resolve_new_peer_rpc(new_peer, sender)
	else
		new_peer_rpc = sender
	end
	logger("[HostStateInGame: on_join_request_received] checkpoint 2")
	new_peer:set_rpc(new_peer_rpc)
	new_peer:set_ip_verified(true)
	Network:add_co_client(new_peer_rpc)
	logger("[HostStateInGame: on_join_request_received] Verifying")
	if not new_peer:begin_ticket_session(auth_ticket) then--and not peer_name=="Gary" then
		logger("[HostStateInGame: on_join_request_received] Failed Verification")
		data.session:remove_peer(new_peer, new_peer:id(), "auth_fail")
		self:_send_request_denied(sender, 8, my_user_id)
		return
	end
	logger("[HostStateInGame: on_join_request_received] Verified")
	local ticket = new_peer:create_ticket()
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
	--Only being used to get the ticket now
	new_peer:send("join_request_reply", 1, new_peer_id, character, level_index, difficulty_index, 2, data.local_peer:character(), my_user_id, Global.game_settings.mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, server_xuid, ticket)
	--BLT Network message used instead, proper peerID values are being changed to 4 for peers > 4, this works around that bug
	logger("[HostStateInGame: on_join_request_received] Storing peers data as JSON")
	local xdata = json.encode({ "join_request_reply", 1, new_peer_id, character, level_index, difficulty_index, 2, data.local_peer:character(), my_user_id, Global.game_settings.mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, server_xuid})--, ticket })
	BigLobbyGlobals:jdata(new_peer_id, xdata)
	--local Net = _G.LuaNetworking
	--Net:SendToPeer(new_peer:id(), "join_request_reply", xdata)
	self:on_handshake_confirmation(data, new_peer, 1)

	-- new_peer:send("set_loading_state", false, data.session:load_counter())
	-- if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
	-- 	new_peer:send("request_player_name_reply", managers.network:session():local_peer():name())
	-- end
	-- managers.vote:sync_server_kick_option(new_peer)
	-- data.session:send_ok_to_load_level()
	-- self:on_handshake_confirmation(data, new_peer, 1)
	-- logger("[HostStateInGame: on_join_request_received] DONE!!!!" .. tostring(peer_name))
end--[[
function HostStateInGame:on_peer_finished_loading(data, peer)
	logger("[HostStateInGame: on_peer_finished_loading]")
	self:_introduce_new_peer_to_old_peers(data, peer, false, peer:name(), peer:character(), "remove", peer:xuid(), peer:xnaddr())
	self:_introduce_old_peers_to_new_peer(data, peer)
	if data.game_started then
		peer:send("set_dropin")
	end
end
function HostStateInGame:is_joinable(data)
	logger("[HostStateInGame: is_joinable]")
	return not data.wants_to_load_level
end]]
