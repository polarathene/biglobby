## BigLobby
This mod makes it possible to have more than 4 players in a map. The search_key which affects what lobbies you can see on Crime.net is changed. Doing so prevents regular players without the mod joining and only shows you lobbies hosted with this mod.

[**NO LONGER MAINTAINED**](https://github.com/polarathene/biglobby/issues/63) - Please show support if you'd like updates by contributing to bounties on BountySource. Either I or someone else may claim it. In future I may write a tool to automate sync updates with bounties encouraging the community to maintain the mod for any other breakage.

**BigLobby3:** The community has made it possible to use this mod without requiring pdmod to use. Development of BigLobby is likely to continue at their new repo located [here](https://github.com/payday-restoration/BigLobby3). It includes all commits from 2017 in this repo, including unreleased fixes/improvements recently contributed. [ModWorkshop link](https://modworkshop.net/mydownloads.php?action=view_down&did=21582).

# How to install

[Video guide by B33croft](https://www.youtube.com/watch?v=rkxwfFdFXnI).

1. Download the latest `.zip` file at the bottom of the [latest release](https://github.com/polarathene/biglobby/releases/latest)
2. You will need [Bundle Modder](http://downloads.lastbullet.net/197) and [BLT](http://paydaymods.com/download/) to run this mod.
3. Install the `.pdmod` file provided using Bundle Modder, instructions on how to use the Bundle Modder can be found [here](http://steamcommunity.com/sharedfiles/filedetails/?id=231568439).
4. Install BLT by copying it's contents into your Payday 2 directory.
5. Then copy the `biglobby` folder into the `mods` folder, found inside your Payday 2 directory.
6. Run Payday 2. At the main menu you can change the settings for BigLobby at `Options -> Mod Settings`(Make sure you have the BLT mod enabled first).

- *All players* must use both the BLT mod **and** pdmod file to participate in a big lobby. **Make sure you are all using the same version!**
- BLT updater is not able to update BigLobby yet, you must manually get updates by checking the [releases page](https://github.com/polarathene/biglobby/releases) until this mod is released on Last Bullet and gets official update support.

### Enable/Disable BigLobby
To play normal games disable the BLT mod, this then requires you to restart the game or go into mission briefing screen of a lobby for the BLT mods to refresh. The pdmod does not need to be disabled unless an update is released and you experience crash on regular lobbies.

The same applies for enabling the BLT mod, switching it on needs to reload the BLT mods to apply the code changes.

I don't know when I'll have time, but if someone wants to help with Crime.net, either by making BigLobbies display differently or adding a filter/toggle option, then I can enable seamless switch between normal and big lobbies without having to enable/disable BLT mod :)

### Crashing
If the game has updated, you may need to verify cache to restore original code and apply the pdmod again. If you still crash, chances are the game added/changed new code and BigLobby needs to update, create a Github Issue. **Please submit a crashlog**(you can use a web service like pastebin). This will help me identify where the crash is coming from.


# Development Status
Still in beta, not officially released on Mod Workshop yet. I'm swamped with work but will do my best for bug fixes when updates break it as long as you can help report/test it. Actual release to Mod Workshop requires few more features to be done, but they require time, no ETA when that will happen.


# Technical Details
My previous version from December 2015(see commits) was much heavier in code with a hacky JSON approach to re-route network messages from the `Network` class. This mostly worked, with one blocker being the unit network handler class where I couldn't re-route the functions there due to not being able to serialize the unit param into JSON.

The "bug" being worked around turns out it was due to the asset `settings/network.network_settings`, an XML file that the `Network` class uses.

A later update can provide a fix by allowing multiples of a character to join the game.


# Credits:
**Elysium** - Massive help with testing during 2015.

**[I am not a spy...](https://github.com/antonpup)** - Huge help with testing and suggested the network issues fix via pdmod.

**[Shad0wlife](https://github.com/Shad0wlife)** - Contributed several welcome bug fixes and improvements.

**[steam-test1](https://github.com/steam-test1)** - Updated the mod to BLT 2.0, updated several months worth of network method changes. Fixed some bugs.

**Luffy** - Helped with some testing and making some changes to support custom HUDs.

**Snh20** - Helped work on the pdmod file and some testing.
Many others who helped test, feel free to get in touch and I'll update :)

**Rara** and **SlideDrum** - Very helpful with testing!
