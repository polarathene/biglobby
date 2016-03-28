-- Modified to support additional peers.
function BaseNetworkSession:on_network_stopped()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
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


-- Modified to support additional peers.
function BaseNetworkSession:_get_peer_outfit_versions_str()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	local outfit_versions_str = ""
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
