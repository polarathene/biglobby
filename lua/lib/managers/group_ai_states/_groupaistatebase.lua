--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function xlogger(content, use_chat)
	if log_data then
		if not content then return end
		if use_chat then
			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
		end
		if BigLobbyGlobals:Hook() == "pd2hook" then
			io.stdout:write(content .. "\n")
		else
			log(content)
		end
	end
end

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
