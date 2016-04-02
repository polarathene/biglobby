local orig__ClientNetworkSession = {}
orig__ClientNetworkSession.on_join_request_reply = ClientNetworkSession.on_join_request_reply

function ClientNetworkSession:on_join_request_reply(...)
    -- Place params in table
    local params = {...}

    -- Get params we want based on if the func signature is correct
    local reply = params[1]
    local sender = #params==17 and params[17] -- Should be the last param
    local num_players = sender and type(params[16])=='number' and params[16]

    -- If the response is `1`(ok), set BigLobby to use host preference or 4 if
    -- a regular lobby.
    if reply == 1 then
        Global.num_players = num_players or 4
    end

    -- Assign sender to original param 16 for the original func call to use
    if sender then params[16] = params[17] end

    -- Pass params on to the original call
    orig__ClientNetworkSession.on_join_request_reply(self, unpack(params))
end
