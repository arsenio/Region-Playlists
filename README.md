Region Playlists
================

This utility creates a new popup window that lets you treat your REAPER project like a rearrangable playlist. It's intended to work on projects that have multiple regions. You can create a playlist which contains regions in any sequence you choose. Region Playlists supports interactive pause points; play one region, then pause for a keystroke before continuing to the next region. You can create multiple playlists per project, too.

Prerequisites:
--------------
* REAPER (of course)
* [SWS](http://www.sws-extension.org/)
* [ReaPack](https://reapack.com/)
* Lokasenna’s GUI library v2 for Lua
  - You will want to install this via ReaPack (available in your REAPER Actions).
  - Once you do, you will also need to run the `Script: Set Lokasenna_GUI v2 library path.lua` Action.

First-Time Installation:
------------------------
* Clone or unpack this repository onto your local disk. I recommend `<User_Application_Support_Dir>/REAPER/Scripts`.
  - The easiest way to get to your user application support directory is within REAPER itself: **Options**->**Show REAPER resource path in explorer/finder**.
* In REAPER, open up your Actions list (**Actions**->**Show actions list...**)
* Click on the **ReaScript: Load...** button. A new file chooser dialog will appear.
* Find the unpacked repository on your local disk, then select `Region Playlists.lua`
* You should be back in your Actions list, with `Region Playlists.lua` selected.
  - From here, you can Run that script
  - **Pro tip:** before running the script, you can also create a shortcut for that action, so that you can skip the installation going forward. Choose a keyboard shortcut of your liking.
    - One important note: make sure that the **Automatically close window on key/MIDI input** checkbox is *not* checked!

License:
--------
Region Playlists is free software distributed under the terms of the MIT license reproduced [here](LICENSE.txt).
It may be used for any purpose, including commercial purposes, at absolutely no cost.
No paperwork, no royalties, no GNU-like "copyleft" restrictions, either.
Just download it and use it. Region Playlists is provided for free, with no warranties or limitations.
