^[°°±±²²ÛÛ Welcome to](colored: 'cyan') ^[GZDOOM](colored: 'red') ^[for](colored: 'cyan') ^[iOS](colored: 'green')! ^[ÛÛ²²±±°°](colored: 'cyan')

^[GZDoom](colored: 'white') is a ^[source port](colored: 'orange') of what's known as the ^[idTech 1](colored: 'white') game engine, the most notable game from this being, of course, ^[Doom](colored: 'red'). ^[GZDoom](colored: 'white') is the work of the ^[ZDoom, GZDoom teams and many community contributors](colored: 'orange').

A source port is able to read the original game files and ^[render the game using modern technology](colored: 'white'). The game engine can be rendered in ^[full 3D](colored: 'white') using the latest 3D graphics hardware and drivers. ^[GZDoom](colored: 'white') for iOS is using ^[Metal](colored: 'blue') to render its graphics through moltenVK and the Vulkan API.

^[GZDoom](colored: 'white') also supports ^[mods](colored: 'orange'), which further extends capabilities beyond the original game engine, like adding ^[graphical and sound enhancements](colored: 'white') as well as custom behavior through scripting. One of the most notable and popular mods is ^[Brutal DOOM](colored: 'red'), which ^[GZDoom](colored: 'white') fully supports and is my personal favorite (and the reason why I ported this to iOS).

^[°°±±²²ÛÛ  Quick Start ÛÛ²²±±°°](colored: 'cyan')

To start a game, you need to create a ^[Launch Configuration](colored: 'white').

A ^[Launch Configuration](colored: 'white') requires that you select a ^[base game file](colored: 'white') and optionally add any other files (^[mods](colored: 'white')) you wish to load. You can save this configuration to use for later.

For example, you can play John Romero's most recent WAD pack, ^[SIGIL](colored: 'white'), by adding the retail ^[DOOM.wad](colored: 'white') as the base game, and then selecting the ^[SIGIL.wad](colored: 'white') file as an additional external file, and save this configuration to play later.

To create a ^[new launch configuration](colored: 'white'):

* Tap on the + button in the upper left corner to add a new launch configuration

* ^[Tap on a file](colored: 'white') on the left column under ^[Select the base game file](colored: 'yellow') to select it.

  A free community-developed game called ^[Freedoom](colored: 'white) is included with ^[GZDoom](colored: 'red'), named ^[freedoom.wad](colored: 'yellow')

* You can optionally select other files to load such as mods on the right column, under ^[External Files/Mods](colored: 'yellow'). See the ^[Adding WAD files and mods](colored: 'cyan') section below on how to do this.

* Tap the ^[Save launch config](colored: 'yellow') button to save the configuration.

* You're given an option to change the load order of mods in the next screen. Tap ^[Save Launch Configuration](colored: 'yellow') to save the configuration and give it a descriptive name.
 
* Tap the saved launch configuration from the Laucher Configuration list to start the game.

^[°°±±²²ÛÛ Adding WAD files and mods ÛÛ²²±±°°](colored: 'cyan')

In the ^[Files](colored: 'yellow') app on your iOS device, under ^[On my iPhone](colored: 'yellow') or ^[On my iPad](colored: 'yellow') location, you should see a ^[GZDoom](colored: 'yellow') folder. You can add files here by:

- ^[Downloading files in Safari on your iOS device](colored: 'white') and moving them to the GZDoom folder.

- ^[Using AirDrop](colored: 'white') from another Mac, iPhone or iPad, and choosing ^[Save to Files](colored: 'yellow'), and then save to your GZDoom folder.

- ^[Transferring files](colored: 'white') using the ^[Finder](colored: 'yellow') on the Mac, or ^[iTunes](colored: 'yellow') on Windows.

^[°°±±²²ÛÛ More on Launch Configurations ÛÛ²²±±°°](colored: 'cyan')

GZDoom requires a base game, or "^[IWAD](colored: 'white')", at the bare minimum to start a game. This is usually the main game WAD such as "^[doom.wad](colored: 'white')" or "^[doom2.wad](colored: 'white')". Most mods require the ^[full-version](colored: 'white') of the WAD (not the free shareware version). You can purchase these on [Steam](https://steampowered.com) or [GOG](https://gog.com), or if you had the original retail versions on floppy disk or CD-ROM.

Most Doom mods use doom2.wad as the base game.

You can also use IWADs from other compatible games, such as Hexen and Heretic. [View the wiki for a more complete list](https://zdoom.org/wiki/IWAD) of supported games.

Some IWADs are ^[total conversions](colored: 'white'), or TCs that function as standalone games as well.

When creating a new ^[Launch Configuration](colored: 'white'), the left column shows a list of files that are possible IWADs. Note that it only looks for file types matching .iwad, .ipk3, and .wad so some files here might not be IWADs.

Once selected, you have the option of launching the game right away using the ^[Launch without saving](colored: 'yellow') button, or you can further customize the game by selecting external mod files to add. See the ^[External files/mods](colored: 'yellow') section for this.

Here are the other options you can choose after selecting an IWAD on this pane:

- ^[Save launch config](colored: 'yellow'): Save this configuration for use later. If you added a lot of mods and configured the load order, this is handy so that you don't have to configure them every time.

- ^[Back](colored: 'yellow'): Go back to selecting the base game again.

- ^[Multiplayer Options](colored: 'yellow'): This is still largely experimental so use at your own risk.

- ^[Launch without saving](colored: 'yellow'): Launch GZDoom with the configuration right away without saving. Might be useful if you're just testing things out.
 
^[°°±±²²ÛÛ Saving Launch Configurations ÛÛ²²±±°°](colored: 'cyan')

When saving a ^[Launch Configuration](colored: 'white'), you'll see an additional screen that will let you customize the ^[load order](colored: 'white') of the mods you selected.

If you're loading a lot of mods, mod files need to be loaded in the right order, or the game may not start. The general rule of thumb is that maps are loaded before other files, but check the mod's instructions on how to load them.

You can reorder the loading order by dragging the mod files with your finger on the ^[Save Launch Configuration](colored: 'yellow') screen.

^[°°±±²²ÛÛ Game Controller Support ÛÛ²²±±°°](colored: 'cyan')

Game controllers are supported (mFi, PS4, PS5, Xbox One, etc)!

^[°°±±²²ÛÛ In-Game Operation ÛÛ²²±±°°](colored: 'cyan')

^[°°±±²²ÛÛ Troubleshooting/Issues ÛÛ²²±±°°](colored: 'cyan')

- Quitting a game and returning to the main launcher is not currently working. You need to force quit the app and relaunch if you want to launch a different game.

- Keyboard/Mouse support on iPad is incomplete; pressing the mouse button changes the view direction, making it jarring to play with.

- Game controllers may not be detected on launch if they are already connected and may need a disconnect/reconnect while running GZDoom.


