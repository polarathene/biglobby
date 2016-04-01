if not _G.BigLobbyGlobals then
    _G.BigLobbyGlobals = {}

    -- The new player limit is defined here, it should not be greater than
    -- the max values set in the pdmod file.
    BigLobbyGlobals.num_players = 14

    function BigLobbyGlobals:num_player_slots()
        return (Global.player_num ~= nil and managers.network and managers.network:session() and not managers.network:session():is_host()) and Global.player_num or self.num_players
    end

    -- Semantic versioning
    function BigLobbyGlobals:version()
        return "1.1.0"
    end
    
    -- GameVersion for matchmaking
    function BigLobbyGlobals:gameversion()
        return 110
    end

    -- Nothing calls this anymore for the time being.
    local log_data = true -- Can use to turn the logging on/off
    function BigLobbyGlobals:logger(content, use_chat)
        if log_data then
            if not content then return end

            if use_chat then
                managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
            end

            log(content)
        end
    end

end
