--Use global version later? Possible issue with gtrace in some instances
-- local log_data = true
-- function xlogger(content, use_chat)
-- 	if log_data then
-- 		if not content then return end
-- 		if use_chat then
-- 			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
-- 		end
-- 		--io.stdout:write(content .. "\n")
-- 		log(content) --BLT support
-- 	end
-- end


function NetworkMatchMakingSTEAM:join_server(room_id, skip_showing_dialog)
	if not skip_showing_dialog then
		managers.menu:show_joining_lobby_dialog()
	end
	local function f(result, handler)
		print("[NetworkMatchMakingSTEAM:join_server:f]", result, handler)
		managers.system_menu:close("join_server")
		if result == "success" then
			print("Success!")
			self.lobby_handler = handler
			local _, host_id, owner = self.lobby_handler:get_server_details()
			print("[NetworkMatchMakingSTEAM:join_server] server details", _, host_id)
			print("Gonna handshake now!")
			self._server_rpc = Network:handshake(host_id:tostring(), nil, "STEAM")
			print("Handshook!")
			print("Server RPC:", self._server_rpc and self._server_rpc:ip_at_index(0))
			if not self._server_rpc then
				return
			end
			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
			managers.network:start_client()
			managers.menu:show_waiting_for_server_response({
				cancel_func = function()
					managers.network:session():on_join_request_cancelled()
				end
			})
			local joined_game = function(res, level_index, difficulty_index, state_index)
				managers.system_menu:close("waiting_for_server_response")
				print("[NetworkMatchMakingSTEAM:join_server:joined_game]", res, level_index, difficulty_index, state_index)
				if res == "JOINED_LOBBY" then
					MenuCallbackHandler:crimenet_focus_changed(nil, false)
					managers.menu:on_enter_lobby()
				elseif res == "JOINED_GAME" then
					local level_id = tweak_data.levels:get_level_name_from_index(level_index)
					Global.game_settings.level_id = level_id
					managers.network:session():local_peer():set_in_lobby(false)
				elseif res == "KICKED" then
					logger("GOT KICKED :(")
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_peer_kicked_dialog()
				elseif res == "TIMED_OUT" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_request_timed_out_dialog()
				elseif res == "GAME_STARTED" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_game_started_dialog()
				elseif res == "DO_NOT_OWN_HEIST" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_does_not_own_heist()
				elseif res == "CANCELLED" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
				elseif res == "FAILED_CONNECT" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_failed_joining_dialog()
				elseif res == "GAME_FULL" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_game_is_full()
				elseif res == "LOW_LEVEL" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_too_low_level()
				elseif res == "WRONG_VERSION" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_wrong_version_message()
				elseif res == "AUTH_FAILED" or res == "AUTH_HOST_FAILED" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					Global.on_remove_peer_message = res == "AUTH_HOST_FAILED" and "dialog_authentication_host_fail" or "dialog_authentication_fail"
					managers.menu:show_peer_kicked_dialog()
				else
					Application:error("[NetworkMatchMakingSTEAM:join_server] FAILED TO START MULTIPLAYER!", res)
				end
			end
			managers.network:join_game_at_host_rpc(self._server_rpc, joined_game)
		else
			managers.menu:show_failed_joining_dialog()
			self:search_lobby(self:search_friends_only())
		end
	end
	Steam:join_lobby(room_id, f)
end



NetworkMatchMakingSTEAM.OPEN_SLOTS = 6--4
--NetworkMatchMakingSTEAM.GAMEVERSION = 53770 --53770=`hello` or could use NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY .. "-biglobby"
function NetworkMatchMakingSTEAM:create_lobby(settings)
	self._num_players = nil
	local dialog_data = {}
	dialog_data.title = managers.localization:text("dialog_creating_lobby_title")
	dialog_data.text = managers.localization:text("dialog_wait")
	dialog_data.id = "create_lobby"
	dialog_data.no_buttons = true
	managers.system_menu:show(dialog_data)
	local function f(result, handler)
		print("Create lobby callback!!", result, handler)
		if result == "success" then
			self.lobby_handler = handler
			self:set_attributes(settings)
			self.lobby_handler:publish_server_details()
			self._server_joinable = true
			self.lobby_handler:set_joinable(true)
			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
			managers.system_menu:close("create_lobby")
			managers.menu:created_lobby()
		else
			managers.system_menu:close("create_lobby")
			local title = managers.localization:text("dialog_error_title")
			local dialog_data = {
				title = title,
				text = managers.localization:text("dialog_err_failed_creating_lobby")
			}
			dialog_data.button_list = {
				{
					text = managers.localization:text("dialog_ok")
				}
			}
			managers.system_menu:show(dialog_data)
		end
	end
	logger("[NetworkMatchMakingSTEAM:create_lobby] open_slots: " .. tostring(NetworkMatchMakingSTEAM.OPEN_SLOTS))
	return Steam:create_lobby(f, NetworkMatchMakingSTEAM.OPEN_SLOTS, "invisible")
end
