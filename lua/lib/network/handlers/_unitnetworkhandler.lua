-- Extends the UnitNetworkHandler class to add our own unit network calls
BigLobby__UnitNetworkHandler = BigLobby__UnitNetworkHandler or class(UnitNetworkHandler)

-- Will add a prefix of `biglobby__` to all functions our definitions use
-- Required to maintain compatibility with normal lobbies.
BigLobbyGlobals:rename_handler_funcs(BigLobby__UnitNetworkHandler)
