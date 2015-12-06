--Crashes if use global
-- HUDManager.PLAYER_PANEL = 6 --bad idea, this actually referenced 4 as in the 4th panel on the UI(one on the furtherest right)
-- should be the local players

--Nothing seems to call this, I don't think it's even used.. Panels are created somewhere else
function HUDManager:_create_teammates_panel(hud)
	log("[HUDManager :_create_teammates_panel]")
	local num_player_slots = 6--BigLobbyGlobals:num_player_slots()

	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end
	local h = self:teampanels_height()
	local teammates_panel = hud.panel:panel({
		name = "teammates_panel",
		h = h,
		y = hud.panel:h() - h,
		halign = "grow",
		valign = "bottom"
	})
	local teammate_w = 204
	local player_gap = 240
	local small_gap = (teammates_panel:w() - player_gap - teammate_w * num_player_slots) / num_player_slots-1
	for i = 1, num_player_slots do
		log('[HUDManager :_create_teammates_panel] i: ' .. tostring(i))
		local is_player = i == HUDManager.PLAYER_PANEL
		do break end
		-- unhandled boolean indicator
		self._hud.teammate_panels_data[i] = {
			taken = true,
			special_equipments = {}
		}
		local pw = teammate_w + (is_player and 0 or 64)
		local teammate = HUDTeammate:new(i, teammates_panel, is_player, pw)
		local x = math.floor((pw + small_gap) * (i - 1) + (i == HUDManager.PLAYER_PANEL and player_gap or 0))
		teammate._panel:set_x(math.floor(x))
		table.insert(self._teammate_panels, teammate)
		if is_player then
			teammate:add_panel()
		end
	end
end
