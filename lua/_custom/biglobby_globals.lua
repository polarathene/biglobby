BigLobbyGlobals = BigLobbyGlobals or class()

-- I think I only need this function and can delete the rest?
function BigLobbyGlobals:num_player_slots()
    return 8
end


--BigLobbyGlobals.aticket = nil
--local aticket
function BigLobbyGlobals:auth_ticket(ticket)
    log("[BigLobbyGlobals :auth_ticket]")
    if ticket then BigLobbyGlobals.aticket = ticket end
    return BigLobbyGlobals.aticket
end

--pd2hook or BLT version
function BigLobbyGlobals:Hook()
    return "BLT"
end

function BigLobbyGlobals:version()
    return 0.2
end

--BigLobbyGlobals.jdata = nil
--local jdata
function BigLobbyGlobals:jdata(peer_id, data)
    log("[BigLobbyGlobals :jdata] peer_id: " .. tostring(peer_id) .. ", data: " .. tostring(data))
    if data then
        log("[BigLobbyGlobals :jdata] setting data for peer: " .. tostring(peer_id))
        if not BigLobbyGlobals._jdata then BigLobbyGlobals._jdata = {} end
        BigLobbyGlobals._jdata[peer_id] = data
    end
    log("[BigLobbyGlobals :jdata] returning data: " .. tostring(BigLobbyGlobals._jdata[peer_id]))
    return BigLobbyGlobals._jdata[peer_id]
end


function BigLobbyGlobals:gtrace(content)
  if not content then return end
  io.stdout:write(content .. "\n")
end


local test_id = "who_is_awesome"
local Net = _G.LuaNetworking
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_PMs", function(sender, id, data)
    log("NETWORK RESPONSE: " .. tostring(id))

    if id == test_id then
        log("[BigLobbyGlobals :network_hook] who_is_awesome")
        data = tonumber(data)
        local name = Net:GetNameFromPeerID( sender )
        log( "Received Private Message from: " .. name )
        log( "Message: " .. data )

        log("[BigLobbyGlobals :who_is_awesome] Why " .. tostring(managers.network:session():peer(data):name()) .. " is awesome of course!")
    	log("[BigLobbyGlobals :who_is_awesome] From " .. tostring(managers.network:session():peer(sender):name()) .. " :)")
    end
end)


--Use global version later? Possible issue with gtrace in some instances
local log_data = true
function logger(content, use_chat)
	if log_data then
		if not content then return end
		if use_chat then
			managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
		end
		if BigLobbyGlobals:Hook() == "pd2hook" then
			io.stdout:write(content .. "\n")
		else
			log(content)
		end
	end
end
