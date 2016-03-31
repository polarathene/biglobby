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

-- Modified to provide all peers with a character, regardless of free characters.
function BaseNetworkSession:check_peer_preferred_character(preferred_character)
    -- Original Code --
	local free_characters = clone(CriminalsManager.character_names())
	for _, peer in pairs(self._peers_all) do
		local character = peer:character()
        if table.contains(free_characters, character) then
            table.delete(free_characters, character)
        end
	end
	local preferreds = string.split(preferred_character, " ")
	for _, preferred in ipairs(preferreds) do
		if table.contains(free_characters, preferred) then
			return preferred
		end
	end
    -- End Original Code --
    
    -- Only modification is to select a random character once all availiable characters in the game have been taken.
    if #free_characters == 0 then
        local all_characters = clone(CriminalsManager.character_names())
        local character = all_characters[math.random(#all_characters)]
        print("No free chracters left. Player will be", character, "instead of", preferred_character)
        return character
    else
        local character = free_characters[math.random(#free_characters)]
        print("Player will be", character, "instead of", preferred_character)
        return character
    end
end
