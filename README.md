NS2Combat: A Combat-style mod for Natural Selection 2
=====================================================
By JimWest and MCMLXXXIV (with support from Jibrail, fsfod and a small army of mappers!)
========================================================================================

Our Design Aims:
----------------

* Try and reproduce as much of the old NS1 Combat Mode’s game mechanics as possible but bring some of the new skills and game mechanics from NS2 into play as well.
* Players get experience (score) for killing enemies or being around their teammates who are killing enemies.
* You can level up ten times in a game, getting an upgrade point to spend each time. This buys you weapons, evolves and upgrades.
* We’ve tried to balance support classes with offensive ones. You can specialise as any of the Alien lifeforms and as a Marine can choose to go Jetpack, Exo or some kind of ninja engineer.
* We'll keep the mod server-side until client-side mod downloading support is working in Steam Workshop. The most important thing is that you shouldn’t have to install anything to get the mod working as a player, and server operators should only have to do the minimum amount of updating (if any) to keep the game working.

How to play
-----------

1. Connect to a server running NS2 Combat Mode.
2. When you join you’ll get a message telling you about how to buy upgrades, which you’re awarded every time you get a certain amount of experience.
3. Use the "/buy" chat or console command to buy upgrades for yourself. You keep your level even if you switch teams.
4. Killing enemies, damaging structures or being near your teammates who are killing enemies will give you experience points, which will eventually get you more levels and upgrade points.
5. If you join a game in progress, you’ll get the average experience points and upgrade points of all active players, so you should be able to get right into the action.
* (Optional) Download and unzip the zip file above to your "Steam/SteamApps/common/Natural Selection 2" folder to use some of our client-side menus, then run the mod either using the Spark Launch Pad or "NS2.exe -game NS2Combat". Activate them using the 'B' key like with the alien upgrade menu in vanilla NS2.
* (Even more Optional) Users of fsfod's Menu Mod can also add this to their mods list by extracting the NS2Combat zip file to "steam/steamapps/common/Natural Selection 2/menumod/mods" and then also extracting this zip file to the newly extracted "menumod/mods/NS2Combat" folder... In future this will hopefully be less complicated!


Hosting your own server
-----------------------

1. Get the dedicated server working with regular NS2
2. Unzip the NS2Combat zip file to your server's folder. E.g. if the server.exe file is in c:\ns2server then extract to c:\ns2server and preserve folder names.
3. Launch your dedicated server with the command "server.exe -game NS2Combat"
4. To enable support with GameOvermind, get GameOvermind working with vanilla NS2 (so you have a GameOvermind folder in your server's directory) then unzip the special GameOvermind version. Combat will look for your existing GameOvermind installation and make use of it.

Contributing
------------

We're welcome for anyone who would like to contribute to the mod. Send us an email or a pull request if you would like to contribute code. Maps can be easily made and shared via the Steam Workshop. Ideas can be brought to us [here](http://www.unknownworlds.com/ns2/forums/index.php?showtopic=119151) on the Unknown Worlds modding forum.