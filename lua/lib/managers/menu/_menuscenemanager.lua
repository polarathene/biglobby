--Crashes if trying to access global
function MenuSceneManager:_setup_lobby_characters()
	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()

	if self._lobby_characters then
		for _, unit in ipairs(self._lobby_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end
	self._lobby_characters = {}
	self._characters_offset = Vector3(0, -200, -130)
	self._characters_rotation = {
		-89,
		-73,
		-56,
		-106,
		-89,
		-64,
		-35,
		-115
	}
	local masks = {}
	for i = 1, num_player_slots do
		masks[i] = "dallas"
	end

	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	for i = 1, num_player_slots do
		mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[i], 0, 0)
		mvector3.set(pos, self._characters_offset)
		mvector3.rotate_with(pos, rot)
		mvector3.set(mvec, pos)
		mvector3.negate(mvec)
		mvector3.set_z(mvec, 0)
		mrotation.set_look_at(rot, mvec, math_up)
		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)
		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[ masks[i] ].unit, unit, nil, masks[i])
		table.insert(self._lobby_characters, unit)
		self:set_lobby_character_visible(i, false, true)
	end
end

function MenuSceneManager:test_show_all_lobby_characters(enable_card)
	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()()

	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	self._ti = (self._ti or 0) + 1
	self._ti = (self._ti - 1) % num_player_slots + 1
	for i = 1, num_player_slots do
		local is_me = i == self._ti
		local unit = self._lobby_characters[i]
		if unit and alive(unit) then
			if enable_card then
				self:set_character_card(i, math.random(25), unit)
			else
				local state = unit:play_redirect(Idstring("idle_menu"))
				unit:anim_state_machine():set_parameter(state, "lobby_generic_idle" .. i, 1)
			end
			mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and 4 or 0) + i], 0, 0)
			mvector3.set(pos, self._characters_offset)
			if is_me then
				mvector3.set_y(pos, mvector3.y(pos) + 100)
			end
			mvector3.rotate_with(pos, rot)
			mvector3.set(mvec, pos)
			mvector3.negate(mvec)
			mvector3.set_z(mvec, 0)
			mrotation.set_look_at(rot, mvec, math_up)
			unit:set_position(pos)
			unit:set_rotation(rot)
			local character = managers.blackmarket:equipped_character()
			local mask_blueprint = managers.blackmarket:equipped_mask().blueprint
			self:change_lobby_character(i, character)
			unit = self._lobby_characters[i]
			self:set_character_mask_by_id(managers.blackmarket:equipped_mask().mask_id, mask_blueprint, unit, i)
			self:set_character_armor(managers.blackmarket:equipped_armor(), unit)
			self:set_lobby_character_visible(i, true)
		end
	end
end

function MenuSceneManager:hide_all_lobby_characters()
	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()()

	for i = 1, num_player_slots do
		self:set_lobby_character_visible(i, false, true)
	end
end
--[[
function MenuSceneManager:set_character_mask_by_id(mask_id, blueprint, unit, peer_id)
	logger("[MenuSceneManager :set_character_mask_by_id] peer_id: " .. tostring(peer_id) .. "\n")
	if managers and managers.network and managers.network:session() then
		logger("[MenuSceneManager :set_character_mask_by_id] peer_name: " .. tostring(managers.network:session():peer(peer_id):name()) .. "\n")
	end
	logger("[MenuSceneManager :set_character_mask_by_id] mask_id: " .. tostring(mask_id) .. "\n")
	logger("[MenuSceneManager :set_character_mask_by_id] blueprint: " .. tostring(blueprint) .. "\n")
	logger("[MenuSceneManager :set_character_mask_by_id] unit: " .. tostring(unit) .. "\n")
	mask_id = managers.blackmarket:get_real_mask_id(mask_id, peer_id)
	logger("[MenuSceneManager :set_character_mask_by_id] unit_name" .. "\n")
	local unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
	self:set_character_mask(unit_name, unit, peer_id, mask_id, callback(self, self, "clbk_mask_loaded", blueprint))
	logger("[MenuSceneManager :set_character_mask_by_id] owner_unit" .. "\n")
	local owner_unit = unit or self._character_unit
	self:_check_character_mask_sequence(owner_unit, mask_id, peer_id)
end]]

--tracking a bug, delete after
function MenuSceneManager:set_character_mask(mask_name_str, unit, peer_id, mask_id, ready_clbk)
	logger("[MenuSceneManager :set_character_mask] peer_id: " .. tostring(peer_id) .. "\n")
	if managers and managers.network and managers.network:session() then
		logger("[MenuSceneManager :set_character_mask] peer_name: " .. tostring(managers.network:session():peer(peer_id):name()) .. "\n")
	end
	logger("[MenuSceneManager :set_character_mask] mask_id: " .. tostring(mask_id) .. "\n")
	logger("[MenuSceneManager :set_character_mask] unit: " .. tostring(unit) .. "\n")
	logger("[MenuSceneManager :set_character_mask] unit: " .. tostring(self._character_unit) .. "\n")
	unit = unit or self._character_unit
	local mask_name = Idstring(mask_name_str)
	local old_mask_data = self._mask_units[unit:key()]
	if old_mask_data and old_mask_data.mask_name == mask_name then
		if old_mask_data.ready then
			ready_clbk(old_mask_data.mask_unit)
		else
			old_mask_data.ready_clbk = ready_clbk
		end
		return
	end
	self:_delete_character_mask(unit)
	local mask_name_key = mask_name:key()
	local mask_data = {
		unit = unit,
		mask_unit = false,
		mask_name = mask_name,
		peer_id = peer_id,
		mask_id = mask_id,
		ready = false,
		ready_clbk = ready_clbk
	}
	self._mask_units[unit:key()] = mask_data
	managers.dyn_resource:load(Idstring("unit"), mask_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded", mask_data))
	self:_chk_character_visibility(unit)
end

--needs to support additional players?
function MenuSceneManager:character_screen_position(peer_id)
	local unit = self._lobby_characters[peer_id]
	if unit and alive(unit) then
		local is_me = peer_id == managers.network:session():local_peer():id()
		local peer_3_x_offset = 0
		if peer_id == 3 then
			peer_3_x_offset = is_me and -20 or -40
		end
		local peer_y_offset = 0
		if peer_id == 2 then
			peer_y_offset = is_me and -3 or 0
		elseif peer_id == 3 then
			peer_y_offset = is_me and -7 or 0
		elseif peer_id == 4 then
			peer_y_offset = is_me and 5 or 0
		end
		local spine_pos = unit:get_object(Idstring("Spine")):position() + Vector3(peer_3_x_offset, 0, -5 + 15 * (peer_id % 4) + peer_y_offset)
		return self._workspace:world_to_screen(self._camera_object, spine_pos)
	end
end

--instances of 4 might benefit from being increased to additional player value?
function MenuSceneManager:mouse_moved(o, x, y)
	if managers.menu_component:input_focus() == true or managers.menu_component:input_focus() == 1 then
		return false, "arrow"
	end
	if self._character_grabbed then
		self._character_yaw = self._character_yaw + (x - self._character_grabbed_current_x) / 4
		if self._use_character_pan and self._character_values and self._scene_templates and self._scene_templates[self._current_scene_template] then
			local new_z = mvector3.z(self._character_values.pos_target) - (y - self._character_grabbed_current_y) / 12
			local default_z = mvector3.z(self._scene_templates and self._scene_templates[self._current_scene_template].character_pos or self._character_values.pos_current)
			new_z = math.clamp(new_z, default_z - 20, default_z + 10)
			mvector3.set_z(self._character_values.pos_target, new_z)
		end
		self._character_unit:set_rotation(Rotation(self._character_yaw, self._character_pitch))
		self._character_grabbed_current_x = x
		self._character_grabbed_current_y = y
		return true, "grab"
	end
	if self._item_grabbed then
		if self._item_unit and alive(self._item_unit.unit) then
			local diff = (y - self._item_grabbed_current_y) / 4
			self._item_yaw = (self._item_yaw + (x - self._item_grabbed_current_x) / 4) % 360
			local yaw_sin = math.sin(self._item_yaw)
			local yaw_cos = math.cos(self._item_yaw)
			local treshhold = math.sin(45)
			if yaw_cos > -treshhold and yaw_cos < treshhold then
			else
				self._item_pitch = math.clamp(self._item_pitch + diff * yaw_cos, -30, 30)
			end
			if yaw_sin > -treshhold and yaw_sin < treshhold then
			else
				self._item_roll = math.clamp(self._item_roll - diff * yaw_sin, -30, 30)
			end
			mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
			mrotation.set_zero(self._item_rot)
			mrotation.multiply(self._item_rot, self._camera_object:rotation())
			mrotation.multiply(self._item_rot, self._item_rot_temp)
			mrotation.multiply(self._item_rot, self._item_rot_mod)
			self._item_unit.unit:set_rotation(self._item_rot)
			local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)
			self._item_unit.unit:set_position(new_pos)
			self._item_unit.unit:set_moving(2)
		end
		self._item_grabbed_current_x = x
		self._item_grabbed_current_y = y
		return true, "grab"
	elseif self._item_move_grabbed and self._item_unit and alive(self._item_unit.unit) then
		local diff_x = (x - self._item_move_grabbed_current_x) / 4
		local diff_y = (y - self._item_move_grabbed_current_y) / 4
		local move_v = Vector3(diff_x, 0, -diff_y):rotate_with(self._camera_object:rotation())
		mvector3.add(self._item_rot_pos, move_v)
		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)
		self._item_unit.unit:set_position(new_pos)
		self._item_unit.unit:set_moving(2)
		self._item_move_grabbed_current_x = x
		self._item_move_grabbed_current_y = y
		return true, "grab"
	end
	if self._use_item_grab and self._item_grab:inside(x, y) then
		return true, "hand"
	end
	if self._use_character_grab and self._character_grab:inside(x, y) then
		return true, "hand"
	end
	if self._use_character_grab2 and self._character_grab2:inside(x, y) then
		return true, "hand"
	end
end

function MenuSceneManager:set_lobby_character_out_fit(i, outfit_string, rank)
	local outfit = managers.blackmarket:unpack_outfit_from_string(outfit_string)
	local character = outfit.character
	if managers.network:session() then
		if not managers.network:session():peer(i) then
			return
		end
		character = managers.network:session():peer(i):character_id()
	end
	self:change_lobby_character(i, character)
	local unit = self._lobby_characters[i]
	local mask_blueprint = managers.blackmarket:mask_blueprint_from_outfit_string(outfit_string)
	self:set_character_mask_by_id(outfit.mask.mask_id, outfit.mask.blueprint, unit, i)
	self:set_character_armor(outfit.armor, unit)
	self:set_character_deployable(outfit.deployable, unit, i)
	self:_delete_character_weapon(unit, "all")
	local prio_item = self:_get_lobby_character_prio_item(rank, outfit)
	if prio_item == "rank" then
		self:set_character_card(i, rank, unit)
	else
		self:_select_lobby_character_pose(i, unit, outfit[prio_item])
		self:set_character_equipped_weapon(unit, outfit[prio_item].factory_id, outfit[prio_item].blueprint, "primary", outfit[prio_item].cosmetics)
	end
	local is_me = i == managers.network:session():local_peer():id()
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and 4 or 0) + i], 0, 0)
	mvector3.set(pos, self._characters_offset)
	if is_me then
		mvector3.set_y(pos, mvector3.y(pos) + 100)
	end
	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mrotation.set_look_at(rot, mvec, math_up)
	unit:set_position(pos)
	unit:set_rotation(rot)
	self:set_lobby_character_visible(i, true)
end




function MenuSceneManager:_chk_character_visibility(char_unit)
	logger("[MenuSceneManager :_chk_character_visibility]" .. "\n")
	logger("[MenuSceneManager :_chk_character_visibility] char_unit: " .. tostring(char_unit) .. "\n")
	local char_key = char_unit:key()
	logger("[MenuSceneManager :_chk_character_visibility] char_key: ".. tostring(char_key) .. "\n")
	if not self._character_visibilities[char_key] then
		logger("[MenuSceneManager :_chk_character_visibility] _set_character_and_outfit_visibility" .. "\n")
		self:_set_character_and_outfit_visibility(char_unit, false)
		logger("[MenuSceneManager :_chk_character_visibility] _set_character_and_outfit_visibility finished" .. "\n")
		return
	end
	logger("[MenuSceneManager :_chk_character_visibility] char_weapons: ".. tostring(self._weapon_units[char_key]) .. "\n")
	local char_weapons = self._weapon_units[char_key]
	if char_weapons then
		for w_type, w_data in pairs(char_weapons) do
			if not w_data.assembly_complete then
				self:_set_character_and_outfit_visibility(char_unit, false)
				return
			end
		end
	end
	logger("[MenuSceneManager :_chk_character_visibility] char_mask: ".. tostring(self._mask_units[char_key]) .. "\n")
	local char_mask = self._mask_units[char_key]
	if char_mask and not char_mask.mask_unit then
		self:_set_character_and_outfit_visibility(char_unit, false)
		return
	end
	logger("[MenuSceneManager :_chk_character_visibility] self._character_unit: " .. tostring(self._character_unit) .. "\n")
	if char_unit == self._character_unit then
		logger("[MenuSceneManager :_chk_character_visibility] check 1" .. "\n")
		if self._character_unit_need_pose then
			logger("[MenuSceneManager :_chk_character_visibility] check 1.1" .. "\n")
			self:_set_character_and_outfit_visibility(char_unit, false)
			return
		end
		if self._current_scene_template ~= "" and not self._scene_templates[self._current_scene_template].character_visible then
			logger("[MenuSceneManager :_chk_character_visibility] check 1.2" .. "\n")
			self:_set_character_and_outfit_visibility(char_unit, false)
			return
		end
		logger("[MenuSceneManager :_chk_character_visibility] check 2" .. "\n")
	elseif self._current_scene_template ~= "" and not self._scene_templates[self._current_scene_template].lobby_characters_visible then
		logger("[MenuSceneManager :_chk_character_visibility] check 3" .. "\n")
		self:_set_character_and_outfit_visibility(char_unit, false)
		return
	end
	logger("[MenuSceneManager :_chk_character_visibility] check 4" .. "\n")
	self:_set_character_and_outfit_visibility(char_unit, true)
end

function MenuSceneManager:_character_unit_pose_updated()
	logger("[MenuSceneManager :_character_unit_pose_updated]" .. "\n")
	self._character_unit_need_pose = false
	self:_chk_character_visibility(self._character_unit)
end

function MenuSceneManager:set_lobby_character_visible(i, visible, no_state)
	logger("[MenuSceneManager :set_lobby_character_visible]" .. "\n")
	local unit = self._lobby_characters[i]
	self._character_visibilities[unit:key()] = visible
	if not visible then
		self._deployable_equipped[i] = nil
	end
	self:_chk_character_visibility(unit)
	if self._current_profile_slot == i then
		managers.menu_component:close_lobby_profile_gui()
		self._current_profile_slot = 0
	end
end

function MenuSceneManager:set_character_mask(mask_name_str, unit, peer_id, mask_id, ready_clbk)
	local ids_unit = Idstring("unit")
	logger("[MenuSceneManager :set_character_mask]" .. "\n")
	unit = unit or self._character_unit
	local mask_name = Idstring(mask_name_str)
	local old_mask_data = self._mask_units[unit:key()]
	if old_mask_data and old_mask_data.mask_name == mask_name then
		if old_mask_data.ready then
			ready_clbk(old_mask_data.mask_unit)
		else
			old_mask_data.ready_clbk = ready_clbk
		end
		return
	end
	self:_delete_character_mask(unit)
	local mask_name_key = mask_name:key()
	local mask_data = {
		unit = unit,
		mask_unit = false,
		mask_name = mask_name,
		peer_id = peer_id,
		mask_id = mask_id,
		ready = false,
		ready_clbk = ready_clbk
	}
	self._mask_units[unit:key()] = mask_data
	managers.dyn_resource:load(ids_unit, mask_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded", mask_data))
	self:_chk_character_visibility(unit)
end

function MenuSceneManager:clbk_mask_unit_loaded(mask_data_param, status, asset_type, asset_name)
	logger("[MenuSceneManager :clbk_mask_unit_loaded]" .. "\n")
	if not alive(mask_data_param.unit) then
		return
	end
	local mask_data = self._mask_units[mask_data_param.unit:key()]
	if mask_data ~= mask_data_param then
		return
	end
	if mask_data.ready or asset_name ~= mask_data.mask_name then
		return
	end
	local mask_align = mask_data.unit:get_object(Idstring("Head"))
	local mask_unit = self:_spawn_mask(mask_data.mask_name, false, mask_align:position(), mask_align:rotation(), mask_data.mask_id)
	mask_data.mask_unit = mask_unit
	mask_data.ready = true
	mask_data.unit:link(mask_align:name(), mask_unit, mask_unit:orientation_object():name())
	self:_chk_character_visibility(mask_data.unit)
	if mask_data.ready_clbk then
		mask_data.ready_clbk(mask_unit)
		mask_data.ready_clbk = nil
	end
end

function MenuSceneManager:set_character_equipped_weapon(unit, factory_id, blueprint, type, cosmetics)
	local ids_unit = Idstring("unit")
	logger("[MenuSceneManager :set_character_equipped_weapon]" .. "\n")
	unit = unit or self._character_unit
	self:_delete_character_weapon(unit, type)
	if factory_id then
		local factory_weapon = tweak_data.weapon.factory[factory_id]
		local ids_unit_name = Idstring(factory_weapon.unit)
		self._weapon_units[unit:key()] = self._weapon_units[unit:key()] or {}
		self._weapon_units[unit:key()][type] = {
			unit = false,
			name = ids_unit_name,
			assembly_complete = false
		}
		local clbk = callback(self, self, "clbk_weapon_base_unit_loaded", {
			owner = unit,
			factory_id = factory_id,
			blueprint = blueprint,
			cosmetics = cosmetics,
			type = type
		})
		managers.dyn_resource:load(ids_unit, ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, clbk)
	end
	self:_chk_character_visibility(unit)
end

function MenuSceneManager:clbk_weapon_base_unit_loaded(params, status, asset_type, asset_name)
	local null_vector = Vector3()
	logger("[MenuSceneManager :clbk_weapon_base_unit_loaded]" .. "\n")
	print("[MenuSceneManager:clbk_weapon_base_unit_loaded]", inspect(params), status, asset_type, asset_name)
	local owner = params.owner
	if not alive(owner) then
		return
	end
	local owner_weapon_data = self._weapon_units[owner:key()]
	if not owner_weapon_data or not owner_weapon_data[params.type] or owner_weapon_data[params.type].unit or owner_weapon_data[params.type].name ~= asset_name then
		return
	end
	owner_weapon_data = owner_weapon_data[params.type]
	local weapon_unit = World:spawn_unit(asset_name, null_vector, self.null_rotation)
	owner_weapon_data.unit = weapon_unit
	weapon_unit:base():set_npc(true)
	weapon_unit:base():set_factory_data(params.factory_id)
	weapon_unit:base():set_cosmetics_data(params.cosmetics)
	if params.blueprint then
		weapon_unit:base():assemble_from_blueprint(params.factory_id, params.blueprint, nil, callback(self, self, "clbk_weapon_assembly_complete", params))
	else
		weapon_unit:base():assemble(params.factory_id)
	end
	local align_name = params.type == "primary" and Idstring("a_weapon_right_front") or Idstring("a_weapon_left_front")
	owner:link(align_name, weapon_unit, weapon_unit:orientation_object():name())
	self:_select_character_pose()
	self:_chk_character_visibility(owner)
end

function MenuSceneManager:clbk_weapon_assembly_complete(params)
	logger("[MenuSceneManager :clbk_weapon_base_unit_loaded]" .. "\n")
	local owner = params.owner
	if not alive(owner) then
		return
	end
	local owner_weapon_data = self._weapon_units[owner:key()]
	if not owner_weapon_data or not owner_weapon_data[params.type] or owner_weapon_data[params.type].assembly_complete then
		return
	end
	owner_weapon_data[params.type].assembly_complete = true
	self:_chk_character_visibility(owner)
end

function MenuSceneManager:set_scene_template(template, data, custom_name, skip_transition)
	logger("[MenuSceneManager :set_scene_template]" .. "\n")
	if not skip_transition and (self._current_scene_template == template or self._current_scene_template == custom_name) then
		return
	end
	local template_data
	if not skip_transition then
		managers.menu_component:play_transition()
		self._fov_mod = 0
		self._camera_object:set_fov(self._current_fov + (self._fov_mod or 0))
		template_data = data or self._scene_templates[template]
		self._current_scene_template = custom_name or template
		self._character_values = self._character_values or {}
		if template_data.character_pos then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()
			mvector3.set(self._character_values.pos_current, template_data.character_pos)
		elseif self._character_values.pos_target then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()
			mvector3.set(self._character_values.pos_current, self._character_values.pos_target)
		end
		local set_character_position = false
		if template_data.character_pos then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()
			mvector3.set(self._character_values.pos_target, template_data.character_pos)
			set_character_position = true
		elseif self._character_values.pos_current then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()
			mvector3.set(self._character_values.pos_target, self._character_values.pos_current)
			set_character_position = true
		end
		if set_character_position and self._character_values.pos_target then
			self._character_unit:set_position(self._character_values.pos_target)
		end
		self:_chk_character_visibility(self._character_unit)
		logger("[MenuSceneManager :set_scene_template] 2" .. "\n")
		self:_chk_complete_overkill_pack_safe_visibility()
		if self._lobby_characters then
			for _, unit in pairs(self._lobby_characters) do
				self:_chk_character_visibility(unit)
			end
		end
		self:_use_environment(template_data.environment or "standard")
		self:post_ambience_event(template_data.ambience_event or "menu_main_ambience")
		self._camera_values.camera_pos_current = self._camera_values.camera_pos_target
		self._camera_values.target_pos_current = self._camera_values.target_pos_target
		self._camera_values.fov_current = self._camera_values.fov_target
		if self._transition_time then
			self:dispatch_transition_done()
		end
		self._transition_time = 1
		self._camera_values.camera_pos_target = template_data.camera_pos or self._camera_values.camera_pos_current
		self._camera_values.target_pos_target = template_data.target_pos or self._camera_values.target_pos_current
		self._camera_values.fov_target = template_data.fov or self._standard_fov
		self:_release_item_grab()
		self:_release_character_grab()
		self._use_item_grab = template_data.use_item_grab
		self._use_character_grab = template_data.use_character_grab
		self._use_character_grab2 = template_data.use_character_grab2
		self._use_character_pan = template_data.use_character_pan
		self._disable_rotate = template_data.disable_rotate or false
		self._disable_item_updates = template_data.disable_item_updates or false
		self._can_change_fov = template_data.can_change_fov or false
		self._can_move_item = template_data.can_move_item or false
		self._change_fov_sensitivity = template_data.change_fov_sensitivity or 1
		self._characters_deployable_visible = template_data.characters_deployable_visible or false
		self:set_character_deployable(Global.player_manager.kit.equipment_slots[1], false, 0)
		if template_data.remove_infamy_card and self._card_units and self._card_units[self._character_unit:key()] then
			local secondary = managers.blackmarket:equipped_secondary()
			if secondary then
				self:set_character_equipped_weapon(nil, secondary.factory_id, secondary.blueprint, "secondary", secondary.cosmetics)
			end
		end
		self:_select_character_pose()
		if alive(self._menu_logo) then
			self._menu_logo:set_visible(not template_data.hide_menu_logo)
		end
	end
	if template_data and template_data.upgrade_object then
		self._temp_upgrade_object = template_data.upgrade_object
		self:_set_item_offset(template_data.upgrade_object:oobb())
	elseif self._use_item_grab and self._item_unit then
		if self._item_unit.unit then
			managers.menu_scene:_set_weapon_upgrades(self._current_weapon_id)
			self:_set_item_offset(self._current_item_oobb_object:oobb())
		else
			self._item_unit.scene_template = {
				template = template,
				data = data,
				custom_name = custom_name
			}
		end
	end
	if not skip_transition then
		local fade_lights = {}
		for _, light in ipairs(self._fade_down_lights) do
			if light:multiplier() ~= 0 and template_data.lights and not table.contains(template_data.lights, light) then
				table.insert(fade_lights, light)
			end
		end
		for _, light in ipairs(self._active_lights) do
			table.insert(fade_lights, light)
		end
		self._fade_down_lights = fade_lights
		self._active_lights = {}
		if template_data.lights then
			for _, light in ipairs(template_data.lights) do
				light:set_enable(true)
				table.insert(self._active_lights, light)
			end
		end
	end
	managers.network.account:inventory_load()
end

function MenuSceneManager:_chk_complete_overkill_pack_safe_visibility()
	if not alive(self._complete_overkill_pack_safe) then
		return
	end
	self._complete_overkill_pack_safe:set_visible(self._scene_templates[self._current_scene_template].complete_overkill_pack_safe_visible)
end
