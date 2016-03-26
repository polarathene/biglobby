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


function BaseNetworkSession:on_network_stopped()
	logger("[BaseNetworkSession: on_network_stopped]")
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- num_player_slots variable instead of hardcoded 4, handles additional peers.
	for k = 1, num_player_slots do
		self:on_drop_in_pause_request_received(k, nil, false)
		local peer = self:peer(k)
		if peer then
			peer:unit_delete()
		end
	end
	if self._local_peer then
		self:on_drop_in_pause_request_received(self._local_peer:id(), nil, false)
	end
end


function BaseNetworkSession:_get_peer_outfit_versions_str()
	logger("[BaseNetworkSession: _get_peer_outfit_versions_str]")
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	local outfit_versions_str = ""
	-- num_player_slots variable instead of hardcoded 4, handles additional peers.
	for peer_id = 1, num_player_slots do
		local peer
		if peer_id == self._local_peer:id() then
			peer = self._local_peer
		else
			peer = self._peers[peer_id]
		end
		if peer and peer:waiting_for_player_ready() then
			outfit_versions_str = outfit_versions_str .. tostring(peer_id) .. "-" .. peer:outfit_version() .. "."
		end
	end
	return outfit_versions_str
end


-- Network:clients():num_peers() may be of interest
-- function BaseNetworkSession:_has_client(peer)
-- 	logger("[BaseNetworkSession: _has_client] num_peers(): " .. tostring(Network:clients():num_peers() - 1))
--
-- 	for i = 0, Network:clients():num_peers() - 1 do
-- 		if Network:clients():ip_at_index(i) == peer:ip() then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
