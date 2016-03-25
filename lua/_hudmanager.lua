function HUDManager:add_mugshot(data)
	log("[HUDManager :add_mugshot] name: " .. tostring(data.name) .. ", peer_id: " .. tostring(data.peer_id))
	local panel_id = self:add_teammate_panel(data.character_name_id, data.name, not data.use_lifebar, data.peer_id)
	log("[HUDManager :add_mugshot] panel_id: " .. tostring(panel_id))
	log("[HUDManager :add_mugshot] criminal: " .. tostring(managers.criminals:character_data_by_name(data.character_name_id)))

	managers.criminals:character_data_by_name(data.character_name_id).panel_id = panel_id
	local last_id = self._hud.mugshots[#self._hud.mugshots] and self._hud.mugshots[#self._hud.mugshots].id or 0
	local id = last_id + 1
	table.insert(self._hud.mugshots, {
		id = id,
		character_name_id = data.character_name_id,
		peer_id = data.peer_id
	})
	return id
end

function HUDManager:add_mugshot_without_unit(char_name, ai, peer_id, name)
	log("[HUDManager :add_mugshot_without_unit] name: " .. tostring(name) .. ", peer_id: " .. tostring(peer_id))
	local character_name = name
	local character_name_id = char_name
	if not ai then
	end
	local use_lifebar = not ai
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})
	return mugshot_id
end

function HUDManager:add_mugshot_by_unit(unit)
	log("[HUDManager :add_mugshot_by_unit]")
	if unit:base().is_local_player then
		return
	end
	local character_name = unit:base():nick_name()
	local name_label_id = managers.hud:_add_name_label({name = character_name, unit = unit})
	unit:unit_data().name_label_id = name_label_id
	local is_husk_player = unit:base().is_husk_player
	local character_name_id = managers.criminals:character_name_by_unit(unit)
	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name_id then
			if is_husk_player and not data.peer_id then
				log("[HUDManager :add_mugshot_by_unit] husk_player remove_mugshot")
				self:_remove_mugshot(data.id)
				break
			else
				log("[HUDManager :add_mugshot_by_unit] player, set_mugshot_normal, char: " .. tostring(character_name))
				unit:unit_data().mugshot_id = data.id
				managers.hud:set_mugshot_normal(unit:unit_data().mugshot_id)
				managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, 1)
				managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, 1)
				return
			end
		end
	end
	local peer, peer_id
	if is_husk_player then
		peer = unit:network():peer()
		peer_id = peer:id()
	end
	log("[HUDManager :add_mugshot_by_unit] name: " .. tostring(character_name) .. ", peer_id: " .. tostring(peer_id))
	local use_lifebar = is_husk_player and true or false
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})
	unit:unit_data().mugshot_id = mugshot_id
	if peer and peer:is_cheater() then
		self:mark_cheater(peer_id)
	end
	return mugshot_id
end




function HUDManager:set_mugshot_custody(id)
	log("[HUDManager :set_mugshot_custody] id: " .. tostring(id))
	self:set_mugshot_talk(id, false)
	local data = self:_set_mugshot_state(id, "mugshot_in_custody", managers.localization:text("debug_mugshot_in_custody"))
	if data then
		local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id
		self:set_teammate_health(i, {
			current = 0,
			total = 100,
			no_hint = true
		})
		self:set_teammate_armor(i, {
			current = 0,
			total = 100,
			no_hint = true
		})
	end
end

function HUDManager:set_mugshot_armor(id, amount)
	log("[HUDManager :set_mugshot_armor] id: " .. tostring(id) .. ", amount" .. tostring(amount))
	if not id then
		return
	end
	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			log("[HUDManager :set_mugshot_armor] found match. crim name id: " .. tostring(data.character_name_id))
			log("[HUDManager :set_mugshot_armor] crim data: " .. tostring(managers.criminals:character_data_by_name(data.character_name_id)))
			log("[HUDManager :set_mugshot_armor] panel_id: " .. tostring(managers.criminals:character_data_by_name(data.character_name_id).panel_id))
			self:set_teammate_armor(managers.criminals:character_data_by_name(data.character_name_id).panel_id, {
				current = amount,
				total = 1,
				max = 1
			})
		else
		end
	end
end


function HUDManager:reset_player_hpbar()
	local crim_entry = managers.criminals:character_static_data_by_name(managers.criminals:local_character_name())
	if not crim_entry then
		return
	end
	local color_id = managers.network:session():local_peer():id()
	-- self:set_teammate_callsign(4, color_id)
	-- self:set_teammate_name(4, managers.network:session():local_peer():name())
	--Uses dynamic value
	self:set_teammate_callsign(HUDManager.PLAYER_PANEL, color_id)
	self:set_teammate_name(HUDManager.PLAYER_PANEL, managers.network:session():local_peer():name())
end
