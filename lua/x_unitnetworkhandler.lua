function UnitNetworkHandler:set_unit(unit, character_name, outfit_string, outfit_version, peer_id, team_id)
	log("[UnitNetworkHandler :set_unit] peer_id: " .. tostring(peer_id) .. ", character_name: " .. tostring(character_name))
	peer_id, character_name = unpack(json.decode(character_name))
	log("[UnitNetworkHandler :set_unit] UNPACKED = peer_id: " .. tostring(peer_id) .. ", character_name: " .. tostring(character_name))

	print("[UnitNetworkHandler:set_unit]", unit, character_name, peer_id)
	Application:stack_dump()
	if not alive(unit) then
		return
	end
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end
	if peer_id == 0 then --bot related?
		local crim_data = managers.criminals:character_data_by_name(character_name)
		if not crim_data or not crim_data.ai then
			log("[UnitNetworkHandler :set_unit] criminals:add_character")
			managers.criminals:add_character(character_name, unit, peer_id, true)
		else
			log("[UnitNetworkHandler :set_unit] criminals:set_unit")
			managers.criminals:set_unit(character_name, unit)
		end
		unit:movement():set_character_anim_variables()
		return
	end
	local peer = managers.network:session():peer(peer_id)
	if not peer then
		log("[UnitNetworkHandler :set_unit] peer not exist?")
		return
	end
	if peer ~= managers.network:session():local_peer() then
		peer:set_outfit_string(outfit_string, outfit_version)
	end
	peer:set_unit(unit, character_name)
	self:_chk_flush_unit_too_early_packets(unit)
end


function UnitNetworkHandler:set_armor(unit, percent, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	local peer = self._verify_sender(sender)
	local peer_id = peer:id()
	log("[UnitNetworkHandler :set_armor] peer_id: " .. tostring(peer_id))
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)
	if character_data and character_data.panel_id then
		managers.hud:set_teammate_armor(character_data.panel_id, {
			current = percent / 100,
			total = 1,
			max = 1
		})
	else
		managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, percent / 100)
	end
end
