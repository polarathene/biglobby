-- used in `NetworkMatchMakingSTEAM:create_lobby(settings)` when calling `Steam:create_lobby(f, NetworkMatchMakingSTEAM.OPEN_SLOTS, "invisible")`
-- Supposedly important? Originally hardcoded to 4.
NetworkMatchMakingSTEAM.OPEN_SLOTS = 8
--NetworkMatchMakingSTEAM.GAMEVERSION = 53770 --53770=`hello` or could use NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "biglobby"
--NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY .. "-biglobby"
