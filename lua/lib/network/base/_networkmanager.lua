-- CAN REMOVE/DELETE

-- Modified to show 3 players in game on crime.net to others. Not required, but should encourage joining.
function NetworkManager:on_peer_added(peer, peer_id)
	cat_print("multiplayer_base", "NetworkManager:on_peer_added", peer, peer_id)
	if managers.hud then
		managers.menu:get_menu("kit_menu").renderer:set_slot_joining(peer, peer_id)
	end
	if Network:is_server() then
		--log("BigLobby: [NetworkManager :on_peer_added] SETTING NUM PLAYERS TO FIXED VALUE OF 3!")
		managers.network.matchmake:set_num_players(3)
		--managers.network.matchmake:set_num_players(managers.network:session():amount_of_players()) --original line
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
