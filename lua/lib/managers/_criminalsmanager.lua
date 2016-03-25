--Not sure how useful this is, just updating it incase
CriminalsManager.MAX_NR_CRIMINALS = 6 --Unable to use global

--AI colour id should be the last colour in the table, replaces the old value of '5'
function CriminalsManager:character_color_id_by_unit(unit)
	local last_colour_id = #tweak_data.chat_colors

	local search_key = unit:key()
	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			if data.data.ai then
				return last_colour_id
			end
			return data.peer_id
		end
	end
end

function CriminalsManager:set_unit(name, unit)
	logger("[CriminalsManager] :set_unit - name: " .. name)
	Application:stack_dump()
	for id, data in pairs(self._characters) do
		if data.name == name then
			if not data.taken then
				Application:error("[CriminalsManager:set_character] Error: Trying to set a unit on a slot that has not been taken!")
				Application:stack_dump()
				return
			end
			data.unit = unit
			managers.hud:remove_mugshot_by_character_name(data.name)
			data.data.mugshot_id = managers.hud:add_mugshot_by_unit(unit)
			data.data.mask_obj = tweak_data.blackmarket.masks[data.static_data.ai_mask_id].unit
			data.data.mask_id = data.static_data.ai_mask_id
			data.data.mask_blueprint = nil
			if not data.data.ai then
				local mask_id = managers.network:session():peer(data.peer_id):mask_id()
				data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, data.peer_id)
				data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, data.peer_id)
				data.data.mask_blueprint = managers.network:session():peer(data.peer_id):mask_blueprint()
			end
			if unit:base().is_local_player then
				self._local_character = name
				managers.hud:reset_player_hpbar()
			end
			unit:sound():set_voice(data.static_data.voice)
		else
		end
	end
end

--debugging peer_id bug
function CriminalsManager:add_character(name, unit, peer_id, ai)
	log("[CriminalsManager :add_character] name: " .. tostring(name) .. ", peer_id: " .. tostring(peer_id))
	print("[CriminalsManager:add_character]", name, unit, peer_id, ai)
	for id, data in pairs(self._characters) do
		if data.name == name then
			if data.taken then
				Application:error("[CriminalsManager:set_character] Error: Trying to take a unit slot that has already been taken!")
				Application:stack_dump()
				Application:error("[CriminalsManager:set_character] -----")
				self:_remove(id)
			end
			data.taken = true
			data.unit = unit
			data.peer_id = peer_id
			data.data.ai = ai or false
			data.data.mask_obj = tweak_data.blackmarket.masks[data.static_data.ai_mask_id].unit
			data.data.mask_id = data.static_data.ai_mask_id
			data.data.mask_blueprint = nil
			if not ai and unit then
				local mask_id = managers.network:session():peer(peer_id):mask_id()
				data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
				data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, peer_id)
				data.data.mask_blueprint = managers.network:session():peer(peer_id):mask_blueprint()
			end
			managers.hud:remove_mugshot_by_character_name(name)
			if unit then
				data.data.mugshot_id = managers.hud:add_mugshot_by_unit(unit)
				if unit:base().is_local_player then
					self._local_character = name
					managers.hud:reset_player_hpbar()
				end
				unit:sound():set_voice(data.static_data.voice)
				unit:inventory():set_mask_visibility(unit:inventory()._mask_visibility)
			else
				if not ai or not managers.localization:text("menu_" .. name) then
				end
				log("[CriminalsManager :add_character] calling add_mugshot_without_unit() and assigning peer_id: " .. tostring(peer_id))
				data.data.mugshot_id = managers.hud:add_mugshot_without_unit(name, ai, peer_id, (managers.network:session():peer(peer_id):name()))
			end
		else
		end
	end
end


--[[
function CriminalsManager:_create_characters()
	io.stdout:write("[CriminalsManager] :_create_characters" .. "\n")
	self._characters = {}

	local name = "female_1"
	for _, character in ipairs(tweak_data.criminals.characters) do
		if(character.name == name) then
		local static_data = deep_clone(character.static_data)
		local character_data = {
			taken = false,
			name = character.name,
			unit = nil,
			peer_id = 0,
			static_data = static_data,
			data = {}
		}
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)

		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)

		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)

		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		table.insert(self._characters, character_data)
		end
	end
end

function CriminalsManager:is_taken(name)
	logger("[CriminalsManager] :is_taken - name: " .. name)
	if name=="female_1" then
		logger('Available!')
		return false
	end
	logger('Taken!')
	return true

	-- for _, data in pairs(self._characters) do
	-- 	if name == data.name then
	-- 		return data.taken
	-- 	end
	-- end
	-- return false
end

function CriminalsManager:get_free_character_name()
	logger("[CriminalsManager] :get_free_character_name")
	return "female_1"
end

-- 	local available = {}
-- 	for id, data in pairs(self._characters) do
-- 		local taken = data.taken
-- 		if not taken and not self:is_character_as_AI_level_blocked(data.name) then
-- 			table.insert(available, data.name)
-- 		end
-- 	end
-- 	if #available > 0 then
-- 		return available[math.random(#available)]
-- 	end
-- end


function CriminalsManager:add_character(name, unit, peer_id, ai)
  logger("[CriminalsManager] :add_character - name: " .. name)
  name = 'female_1'

--   for _, character in ipairs(tweak_data.criminals.characters) do
-- 	if(character.name == name) then
-- 	  logger('found: ' .. name)
-- 	  local static_data = deep_clone(character.static_data)
-- 	  local character_data = {
-- 		taken = false,
-- 		name = name,
-- 		unit = nil,
-- 		peer_id = nil,
-- 		static_data = static_data,
-- 		data = {}
-- 	  }
-- 	  table.insert(self._characters, character_data)
-- 	end
-- end
logger('continuing')

  for id, data in pairs(managers.criminals._characters) do

    if data.name == name and data.data.in_use ~= true and data.taken ~= true then
		logger('found data')
      if data.taken then
        managers.criminals:_remove(id)
      end
      data.taken = true
      data.unit = unit
      data.peer_id = peer_id
      data.data.ai = ai or false
      data.data.in_use = true
      data.data.mask_obj = tweak_data.blackmarket.masks[data.static_data.ai_mask_id].unit
      data.data.mask_id = data.static_data.ai_mask_id
      data.data.mask_blueprint = nil
      if not ai and unit then
        local mask_id = managers.network:session():peer(peer_id):mask_id()
        data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
        data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, peer_id)
        data.data.mask_blueprint = managers.network:session():peer(peer_id):mask_blueprint()
      end
	  managers.hud:remove_mugshot_by_character_name(name)
      if unit then
		  data.data.mugshot_id = managers.hud:add_mugshot_by_unit(unit)
				if unit:base().is_local_player then
					self._local_character = name
					managers.hud:reset_player_hpbar()
				end
        unit:sound():set_voice(data.static_data.voice)
        unit:inventory():set_mask_visibility(unit:inventory()._mask_visibility)
      end
      --managers.hud:remove_mugshot_by_character_name(name)
      data.data.mugshot_id = managers.hud:add_mugshot_without_unit(name, ai, peer_id, (managers.network:session():peer(peer_id):name()))
	  break
	end

  end
  logger('end function')
end
]]
