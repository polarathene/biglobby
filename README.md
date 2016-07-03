##BigLobby
This mod makes it possible to have more than 4 players in a map. The search_key which affects what lobbies you can see on Crime.net is changed. Doing so prevents regular players without the mod joining and only shows you lobbies hosted with this mod.


#How to install
1. Download the latest .zip file at the bottom of the [latest release](https://github.com/polarathene/biglobby/releases/tag/v2.0.0-alpha)
2. You will need [Bundle Modder](http://downloads.lastbullet.net/197) and [BLT](http://paydaymods.com/download/) to run this mod.
3. Install the .pdmod file provided using Bundle Modder, instructions on how to use the Bundle Modder can be found [here](http://steamcommunity.com/sharedfiles/filedetails/?id=231568439).
4. Install BLT by copying it's contents into your Payday 2 directory.
5. Then copy the "biglobby" folder into the "mods" folder, found inside your Payday 2 directory.
6. Run Payday 2, at the main menu you can change the settings for BigLobby at `Options -> Mod Settings`(Make sure you have the BLT mod enabled first).

- *All players* must use both the BLT mod **and** pdmod file to participate in a big lobby. **Make sure you are all using the same version!**
- BLT updater is not able to update BigLobby yet, you must manually get updates by checking the [releases page](https://github.com/polarathene/biglobby/releases/tag/v2.0.0-alpha) until this mod is released on Last Bullet and gets official update support.

###Enable/Disable BigLobby
To play normal games disable the BLT mod, this then requires you to restart the game or go into mission briefing screen of a lobby for the BLT mods to refresh. The pdmod does not need to be disabled unless an update is released and you experience crash on regular lobbies.

The same applies for enabling the BLT mod, switching it on needs to reload the BLT mods to apply the code changes.

If don't know when I'll have time, but if someone wants to help with Crime.net, either by making BigLobbies display differently or adding a filter/toggle option, then I can enable seamless switch between normal and big lobbies without having to enable/disable BLT mod :)

###Crashing
If the game has updated, you may need to verify cache to restore original code and apply the pdmod again. If you still crash, chances are the game added/changed new code and BigLobby needs to update, create a Github Issue or notify Kwhali on reddit. **Please submit a crashlog**(you can use a web service like pastebin). This will help me identify where the crash is coming from.


#Development Status
Still in alpha/beta, not officially released on to Last Bullet yet. I'm swamped at work but will do my best for bug fixes when updates break it as long as you can help report/test it. Actual release to Last Bullet requires few more features to be done, but they require time/experience, no ETA when that will happen.


#Technical Details
My previous version from December 2015(see commits) was much heavier in code with a hacky JSON approach to re-route network messages from the `Network` class. This mostly worked, with one blocker being the unit network handler class where I couldn't re-route the functions there due to not being able to serialize the unit param into JSON.

The "bug" being worked around turns was due to the asset `settings/network.network_settings`, an XML file that the `Network` class uses.

A later update can provide a fix by allowing multiples of a character to join the game.


#Credits:
**Elysium** - Massive help with testing during 2015.

**[I am not a spy...](https://github.com/antonpup)** - Huge help with testing and suggested the network issues fix via pdmod.

**Luffy** - Helped with some testing and making some changes to support custom HUDs.

**Snh20** - Helped work on the pdmod file and some testing.
Many others who helped test, feel free to get in touch and I'll update :)

**Rara** - Very helpful with testing.


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
