-- CAN REMOVE/DELETE

-- Modified to alter the display of player count in lobbies
function NetworkManager:on_peer_added(peer, peer_id)
	cat_print("multiplayer_base", "NetworkManager:on_peer_added", peer, peer_id)
	if managers.hud then
		managers.menu:get_menu("kit_menu").renderer:set_slot_joining(peer, peer_id)
	end
	if Network:is_server() then
		-- Change the crime.net display to show the % of players relative to the lobby size set by host.
		local ratio = managers.network:session():amount_of_players() / BigLobbyGlobals:num_player_slots()
		local ratio_to_icon = math.ceil(4 * ratio)
		-- Ensure the value is at minimum 1
		if ratio_to_icon <= 1 then ratio_to_icon = 1 end

		managers.network.matchmake:set_num_players( ratio_to_icon )
	end
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		managers.network.matchmake:on_peer_added(peer)
	end
	if managers.chat then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_added", {
			name = peer:name()
		}))
	end
end


-- Adds two new handlers for network messages to handle the `biglobby__` prefix modifications.
local orig__NetworkManager = {}
orig__NetworkManager.start_network = NetworkManager.start_network
function NetworkManager:start_network()
	if not self._started then
		self:register_handler("biglobby__connection", BigLobby__ConnectionNetworkHandler)
		self:register_handler("biglobby__unit", BigLobby__UnitNetworkHandler)
	end
	orig__NetworkManager.start_network(self)
end
