-- Modified to support additional player slots in the mission briefing screen.
-- Instead of overriding methods, I am now hooking them and continuiing the loop
-- to handle >4 peers.
local orig__MenuLobbyRenderer = {
	open = MenuLobbyRenderer.open
}


function MenuLobbyRenderer:open(...)
	orig__MenuLobbyRenderer.open(self, ...)

	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for i = 5, num_player_slots do
		local t = {}
		t.player = {}
		t.free = true
		t.kit_slots = {}
		t.params = {}
		for slot = 1, PlayerManager.WEAPON_SLOTS + 3 do
			table.insert(t.kit_slots, slot)
		end
		table.insert(self._player_slots, t)
	end
end
