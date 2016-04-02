-- Extends the ConnectionNetworkHandler class to add our own connection network calls
BigLobby__ConnectionNetworkHandler = BigLobby__ConnectionNetworkHandler or class(ConnectionNetworkHandler)

-- Additional `num_players` parameter(set in pdmod xml) for adjusting BigLobby to host lobby size preference
-- params: [ reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character,
-- user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index,
-- xuid, auth_ticket, num_players, sender ]
function BigLobby__ConnectionNetworkHandler:join_request_reply(...)
	if not self._verify_in_client_session() then
		return
	end
	
	managers.network:session():on_join_request_reply(...)
end

-- Will add a prefix of `biglobby__` to all functions our definitions use
-- Required to maintain compatibility with normal lobbies.
BigLobbyGlobals:rename_handler_funcs(BigLobby__ConnectionNetworkHandler)
