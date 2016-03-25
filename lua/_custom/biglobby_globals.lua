BigLobbyGlobals = BigLobbyGlobals or class()

--BigLobbyGlobals.aticket = nil
--local aticket
function BigLobbyGlobals:auth_ticket(ticket)
    log("[BigLobbyGlobals :auth_ticket]")
    if ticket then BigLobbyGlobals.aticket = ticket end
    return BigLobbyGlobals.aticket
end

--pd2hook or BLT version
function BigLobbyGlobals:Hook()
    return "BLT"
end

function BigLobbyGlobals:version()
    return 0.2
end

--BigLobbyGlobals.jdata = nil
--local jdata
function BigLobbyGlobals:jdata(peer_id, data)
    log("[BigLobbyGlobals :jdata] peer_id: " .. tostring(peer_id) .. ", data: " .. tostring(data))
    if data then
        log("[BigLobbyGlobals :jdata] setting data for peer: " .. tostring(peer_id))
        if not BigLobbyGlobals._jdata then BigLobbyGlobals._jdata = {} end
        BigLobbyGlobals._jdata[peer_id] = data
    end
    log("[BigLobbyGlobals :jdata] returning data: " .. tostring(BigLobbyGlobals._jdata[peer_id]))
    return BigLobbyGlobals._jdata[peer_id]
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

if id == "join_request_reply" then
--join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
--log("REPLY_ID: " .. tostring(reply_id) .. "\nMYPEER_ID: " .. tostring(my_peer_id) .. "\nMYCHAR: " .. tostring(my_character) .. "\nLvINDEX: " .. tostring(level_index) .. "\nDiffINDEX: " .. tostring(difficulty_index) .. "\nSTATE: " .. tostring(state) .. "\nSERVERCHAR: " .. tostring(server_character) .. "\nUSERID: " .. tostring(user_id) .. "\nMISSION: " .. tostring(mission))
--log("JobINDEX: " .. tostring(job_id_index) .. "\nJobSTAGE: " .. tostring(job_stage) .. "\nAltJobSTAGE: " .. tostring(alternative_job_stage) .. "\nInterruptJobSTAGE_LvINDEX: " .. tostring(interupt_job_stage_level_index) .. "\nXUID: " .. tostring(xuid))
log("[BigLobbyGlobals :set_member_ready] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
local sender_peer = managers.network:session():peer(sender):rpc()
managers.network:session():on_join_request_reply(unpack(json.decode(data)), auth_ticket, sender)
end

    --if id == "client_peer_handshake" then
    if id == "peer_handshake" then
        log("[BigLobbyGlobals :network_hook] " .. id)
        local name = Net:GetNameFromPeerID( sender )
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        BigLobbyGlobals:peer_handshake(unpack(json.decode(data)))
        --client_peer_handshake(data)
    end

-- if id == "client_on_join_request_reply" then
--     log("[BigLobbyGlobals :network_hook] client_on_join_request_reply")
--     local name = Net:GetNameFromPeerID( sender )
--     log( "Received Private Message from: " .. name )
--     log( "Message: " .. data )
--
--     client_on_join_request_reply(data)
-- end
--
-- if id == "request_json_data" then
--     log("[BigLobbyGlobals :network_hook] request_json_data")
--     local name = Net:GetNameFromPeerID( sender )
--     log("JSON DATA REQUEST")
--     log( "Received Private Message from: " .. name )
--     log( "Message: " .. data )
--
--     local jsdata = BigLobbyGlobals:jdata(sender)
--     log("Sending JSON data to peer: " .. sender .. ", jsdata: " .. tostring(jsdata))
--
--     Net:SendToPeer(sender, "client_on_join_request_reply", jsdata)
--     --local exclude = { 1, 3, 4 }
--     --Net:SendToPeersExcept( exclude, "client_on_join_request_reply", jsdata )
-- end

-- if id == "client_reply_finished" then
--     log("[BigLobbyGlobals :network_hook] client_reply_finished")
--     local new_peer = managers.network:session():peer(sender)
--     local data_session = managers.network
--     new_peer:send("set_loading_state", false, data_session:session():load_counter())
--     if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
--         new_peer:send("request_player_name_reply", managers.network:session():local_peer():name())
--     end
--     managers.vote:sync_server_kick_option(new_peer)
--     data_session:session():send_ok_to_load_level()
--     -- crashes, claims nil value. managers.network = NetworkManager, :session() returns ._session,
--     -- should be a host session, so don't know what's up :\ moved back to original method.
--     --managers.network:session():on_handshake_confirmation(data_session, new_peer, 1)
--     logger("[HostStateInGame: on_join_request_received] DONE!!!!" .. tostring(peer_name))
-- end

    if id == "set_member_ready" then
        log("[BigLobbyGlobals :set_member_ready] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
        local sender_peer = managers.network:session():peer(sender):rpc()
        BigLobbyGlobals:set_member_ready(sender_peer, unpack(json.decode(data)))
    end

    if id == "peer_exchange_info" then
        log("[BigLobbyGlobals :peer_exchange_info] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
        local sender_peer = managers.network:session():peer(sender):rpc()
        BigLobbyGlobals:peer_exchange_info(sender_peer, unpack(json.decode(data)))
    end

    if id == "connection_established" then
        log("[BigLobbyGlobals :connection_established] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
        local sender_peer = managers.network:session():peer(sender):rpc()
        BigLobbyGlobals:connection_established(sender_peer, unpack(json.decode(data)))
    end

    if id == "mutual_connection" then
        log("[BigLobbyGlobals :mutual_connection] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
        --local sender_peer = managers.network:session():peer(sender):rpc()
        BigLobbyGlobals:mutual_connection(unpack(json.decode(data)))
    end

if id == "set_peer_synched" then
    log("[BigLobbyGlobals :set_peer_synched] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
    local sender_peer = managers.network:session():peer(sender):rpc()
    BigLobbyGlobals:set_peer_synched(sender_peer, unpack(json.decode(data)))
end

if id == "request_drop_in_pause" then
    log("[BigLobbyGlobals :request_drop_in_pause] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
    local sender_peer = managers.network:session():peer(sender):rpc()
    BigLobbyGlobals:request_drop_in_pause(sender_peer, unpack(json.decode(data)))
end

if id == "drop_in_pause_confirmation" then
    log("[BigLobbyGlobals :drop_in_pause_confirmation] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
    local sender_peer = managers.network:session():peer(sender):rpc()
    BigLobbyGlobals:drop_in_pause_confirmation(sender_peer, unpack(json.decode(data)))
end

if id == "dropin_progress" then
    log("[BigLobbyGlobals :dropin_progress] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
    local sender_peer = managers.network:session():peer(sender):rpc()
    BigLobbyGlobals:dropin_progress(sender_peer, unpack(json.decode(data)))
end


--
-- UnitNetworkHandler
--
if id == "sync_trip_mine_setup" then
    log("[BigLobbyGlobals :sync_trip_mine_setup] sender_id: ".. tostring(sender) .. ", data: " .. tostring(data))
data = json.decode(data)
    --for k,v in pairs(typefilter) do
      for _,unitx in ipairs(World:find_units_quick("all", managers.slot:get_mask("world_geometry"), managers.slot:get_mask("trip_mine_targets"), managers.slot:get_mask("trip_mine_placeables"))) do
        if tostring(unitx:id()) == data[1] then
            log("[BigLobbyGlobals :sync_trip_mine_setup] FOUND TRIPMINE! " .. data[1])
        end
        --local pox = get_crosshair_pos_new().hit_position
        -- if(type==v) then
        --   --World:delete_unit(unitx)
        --   --unitx:set_slot(0)
        --   pox = Vector3(99999,99999,99999)
        --   --unitx:set_position(pox)
        -- end
      end
--      typetable[v] = nil
--    end
    --local sender_peer = managers.network:session():peer(sender):rpc()
    --BigLobbyGlobals:sync_trip_mine_setup(sender_peer, unpack(json.decode(data)))
end


end)


function BigLobbyGlobals:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
    log("[BigLobbyGlobals :peer_handshake]")
	if not BaseNetworkHandler._verify_in_client_session() then
        log("[BigLobbyGlobals :peer_handshake] verification failed")
		return
	end
    log("[BigLobbyGlobals :peer_handshake] verified")
	log("NAME: " .. tostring(name) .. "\nPEERID: " .. tostring(peer_id) .. "\nIP: " .. tostring(ip) .. "\nINLOBBY: " .. tostring(in_lobby) .. "\nLOADING: " .. tostring(loading))
	log("SYNCHED: " .. tostring(synched) .. "\nCHARACTER: " .. tostring(character) .. "\nSLOT: " .. tostring(slot) .. "\nMASKSET: " .. tostring(mask_set) .. "\nXUID: " .. tostring(xuid) .. "\nXNADDR: " .. tostring(xnaddr))
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
end

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


-- function client_on_join_request_reply(data)
--     log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply]")
--     --parameters unpacked from json data
--     --local reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender = unpack(json.decode(data))
--     local func_name, reply, my_peer_id, my_character, level_index, difficulty_index, state_index, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid = unpack(json.decode(data))
--     --set vars to stored ticket and sender
--     local auth_ticket = BigLobbyGlobals:auth_ticket()
--     --local sender = BigLobbyGlobals:sender() --not needed anymore
--     my_peer_id, my_character = unpack(json.decode(my_character)) --ClientNetworkSession not getting called? I had this there before but character was assigned json string oddly peer ID was correct in this function without this trick!? (host assigned first new peer as 5 however..)
--
-- 	log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] My Peer ID: " .. tostring(my_peer_id) .. ", my character: " .. tostring(my_character))
--     log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] Reply: " .. tostring(reply))
-- 	--print("[BigLobbyGlobals-ClientNetworkSession:on_join_request_reply] ", managers.network:session()._server_peer and managers.network:session()._server_peer:user_id(), user_id, sender:ip_at_index(0), sender:protocol_at_index(0))
--
-- 	local cb = managers.network:session()._cb_find_game
--     if cb == nil then
--         log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] CB IS NIL, WILL CRASH, RETURNING")
--         return
--     end
-- 	managers.network:session()._cb_find_game = nil
-- 	if reply == 1 then
-- 		managers.network:session()._host_sanity_send_t = TimerManager:wall():time() + managers.network:session().HOST_SANITY_CHECK_INTERVAL
-- 		Global.game_settings.level_id = tweak_data.levels:get_level_name_from_index(level_index)
-- 		Global.game_settings.difficulty = tweak_data:index_to_difficulty(difficulty_index)
-- 		Global.game_settings.mission = mission
-- 		managers.network:session()._server_peer:set_character(server_character)
-- 		managers.network:session()._server_peer:set_xuid(xuid)
-- 		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
-- 			local xnaddr = managers.network.matchmake:external_address(managers.network:session()._server_peer:rpc())
-- 			managers.network:session()._server_peer:set_xnaddr(xnaddr)
-- 			managers.network.matchmake:on_peer_added(managers.network:session()._server_peer)
-- 		elseif SystemInfo:platform() == Idstring("PS4") then
-- 			managers.network.matchmake:on_peer_added(managers.network:session()._server_peer)
-- 		end
-- 		--LOCAL PEER ASSIGNED PEER ID
-- 		managers.network:session():register_local_peer(my_peer_id)
-- 		managers.network:session()._local_peer:set_character(my_character)
-- 		managers.network:session()._server_peer:set_id(1)
--         if not managers.network:session()._server_peer:begin_ticket_session(auth_ticket) then
--     		log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] AUTH_HOST_FAILED")
--     		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
--     		cb("AUTH_HOST_FAILED") --no cb again! failed auth!
--     		return
--     	end
--     	log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] AUTH_HOST_OK")
-- 		managers.network:session()._server_peer:set_in_lobby_soft(state_index == 1)
-- 		managers.network:session()._server_peer:set_synched_soft(state_index ~= 1)
-- 		if SystemInfo:platform() == Idstring("PS3") then
-- 		end
-- 		managers.network:session():_chk_send_proactive_outfit_loaded()
-- 		if job_id_index ~= 0 then
-- 			local job_id = tweak_data.narrative:get_job_name_from_index(job_id_index)
-- 			managers.job:activate_job(job_id, job_stage)
-- 			if alternative_job_stage ~= 0 then
-- 				managers.job:synced_alternative_stage(alternative_job_stage)
-- 			end
-- 			if interupt_job_stage_level_index ~= 0 then
-- 				local interupt_level = tweak_data.levels:get_level_name_from_index(interupt_job_stage_level_index)
-- 				managers.job:synced_interupt_stage(interupt_level)
-- 			end
-- 			Global.game_settings.world_setting = managers.job:current_world_setting()
-- 			managers.network:session()._server_peer:verify_job(job_id)
-- 		end
-- 		cb(state_index == 1 and "JOINED_LOBBY" or "JOINED_GAME", level_index, difficulty_index, state_index) --no cb for player crashed them on this line
-- 	elseif reply == 2 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("KICKED")
-- 	elseif reply == 0 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("FAILED_CONNECT")
-- 	elseif reply == 3 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("GAME_STARTED")
-- 	elseif reply == 4 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("DO_NOT_OWN_HEIST")
-- 	elseif reply == 5 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("GAME_FULL")
-- 	elseif reply == 6 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("LOW_LEVEL")
-- 	elseif reply == 7 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("WRONG_VERSION")
-- 	elseif reply == 8 then
-- 		managers.network:session():remove_peer(managers.network:session()._server_peer, 1)
-- 		cb("AUTH_FAILED")
-- 	end
--     log("[BigLobbyGlobals-ClientNetworkSession :on_join_request_reply] Done")
--     Net:SendToPeer(1, "client_reply_finished", "nothing v" .. tostring(BigLobbyGlobals:version()))
-- end

function BigLobbyGlobals:set_member_ready(sender, peer_id, ready, mode, outfit_versions_str)
	log("[BigLobbyGlobals :set_member_ready] check_me 1 :: peer_id: " .. tostring(peer_id) .. ", mode: " .. tostring(mode) .. ", outfit_str: " .. tostring(outfit_versions_str))
	--peer_id, ready, mode, outfit_versions_str = unpack(json.decode(outfit_versions_str))
	log("[BigLobbyGlobals :set_member_ready] check_me 2 :: peer_id: " .. tostring(peer_id) .. ", mode: " .. tostring(mode) .. ", outfit_str: " .. tostring(outfit_versions_str))

	--Get real peer id by assigning peer_id as senders...is this ok? or do we have a problem?
	-- local sender_peer = self._verify_sender(sender)
	-- if not sender_peer then
	-- 	return
	-- end
	-- peer_id = sender_peer:id()
	-- log("SENDER: " .. tostring(sender_peer:name()) .. " - " .. tostring(sender_peer:id()))
	if not BaseNetworkHandler._verify_gamestate(BaseNetworkHandler._gamestate_filter.any_ingame) or not BaseNetworkHandler._verify_sender(sender) then
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

function BigLobbyGlobals:peer_exchange_info(sender, peer_id)
	log("$$$$$$$$[BigLobbyGlobals :peer_exchange_info] peer_id: " .. tostring(peer_id))
	local sender_peer = BaseNetworkHandler._verify_sender(sender)
	if not sender_peer then
		return
	end
	log("$$$$$$$$[BigLobbyGlobals :peer_exchange_info] peer_id: " .. tostring(peer_id) .. ", sender: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()))
	if BaseNetworkHandler._verify_in_client_session() then
		if sender_peer:id() == 1 then
			log("$$$$$$$$[BigLobbyGlobals :peer_exchange_info] -> on_peer_requested_info()")
			managers.network:session():on_peer_requested_info(peer_id)
		elseif peer_id == sender_peer:id() then
			log("$$$$$$$$[BigLobbyGlobals :peer_exchange_info] -> send_to_host('peer_exchange_info', peer_id)")
			managers.network:session():send_to_host("peer_exchange_info", peer_id)
		end
	elseif BaseNetworkHandler._verify_in_server_session() then
		log("$$$$$$$$[BigLobbyGlobals :peer_exchange_info] -> on_peer_connection_established(sender_peer, peer_id)")
		managers.network:session():on_peer_connection_established(sender_peer, peer_id)
	end
end

function BigLobbyGlobals:connection_established(sender, peer_id)
	if not BaseNetworkHandler._verify_in_server_session() then
		return
	end
	local sender_peer = BaseNetworkHandler._verify_sender(sender)
	if not sender_peer then
		return
	end
	log("$$$$$$$$[BigLobbyGlobals :connection_established] peer_id: " .. tostring(peer_id) .. ", sender name and id: " .. tostring(sender_peer:id()) .. " - " .. tostring(sender_peer:name()))
	log("$$$$$$$$[BigLobbyGlobals :connection_established] -> on_peer_connection_established()")
	managers.network:session():on_peer_connection_established(sender_peer, peer_id)
end
function BigLobbyGlobals:mutual_connection(other_peer_id)
	print("[BigLobbyGlobals:mutual_connection]", other_peer_id)
	if not BaseNetworkHandler._verify_in_client_session() then
		return
	end
	managers.network:session():on_mutual_connection(other_peer_id)
end

function BigLobbyGlobals:set_peer_synched(sender, id)
	log("$$$$$$$$[BigLobbyGlobals :set_peer_synched] peer_id: " .. tostring(id))
	if not BaseNetworkHandler._verify_sender(sender) then
		return
	end
	managers.network:session():on_peer_synched(id)
end

function BigLobbyGlobals:request_drop_in_pause(sender, peer_id, nickname, state)
    log("$$$$$$$$[BigLobbyGlobals :request_drop_in_pause] peer_id: " .. tostring(peer_id))
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end
function BigLobbyGlobals:drop_in_pause_confirmation(sender, dropin_peer_id)
    log("$$$$$$$$[BigLobbyGlobals :drop_in_pause_confirmation] dropin_peer_id: " .. tostring(dropin_peer_id))
	local sender_peer = BaseNetworkHandler._verify_sender(sender)
	if not sender_peer then
		return
	end
	managers.network:session():on_drop_in_pause_confirmation_received(dropin_peer_id, sender_peer)
end
-- function ConnectionNetworkHandler:report_dead_connection(other_peer_id, sender)
-- 	local sender_peer = BaseNetworkHandler._verify_sender(sender)
-- 	if not sender_peer then
-- 		return
-- 	end
-- 	managers.network:session():on_dead_connection_reported(sender_peer:id(), other_peer_id)
-- end

function BigLobbyGlobals:dropin_progress(sender, dropin_peer_id, progress_percentage)
    log("[BigLobbyGlobals :dropin_progress] dropin_peer_id: " .. tostring(dropin_peer_id) .. ", progress: " .. tostring(progress_percentage))
	if not BaseNetworkHandler._verify_in_client_session() or not BaseNetworkHandler._verify_gamestate(BaseNetworkHandler._gamestate_filter.any_ingame) then
		return
	end
	local session = managers.network:session()
	local dropin_peer = session:peer(dropin_peer_id)
	if not dropin_peer or dropin_peer_id == session:local_peer():id() then
		return
	end
	session:on_dropin_progress_received(dropin_peer_id, progress_percentage)
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
