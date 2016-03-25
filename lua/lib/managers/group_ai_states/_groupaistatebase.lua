function GroupAIStateBase:on_criminal_team_AI_enabled_state_changed()
	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1

	if Network:is_client() then
		return
	end
	if managers.groupai:state():team_ai_enabled() then
		self:fill_criminal_team_with_AI()
	else
		for i = 1, num_player_slots do
			self:remove_one_teamAI()
		end
	end
end



--debugging peer id
function GroupAIStateBase:spawn_one_teamAI(is_drop_in, char_name, spawn_on_unit)
	log("[GroupAIStateBase :spawn_one_teamAI] " .. tostring(char_name))
	if not managers.groupai:state():team_ai_enabled() or not self._ai_enabled or not managers.criminals:character_taken_by_name(char_name) and managers.criminals:nr_AI_criminals() >= managers.criminals.MAX_NR_TEAM_AI then
		return
	end
	local objective = self:_determine_spawn_objective_for_criminal_AI()
	if objective and objective.type == "follow" then
		local player = spawn_on_unit or objective.follow_unit
		local player_pos = player:position()
		local tracker = player:movement():nav_tracker()
		local spawn_pos, spawn_rot
		if (is_drop_in or spawn_on_unit) and not self:whisper_mode() then
			local spawn_fwd = player:movement():m_head_rot():y()
			mvector3.set_z(spawn_fwd, 0)
			mvector3.normalize(spawn_fwd)
			spawn_rot = Rotation(spawn_fwd, math.UP)
			spawn_pos = player_pos
			if not tracker:lost() then
				local search_pos = player_pos - spawn_fwd * 200
				local ray_params = {
					tracker_from = tracker,
					allow_entry = false,
					pos_to = search_pos,
					trace = true
				}
				local ray_hit = managers.navigation:raycast(ray_params)
				if ray_hit then
					spawn_pos = ray_params.trace[1]
				else
					spawn_pos = search_pos
				end
			end
		else
			local spawn_point = managers.network:session():get_next_spawn_point()
			spawn_pos = spawn_point.pos_rot[1]
			spawn_rot = spawn_point.pos_rot[2]
			objective.in_place = true
		end
		local character_name = char_name or managers.criminals:get_free_character_name()
		local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
		local unit_folder = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
		local ai_character_id = managers.criminals:character_static_data_by_name(character_name).ai_character_id
		local unit_name = Idstring(tweak_data.blackmarket.characters[ai_character_id].npc_unit)
		local unit = World:spawn_unit(unit_name, spawn_pos, spawn_rot)
		local xcharacter_name = json.encode({0, character_name}) --Fix peer id bug for peers 5 and up with this json string trick
		managers.network:session():send_to_peers_synched("set_unit", unit, xcharacter_name, "", 0, 0, tweak_data.levels:get_default_team_ID("player"))
		if char_name and not is_drop_in then
			log("[GroupAIStateBase :spawn_one_teamAI] criminals:set_unit")
			managers.criminals:set_unit(character_name, unit)
		else
			log("[GroupAIStateBase :spawn_one_teamAI] criminals:add_character")
			managers.criminals:add_character(character_name, unit, nil, true)
		end
		unit:movement():set_character_anim_variables()
		unit:brain():set_spawn_ai({
			init_state = "idle",
			params = {scan = true},
			objective = objective
		})
		return unit
	end
end
