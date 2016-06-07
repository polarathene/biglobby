function NetworkPeer:send(func_name, ...)
	-- In biglobby mode if the func is matched, call the prefixed version instead
	if not BigLobbyGlobals:is_small_lobby() and BigLobbyGlobals.network_handler_funcs[func_name] then
		func_name = 'biglobby__' .. func_name
	end




	-- Original Code --
	if not self._ip_verified then
		debug_pause("[NetworkPeer:send] ip unverified:", func_name, ...)
		return
	end
	local rpc = self._rpc
	rpc[func_name](rpc, ...)
	local send_resume = Network:get_connection_send_status(rpc)
	if send_resume then
		local nr_queued_packets = 0
		for delivery_type, amount in pairs(send_resume) do
			nr_queued_packets = nr_queued_packets + amount
			if nr_queued_packets > 100 and send_resume.unreliable then
				print("[NetworkPeer:send] dropping unreliable packets", send_resume.unreliable)
				Network:drop_unreliable_packets_for_connection(rpc)
			else
			end
		end
	end
	-- End Original Code --
end
