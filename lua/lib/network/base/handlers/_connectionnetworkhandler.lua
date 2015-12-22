
function ConnectionNetworkHandler:request_join(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	if not self._verify_in_server_session() then
		return
	end
	managers.network:session():on_join_request_received(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
end
function ConnectionNetworkHandler:join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	print(" 1 ConnectionNetworkHandler:join_request_reply", reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	if not self._verify_in_client_session() then
		return
	end
	log("REPLY_ID: " .. tostring(reply_id) .. "\nMYPEER_ID: " .. tostring(my_peer_id) .. "\nMYCHAR: " .. tostring(my_character) .. "\nLvINDEX: " .. tostring(level_index) .. "\nDiffINDEX: " .. tostring(difficulty_index) .. "\nSTATE: " .. tostring(state) .. "\nSERVERCHAR: " .. tostring(server_character) .. "\nUSERID: " .. tostring(user_id) .. "\nMISSION: " .. tostring(mission))
	log("JobINDEX: " .. tostring(job_id_index) .. "\nJobSTAGE: " .. tostring(job_stage) .. "\nAltJobSTAGE: " .. tostring(alternative_job_stage) .. "\nInterruptJobSTAGE_LvINDEX: " .. tostring(interupt_job_stage_level_index) .. "\nXUID: " .. tostring(xuid))
	managers.network:session():on_join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
end
function ConnectionNetworkHandler:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	print(" 1 ConnectionNetworkHandler:peer_handshake", name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	if not self._verify_in_client_session() then
		return
	end
	print(" 2 ConnectionNetworkHandler:peer_handshake")
	log("NAME: " .. tostring(name) .. "\nPEERID: " .. tostring(peer_id) .. "\nIP: " .. tostring(ip) .. "\nINLOBBY: " .. tostring(in_lobby) .. "\nLOADING: " .. tostring(loading))
	log("SYNCHED: " .. tostring(synched) .. "\nCHARACTER: " .. tostring(character) .. "\nSLOT: " .. tostring(slot) .. "\nMASKSET: " .. tostring(mask_set) .. "\nXUID: " .. tostring(xuid) .. "\nXNADDR: " .. tostring(xnaddr))
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
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
function ConnectionNetworkHandler:mutual_connection(other_peer_id)
	print("[ConnectionNetworkHandler:mutual_connection]", other_peer_id)
	if not self._verify_in_client_session() then
		return
	end
	managers.network:session():on_mutual_connection(other_peer_id)
end
function ConnectionNetworkHandler:kick_peer(peer_id, message_id, sender)
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
function ConnectionNetworkHandler:remove_peer_confirmation(removed_peer_id, sender)
	log("$$$$$$$$[CNH :remove_peer_confirmation] removed_peer_id: " .. tostring(removed_peer_id))
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	managers.network:session():on_remove_peer_confirmation(sender_peer, removed_peer_id)
end

function ConnectionNetworkHandler:set_peer_synched(id, sender)
	log("$$$$$$$$[CNH :set_peer_synched] peer_id: " .. tostring(id))
	if not self._verify_sender(sender) then
		return
	end
	managers.network:session():on_peer_synched(id)
end

function ConnectionNetworkHandler:entered_lobby_confirmation(peer_id)
	log("$$$$$$$$[CNH :entered_lobby_confirmation] peer_id: " .. tostring(peer_id))
	managers.network:session():on_entered_lobby_confirmation(peer_id)
end

function ConnectionNetworkHandler:request_drop_in_pause(peer_id, nickname, state, sender)
log("$$$$$$$$[CNH :request_drop_in_pause] peer_id: " .. tostring(peer_id))
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end
function ConnectionNetworkHandler:drop_in_pause_confirmation(dropin_peer_id, sender)
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	managers.network:session():on_drop_in_pause_confirmation_received(dropin_peer_id, sender_peer)
end
function ConnectionNetworkHandler:report_dead_connection(other_peer_id, sender)
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	managers.network:session():on_dead_connection_reported(sender_peer:id(), other_peer_id)
end

function ConnectionNetworkHandler:dropin_progress(dropin_peer_id, progress_percentage, sender)
log("[CNH :dropin_progress] dropin_peer_id: " .. tostring(dropin_peer_id) .. ", progress: " .. tostring(progress_percentage))
	if not self._verify_in_client_session() or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end
	local session = managers.network:session()
	local dropin_peer = session:peer(dropin_peer_id)
	if not dropin_peer or dropin_peer_id == session:local_peer():id() then
		return
	end
	session:on_dropin_progress_received(dropin_peer_id, progress_percentage)
end
function ConnectionNetworkHandler:set_member_ready(peer_id, ready, mode, outfit_versions_str, sender)
	log("[ConnectionNetworkHandler :set_member_ready] check_me 1 :: peer_id: " .. tostring(peer_id) .. ", mode: " .. tostring(mode) .. ", outfit_str: " .. tostring(outfit_versions_str))
	peer_id, ready, mode, outfit_versions_str = unpack(json.decode(outfit_versions_str))
	log("[ConnectionNetworkHandler :set_member_ready] check_me 2 :: peer_id: " .. tostring(peer_id) .. ", mode: " .. tostring(mode) .. ", outfit_str: " .. tostring(outfit_versions_str))

	--Get real peer id by assigning peer_id as senders...is this ok? or do we have a problem?
	-- local sender_peer = self._verify_sender(sender)
	-- if not sender_peer then
	-- 	return
	-- end
	-- peer_id = sender_peer:id()
	-- log("SENDER: " .. tostring(sender_peer:name()) .. " - " .. tostring(sender_peer:id()))
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	local peer = managers.network:session():peer(peer_id)
	if not peer then
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

--[[
function ConnectionNetworkHandler:sync_explode_bullet(position, normal, damage, peer_id_or_selection_index, sender)
	log("[ConnectionNetworkHandler :sync_explode_bullet] peer_id_or_selection_index: " .. tostring(peer_id_or_selection_index))
	local peer = self._verify_sender(sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end
	if InstantExplosiveBulletBase then
		break -- decompile bug
	end
end
]]

function ConnectionNetworkHandler:preplanning_reserved(type, id, peer_id, state, sender)
	log("[ConnectionNetworkHandler :preplanning_reserved] peer_id: " .. tostring(peer_id))
	if not self._verify_sender(sender) then
		return
	end
	if state == 0 then
		managers.preplanning:client_reserve_mission_element(type, id, peer_id)
	elseif state == 1 then
		managers.preplanning:client_unreserve_mission_element(id, peer_id)
	elseif state == 2 then
		managers.preplanning:client_vote_on_plan(type, id, peer_id)
	end
end
