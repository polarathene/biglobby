
local inspectData = true

--Host receiving
function ConnectionNetworkHandler:request_join(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
logger("[CNH-request_join] 1")
logger("PEER NAME: " .. tostring(peer_name))

	if not self._verify_in_server_session() and not (peer_name=="Gary") then
		return
	end
	logger("[CNH-request_join] 2")
	if inspectData then
		logger("PEER NAME: " .. tostring(peer_name) .. "\nPCHARACTER: " .. tostring(preferred_character) .. "\nDLCS: " .. tostring(dlcs) .. "\nXUID: " .. tostring(xuid) .. "\nPEER LV: " .. tostring(peer_level) .. "\nGAME VER: " .. tostring(gameversion) .. "\nJOIN ID: " .. tostring(join_attempt_identifier) .. "\nAUTH_TICKET: " .. tostring(auth_ticket) .. "\nSENDER: " .. tostring(sender))
		logger("=============\n\nIS NIL?, DLC:" .. tostring(dlcs == "") .. "\nXUID:" .. tostring(xuid == "") .. "\nGameVer:" .. tostring(gameversion == -1))
	end
	managers.network:session():on_join_request_received(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
end

--Client joining
function ConnectionNetworkHandler:join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	print(" 1 ConnectionNetworkHandler:join_request_reply", reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	logger("[CNH-join_request_reply] 1")
	logger("PEER ID: " .. tostring(my_peer_id))
	if not self._verify_in_client_session() then
		return
	end
	logger("[CNH-join_request_reply] 2")
	if inspectData then
		logger("REPLY_ID: " .. tostring(reply_id) .. "\nMYPEER_ID: " .. tostring(my_peer_id) .. "\nMYCHAR: " .. tostring(my_character) .. "\nLvINDEX: " .. tostring(level_index) .. "\nDiffINDEX: " .. tostring(difficulty_index) .. "\nSTATE: " .. tostring(state) .. "\nSERVERCHAR: " .. tostring(server_character) .. "\nUSERID: " .. tostring(user_id) .. "\nMISSION: " .. tostring(mission))
		logger("JobINDEX: " .. tostring(job_id_index) .. "\nJobSTAGE: " .. tostring(job_stage) .. "\nAltJobSTAGE: " .. tostring(alternative_job_stage) .. "\nInterruptJobSTAGE_LvINDEX: " .. tostring(interupt_job_stage_level_index) .. "\nXUID: " .. tostring(xuid) .. "\nAUTH_TICKET: " .. tostring(auth_ticket) .. "\nSENDER: " .. tostring(sender))
		logger("=======\n\n Is Empty?" .. "\nXUID: " .. tostring(xuid == ""))
	end
	managers.network:session():on_join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
end
function ConnectionNetworkHandler:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	print(" 1 ConnectionNetworkHandler:peer_handshake", name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	logger("[CNH-peer_handshake] 1")
	if not self._verify_in_client_session() then
		return
	end
	logger("[CNH-peer_handshake] 2")
	if inspectData then
		logger("NAME: " .. tostring(name) .. "\nPEERID: " .. tostring(peer_id) .. "\nIP: " .. tostring(ip) .. "\nINLOBBY: " .. tostring(in_lobby) .. "\nLOADING: " .. tostring(loading))
		logger("SYNCHED: " .. tostring(synched) .. "\nCHARACTER: " .. tostring(character) .. "\nSLOT: " .. tostring(slot) .. "\nMASKSET: " .. tostring(mask_set) .. "\nXUID: " .. tostring(xuid) .. "\nXNADDR: " .. tostring(xnaddr))
		logger("=======\n\n Is Empty?" .. "\nMaskSet: " .. tostring(mask_set == "") .. "\nXUID: " .. tostring(xuid == ""))
	end
	print(" 2 ConnectionNetworkHandler:peer_handshake")
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
end

function ConnectionNetworkHandler:steam_p2p_ping(sender)
	logger("[CNH-steam_p2p_ping]")
	print("[ConnectionNetworkHandler:steam_p2p_ping] from", sender:ip_at_index(0), sender:protocol_at_index(0))
	local session = managers.network:session()
	if not session or session:closing() then
		print("[ConnectionNetworkHandler:steam_p2p_ping] no session or closing")
		return
	end
	session:on_steam_p2p_ping(sender)
end

function ConnectionNetworkHandler:kick_peer(peer_id, message_id, sender)
logger("[CNH-kick_peer]")
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
logger("$$$$$$$$[CNH :request_drop_in_pause]")
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end

function ConnectionNetworkHandler:entered_lobby_confirmation(peer_id)
	logger("$$$$$$$$[CNH :entered_lobby_confirmation]")
	managers.network:session():on_entered_lobby_confirmation(peer_id)
end

function ConnectionNetworkHandler:set_peer_entered_lobby(sender)
logger("$$$$$$$$[CNH :set_peer_entered_lobby]")
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
logger("$$$$$$$$[CNH :set_peer_synched]")
	if not self._verify_sender(sender) then
		return
	end
	managers.network:session():on_peer_synched(id)
end


function ConnectionNetworkHandler:connection_established(peer_id, sender)
logger("$$$$$$$$[CNH :connection_established] peer_id: " .. tostring(peer_id) .. ", sender name and id: " .. tostring(sender:id()) .. " - " .. tostring(sender:name()))
	if not self._verify_in_server_session() then
		return
	end
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	logger("$$$$$$$$[CNH :connection_established] -> on_peer_connection_established()")
	managers.network:session():on_peer_connection_established(sender_peer, peer_id)
end

function ConnectionNetworkHandler:peer_exchange_info(peer_id, sender)
	logger("$$$$$$$$[CNH :connection_established] peer_id: " .. tostring(peer_id) .. ", sender: " .. tostring(sender:id()) .. " - " .. tostring(sender:name()))
	local sender_peer = self._verify_sender(sender)
	if not sender_peer then
		return
	end
	if self._verify_in_client_session() then
		if sender_peer:id() == 1 then
			logger("$$$$$$$$[CNH :connection_established] -> on_peer_requested_info()")
			managers.network:session():on_peer_requested_info(peer_id)
		elseif peer_id == sender_peer:id() then
			logger("$$$$$$$$[CNH :connection_established] -> send_to_host('peer_exchange_info', peer_id)")
			managers.network:session():send_to_host("peer_exchange_info", peer_id)
		end
	elseif self._verify_in_server_session() then
		logger("$$$$$$$$[CNH :connection_established] -> on_peer_connection_established(sender_peer, peer_id)")
		managers.network:session():on_peer_connection_established(sender_peer, peer_id)
	end
end
