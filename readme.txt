Title    : Pure CTF
Filename : purectf199beta4.zip
Version  : v1.99 beta4
Date     : 98-08-??
Author   : Dan Zetterstrom aka Methabol
Email    : metabol@bt.nu
WWW      : http://purectf.solgames.com/
Credits  : Methabol
Info	 : 

In this document:
-----------------
Pure CTF
Features
Quick Installation

Read purectf.html for complete documentation.

Pure CTF
--------
Since Zoid's first version of 3wave CTF there have been many different CTF mods out there. 
Some good and some not so good. Most had one thing in common though: You had to play with
all new features, you couldn't just select the ones you want. I wanted a mod where you
could select exactly what new features you wanted, and which ones you rather not use at 
all. I also wanted a solid competition mod that you could use to set up clanfights or 
practice games quickly and easily. Finally I wanted a mod that fixed all those small but
annoying bugs that was left since the developement of 3wave CTF was discontinued. 
The result is Pure CTF.

With Pure CTF you got the choice. You can select any of the dozens of options, modes and 
clientpaks you want. You can use it as a competition server, arena server, clanarena server,
even a DM server, and it supports the most popular CTF mod besides 3wave, Thunderwalker CTF.
And you can combine any of the features making the possibilities endless.

Or you can play just plain, Pure CTF. 

Features
--------
 - Fully compatible with Threewave CTF, CTF Expansion pack and All-star CTF. 
 - Dynamic Map conversion: This converts all the id maps on-the-fly by the QuakeC code! 
   This means that you don't have to do the work of converting them when you set up a 
   server and that you save 43 meg of HD space. As a bonus this means that all map bugs 
   I've found (bogus teleporters, spawn spots in the ground, etc.) are fixed automatically. 
 - Showdown Support: Ctf showdown is a competition mode intended to run on a public server
   where players can set up small games (2on2 or suchlike) by themselves without needing 
   rcon. This version of showdown has more options and some improvements from the original 
   ctf showdown by [LoRD]Tar. 
 - Admin function: The admin functions helps to configure and administrate the server more 
   easily. They include a lot of commands that's much easier to use than rcon , and some 
   commands that does things you can't do as rcon such as swapping players or teams. Also,
   you can give people a special admin pass so you don't have to give the full rcon access. 
 - Fixed a lot of bugs like the hookbug, discharge bug, the bug where the flag floats around
   after being dropped on an elevator and the crashbug with some teleporters. 
 - Tossrune command. 
 - Advanced Spectator tracking. Instead of just selecting a player to track you can track a 
   flag, quad, penta, ring, rune, etc. 
 - Enhanced MapQueue. Supports 3wave ctf, ctfep and allstar ctf. Use "Vote for episode",
   custom mapqueue or random maps, all configurable from server.cfg. 
 - Simple competition mode with autoscreenshot, autodemos and score totals that remember
   disconnects. 
 - Pingban patch. Automatically kicks anyone with a ping lower than the value the admin sets. 
 - Disable powerups, runes, hook or discharges. 
 - Clan Practice mode. 
 - Features from qw2.0 : Glglow, dropquad/ring, etc. 
 - Some of the "old" code optimized for better server performance. 
 - All new features completely optional. Everything except MOTD is configured from the
   server.cfg so you can change them without restarting the server. 
 - Bonus: Rljump CTF :) 


Quick Installation
------------------

 - Unzip the pure ctf zip into your ctf server directory. Note: this will not replace your
   old server config or your motd file if you upgrade from an earlier version of Pure CTF, 
   so you won't risk losing any settings. 
 - You DON'T have to convert the id maps to ctf any more. If you already done this, Pure CTF
   will recognize this, but you can safely remove them and save 43mb of HD space.
 - Optional step: If you want to change the motd, rename motd_new.qc to motd.qc, edit 
   it. and recompile. More about this in the html manual. 
 - Rename the file purectf.cfg to server.cfg and change the settings you want. There's a lot
   of settings there, but you can leave most as they are. The important ones to change are: 
    - The Server info section. Change all settings there to reflect your server.  Remember
      to change the rcon_password! 
    - The deathmatch setting in game rules. 1 is respawning weapons, 3 is static. 
    - The mapqueue. Enter your favourite maps to cycle on the server. 
    - Note: tossrune, dropquad, dropring, glglow and shirtlock are on by default. All these
      can be found in the Pure CTF features section. 
 - You're ready to go! Check out the server modes and server settings sections in the manual for more 
   configuration info.

