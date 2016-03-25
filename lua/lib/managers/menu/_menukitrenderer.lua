--NOT REQUIRED, used for console output debugging
function MenuKitRenderer:set_slot_joining(peer, peer_id)
	local peer_id_name = tostring(peer:id()) .. " - " .. tostring(peer:name())
	logger("[MenuKitRenderer :set_slot_joining] super, peer: " .. peer_id_name)

	MenuKitRenderer.super.set_slot_joining(self, peer, peer_id)
	logger("[MenuKitRenderer :set_slot_joining] preplanning")
	managers.preplanning:on_peer_added(peer_id)
	logger("[MenuKitRenderer :set_slot_joining] done")
end
