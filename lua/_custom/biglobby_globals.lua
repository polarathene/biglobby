BigLobbyGlobals = BigLobbyGlobals or class()

-- I think I only need this function and can delete the rest?
function BigLobbyGlobals:num_player_slots()
    return 15
end


function BigLobbyGlobals:version()
    return 0.4
end


--Use global version later? Possible issue with reaching global/class functions for some classes?
local log_data = true
function logger(content, use_chat)
	if log_data then
		if not content then return end

		if use_chat then
			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
		end

		log(content)
	end
end

-- Fix fps performance problems due to running this script every frame
-- 'cos I'm a nub.
biglobby_globals=true
