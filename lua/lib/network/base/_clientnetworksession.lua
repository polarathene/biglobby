local ClientNetworkSession_on_join_request_reply = ClientNetworkSession.on_join_request_reply

function ClientNetworkSession:on_join_request_reply(reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, num_players, sender)
    ClientNetworkSession_on_join_request_reply(self, reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	if reply == 1 then
        if num_players then
            Global.player_num = num_players
        end
	end
end