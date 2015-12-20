--Host receiving
function ConnectionNetworkHandler:request_join(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
log("[CNH-request_join] 1")
log("PEER NAME: " .. tostring(peer_name))

	if not self._verify_in_server_session() and not (peer_name=="Gary") then
		return
	end
	log("[CNH-request_join] 2")
	local inspectData = true
	if inspectData then
		log("PEER NAME: " .. tostring(peer_name) .. "\nPCHARACTER: " .. tostring(preferred_character) .. "\nDLCS: " .. tostring(dlcs) .. "\nXUID: " .. tostring(xuid) .. "\nPEER LV: " .. tostring(peer_level) .. "\nGAME VER: " .. tostring(gameversion) .. "\nJOIN ID: " .. tostring(join_attempt_identifier) .. "\nAUTH_TICKET: " .. tostring(auth_ticket) .. "\nSENDER: " .. tostring(sender))
		log("=============\n\nIS NIL?, DLC:" .. tostring(dlcs == "") .. "\nXUID:" .. tostring(xuid == "") .. "\nGameVer:" .. tostring(gameversion == -1))
	end
	managers.network:session():on_join_request_received(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
end

--Client joining
function ConnectionNetworkHandler:join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	print(" 1 ConnectionNetworkHandler:join_request_reply", reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	log("[CNH-join_request_reply] 1")
	log("PEER ID: " .. tostring(my_peer_id))
	if not self._verify_in_client_session() then
		return
	end
	log("[CNH-join_request_reply] 2")
	local inspectData = true
	if inspectData then
		log("REPLY_ID: " .. tostring(reply_id) .. "\nMYPEER_ID: " .. tostring(my_peer_id) .. "\nMYCHAR: " .. tostring(my_character) .. "\nLvINDEX: " .. tostring(level_index) .. "\nDiffINDEX: " .. tostring(difficulty_index) .. "\nSTATE: " .. tostring(state) .. "\nSERVERCHAR: " .. tostring(server_character) .. "\nUSERID: " .. tostring(user_id) .. "\nMISSION: " .. tostring(mission))
		log("JobINDEX: " .. tostring(job_id_index) .. "\nJobSTAGE: " .. tostring(job_stage) .. "\nAltJobSTAGE: " .. tostring(alternative_job_stage) .. "\nInterruptJobSTAGE_LvINDEX: " .. tostring(interupt_job_stage_level_index) .. "\nXUID: " .. tostring(xuid) .. "\nAUTH_TICKET: " .. tostring(auth_ticket) .. "\nSENDER: " .. tostring(sender))
		log("=======\n\n Is Empty?" .. "\nXUID: " .. tostring(xuid == ""))
	end
	managers.network:session():on_join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
end
function ConnectionNetworkHandler:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	print(" 1 ConnectionNetworkHandler:peer_handshake", name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	log("[CNH-peer_handshake] 1")
	if not self._verify_in_client_session() then
		return
	end
	log("[CNH-peer_handshake] 2")
	local inspectData = true
	if inspectData then
		log("NAME: " .. tostring(name) .. "\nPEERID: " .. tostring(peer_id) .. "\nIP: " .. tostring(ip) .. "\nINLOBBY: " .. tostring(in_lobby) .. "\nLOADING: " .. tostring(loading))
		log("SYNCHED: " .. tostring(synched) .. "\nCHARACTER: " .. tostring(character) .. "\nSLOT: " .. tostring(slot) .. "\nMASKSET: " .. tostring(mask_set) .. "\nXUID: " .. tostring(xuid) .. "\nXNADDR: " .. tostring(xnaddr))
		log("=======\n\n Is Empty?" .. "\nMaskSet: " .. tostring(mask_set == "") .. "\nXUID: " .. tostring(xuid == ""))
	end
	print(" 2 ConnectionNetworkHandler:peer_handshake")
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
end

function ConnectionNetworkHandler:steam_p2p_ping(sender)
	log("[CNH-steam_p2p_ping]")
	print("[ConnectionNetworkHandler:steam_p2p_ping] from", sender:ip_at_index(0), sender:protocol_at_index(0))
	local session = managers.network:session()
	if not session or session:closing() then
		print("[ConnectionNetworkHandler:steam_p2p_ping] no session or closing")
		return
	end
	session:on_steam_p2p_ping(sender)
end

function ConnectionNetworkHandler:kick_peer(peer_id, message_id, sender)
log("[CNH-kick_peer]")
	if not self._verify_sender(sender) then
		return
	end
	sender:remove_peer_confirmation(peer_id)
	local peer = managers.network:session():peer(peer_id)
	if not peer then
		print("[ConnectionNetworkHandler:kick_peer] unknown peer", peer_id)
		return
	end
	managers.network:session():on_peer_kicked(peer, peer_id, message_id)
end



--connection Troubleshooting
function ConnectionNetworkHandler:request_drop_in_pause(peer_id, nickname, state, sender)
log("$$$$$$$$[CNH :request_drop_in_pause] peer_id: " .. tostring(peer_id))
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end

function ConnectionNetworkHandler:entered_lobby_confirmation(peer_id)
	log("$$$$$$$$[CNH :entered_lobby_confirmation] peer_id: " .. tostring(peer_id))
	managers.network:session():on_entered_lobby_confirmation(peer_id)
end

function ConnectionNetworkHandler:set_peer_entered_lobby(sender)
log("$$$$$$$$[CNH :set_peer_entered_lobby]")
	if not self._verify_in_session() then
		return
	end
	local peer = self._verify_sender(sender)
	if not peer then
		return
	end
	managers.network:session():on_peer_entered_lobby(peer)
end

function ConnectionNetworkHandler:set_peer_synched(id, sender)
log("$$$$$$$$[CNH :set_peer_synched] id: " .. tostring(id))
	if not self._verify_sender(sender) then
		return
	end
	managers.network:session():on_peer_synched(id)
end


function ConnectionNetworkHandler:connection_established(peer_id, sender)
	if not self._verify_in_server_session() then
		return
	end
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	log("$$$$$$$$[CNH :connection_established] peer_id: " .. tostring(peer_id) .. ", sender name and id: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()))
	log("$$$$$$$$[CNH :connection_established] -> on_peer_connection_established()")
	managers.network:session():on_peer_connection_established(sender_peer, peer_id)
end

function ConnectionNetworkHandler:peer_exchange_info(peer_id, sender)
	log("$$$$$$$$[CNH :peer_exchange_info] peer_id: " .. tostring(peer_id))
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	log("$$$$$$$$[CNH :peer_exchange_info] peer_id: " .. tostring(peer_id) .. ", sender: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()))
	if self._verify_in_client_session() then
		if sender_peer:id() == 1 then
			log("$$$$$$$$[CNH :peer_exchange_info] -> on_peer_requested_info()")
			managers.network:session():on_peer_requested_info(peer_id)
		elseif peer_id == sender_peer:id() then
			log("$$$$$$$$[CNH :peer_exchange_info] -> send_to_host('peer_exchange_info', peer_id)")
			managers.network:session():send_to_host("peer_exchange_info", peer_id)
		end
	elseif self._verify_in_server_session() then
		log("$$$$$$$$[CNH :peer_exchange_info] -> on_peer_connection_established(sender_peer, peer_id)")
		managers.network:session():on_peer_connection_established(sender_peer, peer_id)
	end
end


function ConnectionNetworkHandler:set_member_ready(peer_id, ready, mode, outfit_versions_str, sender)
	log("[ConnectionNetworkHandler :set_member_ready] check_me :: peer_id: " .. tostring(peer_id) .. ", mode: " .. tostring(mode) .. ", outfit_str: " .. tostring(outfit_versions_str))
	if peer_id == 4 then
		log("~~PEER 4~~")
		local peer
		local rpc = sender
		local session = managers.network:session()
		if rpc:protocol_at_index(0) == "STEAM" then
			peer = session:peer_by_user_id(rpc:ip_at_index(0))
		else
			peer = session:peer_by_ip(rpc:ip_at_index(0))
		end
		if peer then
			log("SENDER: " .. tostring(peer:name()) .. " - " .. tostring(peer:id()))
			peer_id = peer:id()
		else
			log("SENDER DOES NOT EXIST~?~?~")
		end
	end
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	local peer = managers.network:session():peer(peer_id)
	if not peer then
		log("[ConnectionNetworkHandler :set_member_ready] PEER DOES NOT EXIST - check_me")
		return
	end
	if mode == 1 then
		ready = ready ~= 0 and true or false
		local ready_state = peer:waiting_for_player_ready()
		peer:set_waiting_for_player_ready(ready)
		managers.network:session():on_set_member_ready(peer_id, ready, ready_state ~= ready, true)
		if Network:is_server() then
			managers.network:session():send_to_peers_loaded_except(peer_id, "set_member_ready", peer_id, ready and 1 or 0, 1, "")
			if game_state_machine:current_state().start_game_intro then
			elseif ready then
				managers.network:session():chk_spawn_member_unit(peer, peer_id)
			end
		end
	elseif mode == 2 then
		peer:set_streaming_status(ready)
		managers.network:session():on_streaming_progress_received(peer, ready)
	elseif mode == 3 then
		if Network:is_server() then
			managers.network:session():on_peer_finished_loading_outfit(peer, ready, outfit_versions_str)
		end
	elseif mode == 4 and Network:is_client() and peer == managers.network:session():server_peer() then
		managers.network:session():notify_host_when_outfits_loaded(ready, outfit_versions_str)
	end
end
