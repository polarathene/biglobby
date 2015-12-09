BigLobbyGlobals = BigLobbyGlobals or class()

--local aticket
function BigLobbyGlobals:auth_ticket(ticket)
    log("[BigLobbyGlobals :auth_ticket]")
    if ticket then tweak_data.aticket = ticket end
    return tweak_data.aticket
end

--pd2hook or BLT version
function BigLobbyGlobals:Hook()
    return "BLT"
end

--local jdata
function BigLobbyGlobals:jdata(peer_id, data)
    log("[BigLobbyGlobals :jdata] peer_id: " .. tostring(peer_id) .. ", data: " .. tostring(data))
    if data then
        log("[BigLobbyGlobals :jdata] setting data")
        if not tweak_data.jdata then tweak_data.jdata = {} end
        tweak_data.jdata[peer_id] = data
    end
    log("[BigLobbyGlobals :jdata] returning data: " .. tostring(tweak_data.jdata[peer_id]))
    return tweak_data.jdata[peer_id]
end

function BigLobbyGlobals:num_player_slots()
    return 6
end

function BigLobbyGlobals:gtrace(content)
  if not content then return end
  io.stdout:write(content .. "\n")
end


local test_id = "who_is_awesome"
local Net = _G.LuaNetworking
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_PMs", function(sender, id, data)
log("NETWORK RESPONSE: " .. tostring(id))
    if id == test_id then
        log("[BigLobbyGlobals :network_hook] who_is_awesome")
        data = tonumber(data)
        local name = Net:GetNameFromPeerID( sender )
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        log("[BigLobbyGlobals :who_is_awesome] Why " .. tostring(managers.network:session():peer(data):name()) .. " is awesome of course!")
    	log("[BigLobbyGlobals :who_is_awesome] From " .. tostring(managers.network:session():peer(sender):name()) .. " :)")
    end

    if id == "client_peer_handshake" then
        log("[BigLobbyGlobals :network_hook] client_peer_handshake")
        local name = Net:GetNameFromPeerID( sender )
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        client_peer_handshake(data)
    end

    if id == "client_on_join_request_reply" then
        log("[BigLobbyGlobals :network_hook] client_on_join_request_reply")
        local name = Net:GetNameFromPeerID( sender )
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        client_on_join_request_reply(data)
    end

    if id == "request_json_data" then
        log("[BigLobbyGlobals :network_hook] request_json_data")
        local name = Net:GetNameFromPeerID( sender )
        log("JSON DATA REQUEST")
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        local jsdata = BigLobbyGlobals:jdata(sender)
        log("Sending JSON data to peer: " .. sender .. ", jsdata: " .. tostring(jsdata))

        Net:SendToPeer(sender, "client_on_join_request_reply", jsdata)
        --local exclude = { 1, 3, 4 }
        --Net:SendToPeersExcept( exclude, "client_on_join_request_reply", jsdata )
    end

    if id == "client_reply_finished" then
        log("[BigLobbyGlobals :network_hook] client_reply_finished")
        local new_peer = managers.network:session():peer(sender)
        local data_session = managers.network
        new_peer:send("set_loading_state", false, data_session:session():load_counter())
        if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
            new_peer:send("request_player_name_reply", managers.network:session():local_peer():name())
        end
        managers.vote:sync_server_kick_option(new_peer)
        data_session:session():send_ok_to_load_level()
        -- crashes, claims nil value. managers.network = NetworkManager, :session() returns ._session,
        -- should be a host session, so don't know what's up :\ moved back to original method.
        --managers.network:session():on_handshake_confirmation(data_session, new_peer, 1)
        logger("[HostStateInGame: on_join_request_received] DONE!!!!" .. tostring(peer_name))
    end
end)


function client_peer_handshake(data)
    log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake]")
    --parameters unpacked from json data
    local name, peer_id, peer_user_id, in_lobby, loading, synched, character, mask_set, xuid, xnaddr = unpack(json.decode(data))
	log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake] name: " .. tostring(name) .. ", peer_id: " .. tostring(peer_id))
	--print("ClientNetworkSession:peer_handshake", name, peer_id, peer_user_id, in_lobby, loading, synched, character, mask_set, xuid, xnaddr)

    if managers.network:session()._peers[peer_id] then
		log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake] ALREADY HAVE PEER")
		print("ALREADY HAD PEER returns here")
		local peer = managers.network:session()._peers[peer_id]
		if peer:ip_verified() then
			log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake] PEER IP VERIFIED")
			managers.network:session()._server_peer:send("connection_established", peer_id)
		end
		return
	end
	local rpc
	if managers.network:session()._server_protocol == "STEAM" then
		rpc = Network:handshake(peer_user_id, nil, "STEAM")
		Network:add_co_client(rpc)
	end
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		local ip = managers.network.matchmake:internal_address(xnaddr)
		rpc = Network:handshake(ip, managers.network.DEFAULT_PORT, "TCP_IP")
		Network:add_co_client(rpc)
	end
	if SystemInfo:platform() ~= managers.network:session()._ids_WIN32 or not peer_user_id then
		peer_user_id = false
	end
	if SystemInfo:platform() == Idstring("WIN32") then
		name = managers.network.account:username_by_id(peer_user_id)
	end
	log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake] Adding Peer")
	local id, peer = managers.network:session():add_peer(name, rpc, in_lobby, loading, synched, peer_id, character, peer_user_id, xuid, xnaddr)
	cat_print("multiplayer_base", "[BigLobbyGlobals-ClientNetworkSession:peer_handshake]", name, peer_user_id, loading, synched, id, inspect(peer))
	local check_peer = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and peer or nil
	managers.network:session():chk_send_connection_established(name, peer_user_id, check_peer)
	if managers.trade then
		log("[BigLobbyGlobals-ClientNetworkSession :peer_handshake] Handshake Complete? ")
		managers.trade:handshake_complete(peer_id)
	end
end


function client_on_join_request_reply(data)
    log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply]")
    --parameters unpacked from json data
    --local reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender = unpack(json.decode(data))
    local func_name, reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid = unpack(json.decode(data))
    --set vars to stored ticket and sender
    local auth_ticket = BigLobbyGlobals:auth_ticket()
    --local sender = BigLobbyGlobals:sender() --not needed anymore

	log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] My Peer ID: " .. tostring(my_peer_id) .. ", my character: " .. tostring(my_character))
    log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] Reply: " .. tostring(reply))
	--print("[BigLobbyGlobals-ClientNetworkSession:on_join_request_reply] ", managers.network:session()._server_peer and managers.network:session()._server_peer:user_id(), user_id, sender:ip_at_index(0), sender:protocol_at_index(0))

	local cb = managers.network:session()._cb_find_game
	managers.network:session()._cb_find_game = nil
	if reply == 1 then
		managers.network:session()._host_sanity_send_t = TimerManager:wall():time() + managers.network:session().HOST_SANITY_CHECK_INTERVAL
		Global.game_settings.level_id = tweak_data.levels:get_level_name_from_index(level_index)
		Global.game_settings.difficulty = tweak_data:index_to_difficulty(difficulty_index)
		Global.game_settings.mission = mission
		managers.network:session()._server_peer:set_character(server_character)
		managers.network:session()._server_peer:set_xuid(xuid)
		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
			local xnaddr = managers.network.matchmake:external_address(managers.network:session()._server_peer:rpc())
			managers.network:session()._server_peer:set_xnaddr(xnaddr)
			managers.network.matchmake:on_peer_added(managers.network:session()._server_peer)
		elseif SystemInfo:platform() == Idstring("PS4") then
			managers.network.matchmake:on_peer_added(managers.network:session()._server_peer)
		end
		--LOCAL PEER ASSIGNED PEER ID
		managers.network:session():register_local_peer(my_peer_id)
		managers.network:session()._local_peer:set_character(my_character)
		managers.network:session()._server_peer:set_id(1)
        if not managers.network:session()._server_peer:begin_ticket_session(auth_ticket) then
    		log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] AUTH_HOST_FAILED")
    		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
    		cb("AUTH_HOST_FAILED") --no cb again! failed auth!
    		return
    	end
    	log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] AUTH_HOST_OK")
		managers.network:session()._server_peer:set_in_lobby_soft(state_index == 1)
		managers.network:session()._server_peer:set_synched_soft(state_index ~= 1)
		if SystemInfo:platform() == Idstring("PS3") then
		end
		managers.network:session():_chk_send_proactive_outfit_loaded()
		if job_id_index ~= 0 then
			local job_id = tweak_data.narrative:get_job_name_from_index(job_id_index)
			managers.job:activate_job(job_id, job_stage)
			if alternative_job_stage ~= 0 then
				managers.job:synced_alternative_stage(alternative_job_stage)
			end
			if interupt_job_stage_level_index ~= 0 then
				local interupt_level = tweak_data.levels:get_level_name_from_index(interupt_job_stage_level_index)
				managers.job:synced_interupt_stage(interupt_level)
			end
			Global.game_settings.world_setting = managers.job:current_world_setting()
			managers.network:session()._server_peer:verify_job(job_id)
		end
		cb(state_index == 1 and "JOINED_LOBBY" or "JOINED_GAME", level_index, difficulty_index, state_index) --no cb for player crashed them on this line
	elseif reply == 2 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("KICKED")
	elseif reply == 0 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("FAILED_CONNECT")
	elseif reply == 3 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("GAME_STARTED")
	elseif reply == 4 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("DO_NOT_OWN_HEIST")
	elseif reply == 5 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("GAME_FULL")
	elseif reply == 6 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("LOW_LEVEL")
	elseif reply == 7 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("WRONG_VERSION")
	elseif reply == 8 then
		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
		cb("AUTH_FAILED")
	end
    log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] Done")
    Net:SendToPeer(1, "client_reply_finished", "nothing")
end

--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function logger(content, use_chat)
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
