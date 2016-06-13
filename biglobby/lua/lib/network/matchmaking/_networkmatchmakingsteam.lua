-- Used in `NetworkMatchMakingSTEAM:create_lobby(settings)` when calling `Steam:create_lobby(f, NetworkMatchMakingSTEAM.OPEN_SLOTS, "invisible")`
-- If not adjusted to new player limit will prevent Steam allowing a connection, failing it.
NetworkMatchMakingSTEAM.OPEN_SLOTS = BigLobbyGlobals:num_player_slots()

-- Assign a gameversion, to prevent outdated clients from connecting
if not BigLobbyGlobals:is_small_lobby() then
	 NetworkMatchMakingSTEAM.GAMEVERSION = BigLobbyGlobals:gameversion()
end

-- Prevent non BigLobby players from finding/joining this game.
if not BigLobbyGlobals:is_small_lobby() then
	NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "biglobby-" .. BigLobbyGlobals:version()
end
-- TODO: Use the existing search key and concatenate "-biglobby" to it so other mods
-- can use this filter/isolation method. Note at present it's nil
--NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY .. "-biglobby"
