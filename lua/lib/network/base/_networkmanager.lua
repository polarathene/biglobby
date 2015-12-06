function NetworkManager:on_peer_added(peer, peer_id)
	logger("[NetworkManager :on_peer_added] peer_id: " .. tostring(peer_id))
	cat_print("multiplayer_base", "NetworkManager:on_peer_added", peer, peer_id)
	if managers.hud then
		logger("[NetworkManager :on_peer_added] calling kit_menu")
		managers.menu:get_menu("kit_menu").renderer:set_slot_joining(peer, peer_id)
	end
	logger("[NetworkManager :on_peer_added] is_server check")
	if Network:is_server() then
		logger("SETTING NUM PLAYERS!")
		--managers.network.matchmake:set_num_players(3)--managers.network:session():amount_of_players())
		managers.network.matchmake:set_num_players(managers.network:session():amount_of_players())
	end
	logger("[NetworkManager :on_peer_added] platform check")
	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		managers.network.matchmake:on_peer_added(peer)
	end
	logger("[NetworkManager :on_peer_added] chat check")
	if managers.chat then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_added", {
			name = peer:name()-- .. " - OMG"
		}))
	end
	logger("[NetworkManager :on_peer_added] end ")
end

--delete all below
--[[
function NetworkManager:init_finalize()
	logger("[NetworkManager: init_finalize]")
	print("NetworkManager:init_finalize()")
	if Network:multiplayer() and not Application:editor() then
		logger("[NetworkManager: init_finalize] on_load_complete(false)")
		self._session:on_load_complete(false)
		if self._session:is_client() and not self._session:server_peer() then
			game_state_machine:current_state():on_server_left()
		end
	end
end
]]
