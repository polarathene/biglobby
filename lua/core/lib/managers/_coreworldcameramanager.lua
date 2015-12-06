--If this is the "logic" for this file, it's rather pointless to modify?
function CoreWorldCamera:print_points()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	for i = 1, num_player_slots do
		cat_print("debug", i, self._positions[i], self._target_positions[i])
	end
end


--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function logger(content)
	if log_data then
		if not content then return end
		--io.stdout:write(content .. "\n")
		log(content .. "\n") --BLT support
	end
end
