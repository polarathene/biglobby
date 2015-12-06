--Crashes if use global
--I don't particularly feel comfortable about this approach :\
--Updates colours to support UI elements for additional peers

	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()

	--override colours here, rgb values, /255 to get a 0-1 value range that game wants
	local brown = Vector3(204, 161, 102) / 255
	local green = Vector3(194, 252, 151) / 255
	local red = Vector3(178, 104, 89) / 255
	local blue = Vector3(120, 183, 204) / 255
	local pink = Vector3(255, 182, 193) / 255
	local purple = Vector3(186, 90, 186) / 255
	local team_ai = Vector3(0.2, 0.8, 1)

	tweak_data.peer_vector_colors = {
		green,
		blue,
		red,
		pink,
		brown,
		purple
	}

	--This doesn't appear to be referenced, not sure why it still exists in codebase
	tweak_data.peer_colors = {
		"mrgreen",
		"mrblue",
		"mrred",
		"mrpink",
		"mrbrown",
		"mrpurple"
	}

	-- Make sure we have enough colours to support the number of player slots, creates random colours
	if #tweak_data.peer_vector_colors < num_player_slots then
		for i = #tweak_data.peer_vector_colors, num_player_slots do
			--math.randomseed( os.time() ) --Will improve randomness of the PRNG
			local red, blue, green --rgb channels
			local random_colour
			red   = math.random(0, 255)
			green = math.random(0, 255)
			blue  = math.random(0, 255)
			random_colour = Vector3(red, green, blue) / 255

			table.insert(tweak_data.peer_vector_colors, random_colour)
			table.insert(tweak_data.peer_colors, tostring("team_colour_") .. i)
		end
	end

	--AI labels will use this
	table.insert(tweak_data.peer_vector_colors, team_ai)
	table.insert(tweak_data.peer_colors, "mrai")

	--Dynamically added now based on peer_vector_colors table
	tweak_data.chat_colors = {}
	for i = 1, #tweak_data.peer_vector_colors do
		tweak_data.chat_colors[i] = Color(tweak_data.peer_vector_colors[i]:unpack())
	end

	--These hex colours don't have to match the equivalent rgb used above, but they should be similar,
	--ai is not included as this is just for preplanning. The first ff is presumably for opacity, ff being 100% opaque
	tweak_data.preplanning_peer_colors = {
		Color("ff82991e"), --green
		Color("ff0055ff"), --blue
		Color("ffffb6c1"), --pink
		Color("ffffff00"), --yellow
		Color("ffff7800"), --red/orange, definitely orange
		Color("ffba5aba") --purple
	}


--Old version, technique only works with hoxhud enabled:
--[[
--Crashes if use global
--Updates colours to support UI elements for additional peers
orig_TweakData = orig_TweakData or {}
orig_TweakData.init = orig_TweakData.init or TweakData.init

function TweakData.init(self, ...)
	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()

	orig_TweakData.init(self, ...)

	--override colours here, rgb values, /255 to get a 0-1 value range that game wants
	local brown = Vector3(204, 161, 102) / 255
	local green = Vector3(194, 252, 151) / 255
	local red = Vector3(178, 104, 89) / 255
	local blue = Vector3(120, 183, 204) / 255
	local pink = Vector3(255, 182, 193) / 255
	local purple = Vector3(186, 90, 186) / 255
	local team_ai = Vector3(0.2, 0.8, 1)

	self.peer_vector_colors = {
		green,
		blue,
		red,
		pink,
		brown,
		purple
	}

	--This doesn't appear to be referenced, not sure why it still exists in codebase
	self.peer_colors = {
		"mrgreen",
		"mrblue",
		"mrred",
		"mrpink",
		"mrbrown",
		"mrpurple"
	}

	-- Make sure we have enough colours to support the number of player slots, creates random colours
	if #self.peer_vector_colors < num_player_slots then
		for i = #self.peer_vector_colors, num_player_slots do
			--math.randomseed( os.time() ) --Will improve randomness of the PRNG
			local red, blue, green --rgb channels
			local random_colour
			red   = math.random(0, 255)
			green = math.random(0, 255)
			blue  = math.random(0, 255)
			random_colour = Vector3(red, green, blue) / 255

			table.insert(self.peer_vector_colors, random_colour)
			table.insert(self.peer_colors, tostring("team_colour_") .. i)
		end
	end

	--AI labels will use this
	table.insert(self.peer_vector_colors, team_ai)
	table.insert(self.peer_colors, "mrai")

	--Dynamically added now based on peer_vector_colors table
	self.chat_colors = {}
	for i = 1, #self.peer_vector_colors do
		self.chat_colors[i] = Color(self.peer_vector_colors[i]:unpack())
	end

	--These hex colours don't have to match the equivalent rgb used above, but they should be similar,
	--ai is not included as this is just for preplanning. The first ff is presumably for opacity, ff being 100% opaque
	self.preplanning_peer_colors = {
		Color("ff82991e"), --green
		Color("ff0055ff"), --blue
		Color("ffffb6c1"), --pink
		Color("ffffff00"), --yellow
		Color("ffff7800"), --red/orange, definitely orange
		Color("ffba5aba") --purple
	}
end
]]
