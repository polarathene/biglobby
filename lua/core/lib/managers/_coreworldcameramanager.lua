--If this is the "logic" for this file, it's rather pointless to modify?
function CoreWorldCamera:print_points()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	for i = 1, num_player_slots do
		cat_print("debug", i, self._positions[i], self._target_positions[i])
	end
end
