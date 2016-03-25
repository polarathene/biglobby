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
