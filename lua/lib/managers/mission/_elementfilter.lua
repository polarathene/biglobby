-- CloneClass to keep pristine versions of the original functions in a sub-table
CloneClass(ElementFilter)

-- This function must be modified to allow for proper objective activation with greater than 4 players
function ElementFilter._check_players(self)

    -- Original Code --
	local players = Global.running_simulation and managers.editor:mission_player()
	players = players or managers.network:session() and managers.network:session():amount_of_players()
	if not players then
		return false
	end
    -- End Original Code --

    -- Check for >4 players for objective activation fixing
    if self._values.player_4 and players >= 4 then
		return true
	end

	-- Call the original function and return its value if the code above does not return anything
	return self.orig._check_players(self)
end
