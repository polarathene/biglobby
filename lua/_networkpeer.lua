function NetworkPeer:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
	if self._unit then
		return
	end
	if not self:synched() then
		return
	end
	self._spawn_unit_called = true
	local pos_rot
	if is_drop_in then
		pos_rot = managers.criminals:get_valid_player_spawn_pos_rot()
		if not pos_rot then
			local spawn_point = managers.network:session():get_next_spawn_point() or managers.network:spawn_point(1)
			pos_rot = spawn_point.pos_rot
		end
	else
		pos_rot = managers.network:spawn_point(spawn_point_id).pos_rot
	end
	local member_downed, member_dead, health, used_deployable, used_cable_ties, used_body_bags, hostages_killed, respawn_penalty, old_plr_entry = self:_get_old_entry()
	if old_plr_entry then
		old_plr_entry.member_downed = nil
		old_plr_entry.member_dead = nil
		old_plr_entry.hostages_killed = nil
		old_plr_entry.respawn_penalty = nil
	end
	local character_name = self:character()
	local trade_entry, spawn_in_custody
	print("[NetworkPeer:spawn_unit] Member assigned as", character_name)
	local old_unit
	trade_entry, old_unit = managers.groupai:state():remove_one_teamAI(character_name, member_downed or member_dead)
	if trade_entry and member_dead then
		trade_entry.peer_id = self._id
	end
	local has_old_unit = alive(old_unit)
	local ai_is_downed = false
	if alive(old_unit) then
		ai_is_downed = old_unit:character_damage():bleed_out() or old_unit:character_damage():fatal() or old_unit:character_damage():arrested() or old_unit:character_damage():need_revive() or old_unit:character_damage():dead()
		World:delete_unit(old_unit)
	end
	spawn_in_custody = (member_downed or member_dead) and (trade_entry or ai_is_downed or not trade_entry and not has_old_unit)
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_name_suffix = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	local is_local_peer = self._id == managers.network:session():local_peer():id()
	local unit_name = Idstring(tweak_data.blackmarket.characters[self:character_id()].fps_unit)
	local unit
	if is_local_peer then
		unit = World:spawn_unit(unit_name, pos_rot[1], pos_rot[2])
	else
		unit = Network:spawn_unit_on_client(self:rpc(), unit_name, pos_rot[1], pos_rot[2])
	end
	local team_id = tweak_data.levels:get_default_team_ID("player")
	self:set_unit(unit, character_name, team_id)
	log("[NetworkPeer :spawn_unit] set_unit()network call. character_name: " .. tostring(character_name) .. ", peer_id: " .. tostring(self._id))
	character_name = json.encode({self._id, character_name}) --Fix peer id bug for peers 5 and up with this json string trick
	managers.network:session():send_to_peers_synched("set_unit", unit, character_name, self:profile().outfit_string, self:outfit_version(), self._id, team_id)
	if is_local_peer then
		unit:character_damage():send_set_status()
	end
	if is_drop_in then
		managers.groupai:state():set_dropin_hostages_killed(unit, hostages_killed, respawn_penalty)
		self:set_used_deployable(used_deployable)
		self:set_used_body_bags(used_body_bags)
		if is_local_peer then
			managers.player:spawn_dropin_penalty(spawn_in_custody, spawn_in_custody, health, used_deployable, used_cable_ties, used_body_bags)
		else
			self:send_queued_sync("spawn_dropin_penalty", spawn_in_custody, spawn_in_custody, health, used_deployable, used_cable_ties, used_body_bags)
		end
	end
	local vehicle = managers.vehicle:find_active_vehicle_with_player()
	if vehicle and not spawn_in_custody then
		Application:debug("[NetworkPeer] Spawning peer_id in vehicle, peer_id:" .. self._id)
		managers.player:server_enter_vehicle(vehicle, self._id, unit)
	end
	return unit
end

function NetworkPeer:set_unit(unit, character_name, team_id)
	log("[NetworkPeer:set_unit] peer_id: " .. tostring(self:id()))
	local is_new_unit = unit and (not self._unit or self._unit:key() ~= unit:key())
	self._unit = unit
	if is_new_unit and self._id == managers.network:session():local_peer():id() then
		managers.player:spawned_player(1, unit)
	end
	if is_new_unit then
		unit:inventory():set_melee_weapon_by_peer(self)
	end
	if unit then
		if managers.criminals:character_peer_id_by_name(character_name) == self:id() then
			log("[NetworkPeer:set_unit] criminals:set_unit")
			managers.criminals:set_unit(character_name, unit)
		else
			if managers.criminals:is_taken(character_name) then
				managers.criminals:remove_character_by_name(character_name)
			end
			log("[NetworkPeer:set_unit] criminals:add_character")
			managers.criminals:add_character(character_name, unit, self:id(), false)
		end
	end
	if is_new_unit then
		unit:movement():set_team(managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player")))
		self._equipped_armor_id = nil
		self:_update_equipped_armor()
		if unit:damage() then
			local sequence = managers.blackmarket:character_sequence_by_character_id(self:character_id(), self:id())
			unit:damage():run_sequence_simple(sequence)
		end
		unit:movement():set_character_anim_variables()
	end
end


function NetworkPeer:set_synched(state)
	log("[NetworkPeer :set_synched] state: " .. tostring(state) .. "peer: " .. tostring(self:id()) .. " - " .. tostring(self:name()))
	if state and self.chk_timeout == self.pre_handshake_chk_timeout then
		self._default_timeout_check_reset = TimerManager:wall():time() + NetworkPeer.PRE_HANDSHAKE_CHK_TIME
	end
	self._synced = state
	if state then
		self._syncing = false
	end
	self:_chk_flush_msg_queues()
end

function NetworkPeer:set_synched_soft(state)
	log("[NetworkPeer :set_synched_soft] state: " .. tostring(state))
	self._synced = state
	self:_chk_flush_msg_queues()
end

function NetworkPeer:send(func_name, ...)

--peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
if func_name == "peer_handshake" then
	local args = {...}
	local data = json.encode(args)

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] peer_handshake, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "peer_handshake", data)

	return
end

	if func_name == "set_member_ready" then
		local args = {...}
		--params(peer_id, ready, mode, outfit_versions_str, sender)
		args[4] = json.encode({args[1], args[2], args[3], args[4]})

		local Net = _G.LuaNetworking
		logger("[NetworkPeer :send] set_member_ready, data: " .. tostring(args[4]))
		Net:SendToPeer(self:id(), "set_member_ready", args[4])

		return
	end

	--peer_exchange_info(peer_id, sender)
	if func_name == "peer_exchange_info" then
	local args = {...}
	local data = json.encode({args[1]})

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] peer_exchange_info, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "peer_exchange_info", data)

return
	end

	if func_name == "connection_established" then
	local args = {...}
	local data = json.encode({args[1]})

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] connection_established, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "connection_established", data)

	return
	end

	if func_name == "mutual_connection" then
	local args = {...}
	local data = json.encode({args[1]})

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] mutual_connection, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "mutual_connection", data)

	return
	end

	if func_name == "set_peer_synched" then
	local args = {...}
	local data = json.encode({args[1]})

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] set_peer_synched, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "set_peer_synched", data)

	return
	end

	--request_drop_in_pause(peer_id, nickname, state, sender)
	if func_name == "request_drop_in_pause" then
	local args = {...}
	local data = json.encode(args)

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] request_drop_in_pause, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "request_drop_in_pause", data)

	return
	end

	--drop_in_pause_confirmation(dropin_peer_id, sender)
	if func_name == "drop_in_pause_confirmation" then
	local args = {...}
	local data = json.encode(args)

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] drop_in_pause_confirmation, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "drop_in_pause_confirmation", data)

	return
	end

	--dropin_progress(dropin_peer_id, progress_percentage, sender)
	if func_name == "dropin_progress" then
	local args = {...}
	local data = json.encode(args)

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :send] dropin_progress, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "dropin_progress", data)

	return
	end


	if not self._ip_verified then
		debug_pause("[NetworkPeer:send] ip unverified:", func_name, ...)
		return
	end
	local rpc = self._rpc
	rpc[func_name](rpc, ...)
	local send_resume = Network:get_connection_send_status(rpc)
	if send_resume then
		local nr_queued_packets = 0
		for delivery_type, amount in pairs(send_resume) do
			nr_queued_packets = nr_queued_packets + amount
			if nr_queued_packets > 100 and send_resume.unreliable then
				print("[NetworkPeer:send] dropping unreliable packets", send_resume.unreliable)
				Network:drop_unreliable_packets_for_connection(rpc)
			else
			end
		end
	end
end
function NetworkPeer:_send_queued(queue_name, func_name, ...)

--peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
if func_name == "peer_handshake" then
	local args = {...}
	local data = json.encode(args)

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :_send_queued] peer_handshake, data: " .. tostring(data))
	Net:SendToPeer(self:id(), "peer_handshake", data)

	return
end


if func_name == "set_member_ready" then
	local args = {...}
	--params(peer_id, ready, mode, outfit_versions_str, sender)
	args[4] = json.encode({args[1], args[2], args[3], args[4]})

	local Net = _G.LuaNetworking
	logger("[NetworkPeer :_send_queued] set_member_ready, data: " .. tostring(args[4]))
	Net:SendToPeer(self:id(), "set_member_ready", args[4])

	return
end

--peer_exchange_info(peer_id, sender)
if func_name == "peer_exchange_info" then
local args = {...}
local data = json.encode({args[1]})

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] peer_exchange_info, data: " .. tostring(data))
Net:SendToPeer(self:id(), "peer_exchange_info", data)

return
end

if func_name == "connection_established" then
local args = {...}
local data = json.encode({args[1]})

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] connection_established, data: " .. tostring(data))
Net:SendToPeer(self:id(), "connection_established", data)

return
end

if func_name == "mutual_connection" then
local args = {...}
local data = json.encode({args[1]})

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] mutual_connection, data: " .. tostring(data))
Net:SendToPeer(self:id(), "mutual_connection", data)

return
end

if func_name == "set_peer_synched" then
local args = {...}
local data = json.encode({args[1]})

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] set_peer_synched, data: " .. tostring(data))
Net:SendToPeer(self:id(), "set_peer_synched", data)

return
end

--request_drop_in_pause(peer_id, nickname, state, sender)
if func_name == "request_drop_in_pause" then
local args = {...}
local data = json.encode(args)

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] request_drop_in_pause, data: " .. tostring(data))
Net:SendToPeer(self:id(), "request_drop_in_pause", data)

return
end

----drop_in_pause_confirmation(dropin_peer_id, sender)
if func_name == "drop_in_pause_confirmation" then
local args = {...}
local data = json.encode(args)

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] drop_in_pause_confirmation, data: " .. tostring(data))
Net:SendToPeer(self:id(), "drop_in_pause_confirmation", data)

return
end

----dropin_progress(dropin_peer_id, progress_percentage, sender)
if func_name == "dropin_progress" then
local args = {...}
local data = json.encode(args)

local Net = _G.LuaNetworking
logger("[NetworkPeer :_send_queued] dropin_progress, data: " .. tostring(data))
Net:SendToPeer(self:id(), "dropin_progress", data)

return
end

	if self._msg_queues and self._msg_queues[queue_name] then
		self:_push_to_queue(queue_name, func_name, ...)
	else
		local overwrite_data = self._overwriteable_msgs[func_name]
		if overwrite_data then
			overwrite_data.clbk(overwrite_data, self._overwriteable_queue, func_name, ...)
			return
		end
		self:send(func_name, ...)
	end
end
