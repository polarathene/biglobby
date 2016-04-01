function ClientNetworkSession:on_join_request_reply(reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, num_players, sender)
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
        if num_players then
            Global.player_num = num_players
            log(tostring(num_players))
        end
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