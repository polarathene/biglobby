if not _G.BigLobbyGlobals then
    _G.BigLobbyGlobals = {}

    BigLobbyGlobals.ModPath = ModPath
    BigLobbyGlobals.SavePath = SavePath

    BigLobbyGlobals.ClassPath = "lua/_custom/"

    BigLobbyGlobals.Classes = {
        "menu.lua"
    }

    for _, class in pairs(BigLobbyGlobals.Classes) do
        dofile(BigLobbyGlobals.ModPath .. BigLobbyGlobals.ClassPath .. class)
    end

    BigLobbyGlobals.Menu = bkin_bl__menu:new()

    -- The new player limit is defined here, it should not be greater than
    -- the max values set in the pdmod file.
    -- Prefer `Global.num_players` set by BigLobby host
    -- Use Global.num_players_settings as it will either be the user option or the default value for the Player #
    BigLobbyGlobals.num_players = Global.num_players or Global.num_players_settings

    function BigLobbyGlobals:num_player_slots()
        return self.num_players
    end

    -- Regular lobby / Seamless switching support
    function BigLobbyGlobals:is_small_lobby()
        --TODO: Changing lobby slot size without reloading mods such as in
        -- Crime.Net won't properly update filters. Don't enable until working better
        return false --self.num_players<=4
    end

    -- Semantic versioning
    function BigLobbyGlobals:version()
        return "2.0.7"
    end

    -- GameVersion for matchmaking
    function BigLobbyGlobals:gameversion()
        return 206
    end


    -- These tables show the network messages we've modified in the network settings pdmod
    -- We will use them for switching to biglobby prefixed messages when in big lobbies.
    local connection_network_handler_funcs = {
    	'kick_peer',
    	'remove_peer_confirmation',
    	'join_request_reply',
    	'peer_handshake',
    	'peer_exchange_info',
    	'connection_established',
    	'mutual_connection',
    	'set_member_ready',
    	'request_drop_in_pause',
    	'drop_in_pause_confirmation',
    	'set_peer_synched',
    	'dropin_progress',
    	'report_dead_connection',
    	'preplanning_reserved',
    	'draw_preplanning_event',
    	'sync_explode_bullet',
    	'sync_flame_bullet'
    }

    local unit_network_handler_funcs = {
    	'set_unit',
    	'remove_corpse_by_id',
    	'sync_trip_mine_setup',
    	'from_server_sentry_gun_place_result',
    	'sync_equipment_setup',
        'sync_ammo_bag_setup',
        'sync_grenades',
    	'sync_carry_data',
    	'sync_throw_projectile',
    	'sync_attach_projectile',
    	'sync_unlock_asset',
    	'sync_equipment_possession',
    	'sync_remove_equipment_possession',
    	'mark_minion',
    	'sync_statistics_result',
    	'suspicion',
    	'sync_enter_vehicle_host',
    	'sync_vehicle_player',
    	'sync_exit_vehicle',
    	'server_give_vehicle_loot_to_player',
    	'sync_give_vehicle_loot_to_player',
    	'sync_vehicle_interact_trunk'
    }

    -- Builds a single table from our two string based keys for each handler above
    BigLobbyGlobals.network_handler_funcs = {}
    function add_handler_funcs(handler_funcs)
        for i = 1, #handler_funcs do
            BigLobbyGlobals.network_handler_funcs[handler_funcs[i]] = true
    	end
    end

    add_handler_funcs(connection_network_handler_funcs)
    add_handler_funcs(unit_network_handler_funcs)

    -- Takes the network keys we defined above and prefixes any matches on the given handler
    function BigLobbyGlobals:rename_handler_funcs(NetworkHandler)
        for key, value in pairs(BigLobbyGlobals.network_handler_funcs) do
            if NetworkHandler[key] then
                NetworkHandler['biglobby__' .. key] = NetworkHandler[key]
            end
        end
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
