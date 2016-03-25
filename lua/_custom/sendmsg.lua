local me = managers.network:session():local_peer()
logger("My Peer ID is: " .. tostring(me:id()) .. ", and my name is: " .. tostring(me:name()), true)
log("Test send msg")

local Net = _G.LuaNetworking
Net:SendToPeers("who_is_awesome", tostring(1))
--Net:SendToPeers("who_is_awesome", tostring(1))
--local jsdata = BigLobbyGlobals:jdata(2)
--log("Sending JSON data to peer: " .. jsdata)
--Net:SendToPeers("client_on_join_request_reply", jsdata)

function chk_all_handshakes_complete()
	for peer_id, peer in pairs(managers.network:session()._peers) do
		local peer_handshakes = peer:handshakes()
		for other_peer_id, other_peer in pairs(managers.network:session()._peers) do
			if other_peer_id ~= peer_id and peer_handshakes[other_peer_id] ~= true then
				print("[HostNetworkSession:chk_all_handshakes_complete]", peer_id, "is missing handshake for", other_peer_id)
				return false
			end
		end
	end
	return true
end

function chk_peer_handshakes_complete(peer)
	local peer_id = peer:id()
	local peer_handshakes = peer:handshakes()
	for other_peer_id, other_peer in pairs(managers.network:session()._peers) do
		if other_peer_id ~= peer_id and other_peer:loaded() then
			if peer_handshakes[other_peer_id] ~= true then
				logger("[:chk_peer_handshakes_complete] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", is mising handshake for: " .. tostring(other_peer:id()) .. " - " .. tostring(other_peer:name()) .. ", handshake status: " .. tostring(peer_handshakes[other_peer_id]), true)
				print("[HostNetworkSession:chk_peer_handshakes_complete]", peer_id, "is missing handshake for", other_peer_id)
				return false
			end
			if other_peer:handshakes()[peer_id] ~= true then
				print("[HostNetworkSession:chk_peer_handshakes_complete]", peer_id, "is not known by", other_peer_id)
				logger("[:chk_peer_handshakes_complete] peer: " .. tostring(peer:id()) .. " - " .. tostring(peer:name()) .. ", is not known by: " .. tostring(other_peer:id()) .. " - " .. tostring(other_peer:name()))
				return false
			end
		end
	end
	return true
end

function all_peers_done_loading_outfits()
	if not managers.network:session():are_all_peer_assets_loaded() then
		return false
	end
	for peer_id, peer in pairs(managers.network:session()._peers) do
		if peer:waiting_for_player_ready() and not peer:other_peer_outfit_loaded_status() then
			print("[HostNetworkSession:all_peers_done_loading_outfits] waiting for", peer_id, "to load outfits.")
			return false
		end
	end
	return true
end

logger("%%%% Handshakes complete?: " .. tostring( chk_all_handshakes_complete() ))
logger("%%%% All peers done loading outfits?: " .. tostring( all_peers_done_loading_outfits() ))
for peer_id, peer in pairs(managers.network:session()._peers) do
	logger("%%%% Handshakes complete for peer: " ..  tostring(peer:id()) .. " - " .. tostring(peer:name()) .. "? " .. tostring( chk_peer_handshakes_complete(peer) ))
end



logger("[CriminalsManager :character_color_id_by_unit] last_colour_id: " .. tostring(#tweak_data.chat_colors))
logger("[CriminalsManager :character_color_id_by_unit] , colour: " .. tostring(tweak_data.chat_colors[#tweak_data.chat_colors]))
