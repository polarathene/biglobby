-- Not sure if this is referencing team size, it also seems to just be for debug,
-- Thus not really needed for this mod.
function CoreWorldCamera:print_points()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for i = 1, num_player_slots do
		cat_print("debug", i, self._positions[i], self._target_positions[i])
	end
end
