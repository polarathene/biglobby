-- TODO: I'm not sure exactly what these functions are doing and if their hardcoded 4
-- should have been overriden by the player count. May want to remove on release
-- and restore from old commit if needed?

-- Seems to affect the contract UI in lobby screen when Host chooses/changes the contract
function MenuComponentManager:create_contract_gui()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	-- And a quick fix for a decompile error
	self:close_contract_gui()
	self._contract_gui = ContractBoxGui:new(self._ws, self._fullscreen_ws)

	--[[
	if not managers.menu:get_all_peers_state() then
		local peers_state = {}
	end
	]]
	-- Above version is what the codebase changed to some time ago, obviously broke
	-- and doesn't make sense, corrected here:
	local peers_state = managers.menu:get_all_peers_state() or {}

	for i = 1, num_player_slots do
		self._contract_gui:update_character_menu_state(i, peers_state[i])
	end
end


function MenuComponentManager:show_contract_character(state)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	if self._contract_gui then
		for i = 1, num_player_slots do
			self._contract_gui:set_character_panel_alpha(i, state and 1 or 0.4)
		end
	end
end
