--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function logger(content, use_chat)
	if log_data then
		if not content then return end
		if use_chat then
			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
		end
		-- if BigLobbyGlobals:Hook() == "pd2hook" then
		-- 	io.stdout:write(content .. "\n")
		-- else
			log(content)
		-- end
	end
end

function HostStateBase:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	print("[HostStateBase:on_join_request_received]", data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, sender:ip_at_index(0))
	logger("[HostStateBase:on_join_request_received]")
	logger("[HostStateBase:on_join_request_received] gversion: " .. tostring(gameversion))
	local my_user_id = data.local_peer:user_id() or ""
	if not managers.network.matchmake:is_server_joinable() then
		logger("[HostStateBase: on_join_request_received] PEER JOINS THE CREW!")
		self:_send_request_denied(sender, 3, my_user_id)
		return
	end
	logger("[HostStateBase: on_join_request_received] FAILED TO CONNECT!")
	self:_send_request_denied(sender, 0, my_user_id)
end

function HostStateBase:_send_request_denied(sender, reason, my_user_id)
	logger("[HostStateBase :_send_request_denied] reason: " .. tostring(reason))
	local xuid = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and managers.network.account:player_id() or ""
	sender:join_request_reply(reason, 0, "", 1, 1, 0, "", my_user_id, "", 0, 0, 0, 0, xuid, 0)
end

function HostStateBase:is_joinable(data)
	logger("[HostStateBase :is_joinable]")
	return false
end

function HostStateBase:on_peer_finished_loading(data, peer)
	logger("[HostStateBase :on_peer_finished_loading] peer: " .. tostring(peer:name()))
	if not next(peer:handshakes()) then
		self:_introduce_new_peer_to_old_peers(data, peer, false, peer:name(), peer:character(), "remove", peer:xuid(), peer:xnaddr())
		self:_introduce_old_peers_to_new_peer(data, peer)
	end
end

function HostStateBase:_introduce_old_peers_to_new_peer(data, new_peer)
	local new_peer_id = new_peer:id()
	logger("[HostStateBase :_introduce_old_peers_to_new_peer] peer: " .. tostring(new_peer:id()) .. " - " .. tostring(new_peer:name()))
	for old_pid, old_peer in pairs(data.peers) do
		if old_pid ~= new_peer_id then
			if new_peer:handshakes()[old_pid] == nil then
				logger("[HostStateBase :_introduce_old_peers_to_new_peer] introducing: " .. tostring(old_peer:id()) .. " - " .. tostring(old_peer:name()) .. " to: " .. tostring(new_peer:id()) .. " - " .. tostring(new_peer:name()))
				print("[HostStateBase:_introduce_old_peers_to_new_peer] introducing", old_pid, "to", new_peer_id)
				new_peer:send("peer_handshake", old_peer:connection_info())
				logger("[HostStateBase :_introduce_old_peers_to_new_peer] SET HANDSHAKE STATUS TO ASKED: " .. tostring(old_peer:name()) .. " to: " .. tostring(new_peer:name()))
				new_peer:set_handshake_status(old_pid, "asked")
			else
				logger("[HostStateBase :_introduce_old_peers_to_new_peer] PEER ALREADY HAD HANDSHAKE: " .. tostring(old_peer:name()) .. " to: " .. tostring(new_peer:name()))
			end
		end
	end
end

function HostStateBase:_introduce_new_peer_to_old_peers(data, new_peer, loading, peer_name, character, mask_set, xuid, xnaddr)
	logger("[HostStateBase :_introduce_new_peer_to_old_peers] peer: " .. tostring(new_peer:id()) .. " - " .. tostring(new_peer:name()))
	local new_peer_user_id = SystemInfo:platform() == Idstring("WIN32") and new_peer:user_id() or ""
	local new_peer_id = new_peer:id()
	for old_pid, old_peer in pairs(data.peers) do
		if old_pid ~= new_peer_id then
			if old_peer:handshakes()[new_peer_id] == nil then
				logger("[HostStateBase :_introduce_new_peer_to_old_peers] introducing: " .. tostring(new_peer:id()) .. " - " .. tostring(new_peer:name()) .. " to: " .. tostring(old_peer:id()) .. " - " .. tostring(old_peer:name()))
				print("[HostStateBase:_introduce_new_peer_to_old_peers] introducing", new_peer_id, "to", old_pid)

				--old_peer:send("peer_handshake", peer_name, new_peer_id, new_peer_user_id, new_peer:in_lobby(), loading, false, character, mask_set, xuid, xnaddr)
				--BLT Network message used instead, proper peerID values are being changed to 4 for peers > 4, this works around that bug
				local data = json.encode({peer_name, new_peer_id, new_peer_user_id, new_peer:in_lobby(), loading, false, character, mask_set, xuid, xnaddr})
				local Net = _G.LuaNetworking
				logger("[HostStateBase :_introduce_new_peer_to_old_peers] Sending request for handshake to peer")
				Net:SendToPeer(old_peer:id(), "client_peer_handshake", data)

				logger("[HostStateBase :_introduce_new_peer_to_old_peers] SET HANDSHAKE STATUS TO ASKED: " .. tostring(new_peer:name()) .. " to: " .. tostring(old_peer:name()))
				old_peer:set_handshake_status(new_peer_id, "asked")
			else
				logger("[HostStateBase :_introduce_new_peer_to_old_peers] peer already had handshake: " .. tostring(new_peer:name()) .. " to: " .. tostring(old_peer:name()))
			end
		end
	end
end
