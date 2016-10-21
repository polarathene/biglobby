#Custom HUD support
Adding Biglobby support to HUD mods is easy and should work great with or without the biglobby mod enabled. You can patch your HUD mod with info below or reach out to the mod author to update their mod. Again these changes should be safe improvements with no negative effects.

**PD:TH Hud**
--

Already updated to support BigLobby :)

[GitHub](https://github.com/GreatBigBushyBeard/PAYDAY-2-PDTH-Hud/)
[LastBullet](http://forums.lastbullet.net/mydownloads.php?action=view_down&did=682)

**CompactHUD**
---

Newer versions of this HUD should have dynamic support built in. The Chat UI needs to be moved if you want to read chat with large lobbies however.

*Hudmanager.lua - HUDManager:_create_teammates_panel*

**Set the panel height correctly for vertical stack of panels, otherwise clipping occurs.**

Original:
```LUA
local h = self:teampanels_height()
```

Fix:
```LUA
local h = 24 * HUDManager.PLAYER_PANEL
```

---

*Hudmanager.lua - HUDManager:_create_teammates_panel*

**Replace hardcoded 4 value with a variable.**

Original:
```LUA
for i = 1, 4 do
```

Fix:
```LUA
for i = 1, HUDManager.PLAYER_PANEL do
```

---

*Hudmanager.lua - HUDManager:_create_teammates_panel*

**Replace hardcoded values 4 and 3 with a variable.**

Original:
```LUA
local small_gap = (teammates_panel:w() - player_gap - teammate_w * 4) / 3
```

Fix:
```LUA
local small_gap = (teammates_panel:w() - player_gap - teammate_w * HUDManager.PLAYER_PANEL) / (HUDManager.PLAYER_PANEL - 1)
```


MUI
---

MUI source is a bit hard to read/follow, so there may be some code that still needs to be adjusted. Let me know and I'll add any additional fixes here.

*mui_manager.lua - HUDManager:_create_teammates_panel*

**Replace hardcoded 4 value with a variable.**
Original:
```LUA
for i = 1, 4 do
```

Fix:
```LUA
for i = 1, HUDManager.PLAYER_PANEL do
```

---

*mui_manager.lua - MUITeammate.align_panels*

**Fix alignment issue. Using `gap` setting would adjust panels around the 4th panel.**

Original:
```LUA
local totWidth = MUITeammate._muiGap * 3;
```

Fix:
```LUA
local totWidth = MUITeammate._muiGap * (HUDManager.PLAYER_PANEL - 1);
```

---

*mui_manager.lua - MUITeammate.align_panels*

**Remove hardcoded limit to support additional panels.**

Original:
```LUA
for i = 4, 1, -1 do
    local matePanel = teamPanel:child("" .. (Order and 5 - i or i));
-- further down
for i = 4, 1, -1 do
```

Fix:
```LUA
for i = HUDManager.PLAYER_PANEL, 1, -1 do
    local matePanel = teamPanel:child("" .. (Order and (HUDManager.PLAYER_PANEL + 1) - i or i));
-- further down
for i = HUDManager.PLAYER_PANEL, 1, -1 do
```

---

*mui_team.lua - MUITeammate:init*

**Assign correct colours. Use size of `chat_colors` table instead of a hardcoded value.**

Original:
```LUA
local crim_color = tweak_data.chat_colors[5-i];
```

Fix:
```LUA
local crim_color = tweak_data.chat_colors[#tweak_data.chat_colors-i];
```


HoloHUD
---

I have this mostly working, seems to be a slight issue with how panels are laid out that has caused some clipping on the UI panels.

*HUDMissionBriefing.lua - HUDMissionBriefing:init*

**Replace hardcoded 4 values with a variable. `text_font_size * 8` is just double the original `* 4` value.**

Add the following line at the start of the function:

```LUA
local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
```

Original:
```LUA
h = text_font_size * 8
```

Fix:
```LUA
h = text_font_size * (num_player_slots * 2)
```

Original:
```LUA
for i = 1, 4 do
```

Fix:
```LUA
for i = 1, num_player_slots do
```

---

*hudlootscreen.lua - HUDLootScreen:init*

**Replace hardcoded 4 value with a variable.**

Add the following line at the start of the function:

```LUA
local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
```

Original:
```LUA
for i = 1, 4 do
    self:create_peer(self._peers_panel, i)
end
```

Fix:
```LUA
for i = 1, num_player_slots do
    self:create_peer(self._peers_panel, i)
end
```

---

*hudlootscreen.lua - HUDLootScreen:set_num_visible, HUDLootScreen:clear_other_peers, HUDLootScreen:check_all_ready*

**Replace hardcoded 4 values with a variable.**

Add the following line at the start of each function:

```LUA
local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
```

And replace:
```LUA
for i = 1, 4 do
```

With:
```LUA
for i = 1, num_player_slots do
```

Alternatively, the first line could be a HUDLootScreen:num_player_slots() function that is called instead of using a local variable, reducing the copy/paste.
