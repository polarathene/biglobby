function GroupAIStateBase:on_criminal_team_AI_enabled_state_changed()
	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1

	if Network:is_client() then
		return
	end
	if managers.groupai:state():team_ai_enabled() then
		self:fill_criminal_team_with_AI()
	else
		for i = 1, num_player_slots do
			self:remove_one_teamAI()
		end
	end
end
