^[°°±±²²ÛÛ What's New in GenZD! ÛÛ²²±±°°](colored: 'red')

^[Version 2024.9.8](colored: 'yellow')

^[°°±±²²ÛÛ Small Fixes ÛÛ²²±±°°](colored: 'cyan')

- Fixed the issue where the Profiles button does not show the popover menu after tapping on it for some iPads.

- Fixed the appearance of the buttons in the Save Launch Configuration screen.

^[°°±±²²ÛÛ Version History ÛÛ²²±±°°](colored: 'cyan')

^[Version 2024.9.7](colored: 'yellow')

^[°°±±²²ÛÛ Small Fixes ÛÛ²²±±°°](colored: 'cyan')

- Highlight the launch configuration after adding or editing one.

^[Version 2024.9.6](colored: 'yellow')

^[°°±±²²ÛÛ Small Fixes ÛÛ²²±±°°](colored: 'cyan')

- Added button to collapse and reveal the top buttons

- Added GZDoom patch to support Hands of Necromancy II

^[Version 2024.9.5](colored: 'yellow')

Fixed crash on iPads when tapping the "Profiles" button on the Arrange Controls screen.

^[Version 2024.9.4](colored: 'yellow')

You can now change the app icon to the old one in the Settings screen.

^[Version 2024.9.3](colored: 'yellow')

^[°°±±²²ÛÛ Local Multiplayer ÛÛ²²±±°°](colored: 'cyan')

You can now host a ^[co-op or deathmatch local multiplayer game](colored: 'white), and made it easier to join a game that's being hosted by another iOS device running GenZD on the same WiFi network.

Tap the ^[Multiplayer Options](colored: 'white') button when editing a launch configuration. You will have the option of hosting or joining an existing game.

If you host a game and ^[Launch Now without saving](colored: 'white'), your device will be discoverable by another device running GenZD and it will automatically be shown in the "Join" section of the multiplayer options screen. You can also join a game by a computer running GZDoom on the local network by entering the local IP address.

Once all of the players have joined, the multiplayer game will start.

^[°°±±²²ÛÛ Small Fixes ÛÛ²²±±°°](colored: 'cyan')

- A new icon that also supports tinting in iOS 18.
- Fixed the onscreen keyboard to support the shift keys so that you can type characters such as the underscore using shift-"-".

^[Version 2024.9.2](colored: 'yellow')

^[°°±±²²ÛÛ Touch Controls ÛÛ²²±±°°](colored: 'cyan')

^[Layout Profiles](colored: 'white') are here! You can now save multiple touch control layouts and switch between them. Tap the new ^[Profiles](colored: 'yellow') button on the Arrange Controls screen to create a new profile or load an existing one. Your existing touch control layout is now the "Default" profile.

^[°°±±²²ÛÛ Launch Configurations ÛÛ²²±±°°](colored: 'cyan')

- ^[Search](colored: 'white'): You can now search and filter your existing launch configurations.

- The sort order (Recent/ABC) is now saved and remembered the next time you open the app.

^[Version 2024.9.1](colored: 'yellow')

^[°°±±²²ÛÛ Bug Fixes ÛÛ²²±±°°](colored: 'cyan')

- ^[Sound Fonts](colored: 'white'): Sound font files can be placed in the GenZD folder, in: ^[GZDoom/soundfonts](colored: 'yellow') and ^[GZDoom/fm_banks](colored: 'yellow'). Select the sound font file by going to ^[GZDoom Options -> Full options menu -> Sound options -> Advanced -> Midi player options -> FluidSynth -> Select configuration](colored: 'yellow') 

- ^[Bots](colored: 'white'): If you want to use "zcajun" bots, place the bots.cfg file in: ^[GZDoom/zcajun](colored: 'yellow')

- Fixed the touch button for the number ^[7](colored: 'yellow') keyboard key so that it's released properly when pressed.

- Fixed the appearance of the list in the initial screen that shows the launch configurations 

^[Version 2024.8.11](colored: 'yellow')

Support for iOS 15.

^[Version 2024.8.10](colored: 'yellow')

^[°°±±²²ÛÛ Touch Controls ÛÛ²²±±°°](colored: 'cyan')

- Fixed the issue where small size buttons were hard to tap.
- Fixed the mapping for keyboard keys for the "V", "B" and "M" keys.

^[°°±±²²ÛÛ Patches ÛÛ²²±±°°](colored: 'cyan')

- Total Chaos Fix: Updated the argument checking for the SpawnSpotForced function to be less strict and provide default values.

^[Version 2024.8.9](colored: 'yellow')

The underlying GZDoom engine has been updated to ^[version 4.12.2](colored: 'orange')! I applied the patch to support the "Banshee explosion" in the new Legacy of Rust episode.

^[°°±±²²ÛÛ Touch Control ÛÛ²²±±°°](colored: 'cyan')

- ^[Change Button Sizes](colored: 'white'): There's a new button that appears when tapping a button in the arrange controls screen. Tapping this button toggles the sizes between small, medium and large.

- ^[Alignment Controls when Arranging](colored: 'white'): Alignment guides will appear when a button is aligned with another and will automatically snap into alignment. You can turn on/off horizontal alignment using the alignment buttons to the right of the opacity controls at the top of the screen.

- ^[Touch Analog Stick](colored: 'white'): Fixed the issue where moving in small increments would result in movement to the right.

^[°°±±²²ÛÛ Everything Else ÛÛ²²±±°°](colored: 'cyan')

- Hide the option buttons at the top of the screen when interacting with a physical controller or keyboard. Touching the screen will bring it back.

- A log file is now written to the GenZD folder, called ^[logfile.txt](colored: 'white'). If a launch configuration does not start, you can look at the log file to troubleshoot, or get help in our [Discord](https://discord.gg/S4tVTNEmsj).


^[Version 2024.8.8](colored: 'yellow')

Fixed an issue with the touch aiming where it can get unresponsive while moving.


^[Version 2024.8.7](colored: 'yellow')

^[°°±±²²ÛÛ Control Improvements ÛÛ²²±±°°](colored: 'cyan')

- ^[Analog Movement](colored: 'white'): Fixed the analog movement for both the virtual and physical controllers. You can now move slower if you don't push the stick all the way and have more fine-grained control over movement.

- ^[Touch Screen Aiming](colored: 'white'): Fixed the touch controls to be more sensitive and responsive. Previously, moving in small amounts would not trigger aiming movement due to a math error. This problem is now gone and aiming feels much smoother.

- The ^[Virtual Joystick/Left Thumbstick](colored: 'white') can now be used in the ^[in-game menus](colored: 'white'). Before it was unusable in the menus because it moved too fast. This has now been fixed.

- ^[Fixed Gyroscope Aiming](colored: 'white'): Facing down or up unintentionally reversed the gyroscope aiming. This has now been fixed, and the aiming will adjust properly if you flip the device.

Special thanks to those who reported these issues on [Discord](https://discord.gg/S4tVTNEmsj)! 


Version 2024.8.6

^[°°±±²²ÛÛ Touch Controller ÛÛ²²±±°°](colored: 'cyan')

- ^[C](colored: 'red')^[o](colored: 'green')^[l](colored: 'blue')^[o](colored: 'yellow')^[r](colored: 'cyan')^[a](colored: 'orange')^[b](colored: 'pink')^[l](colored: 'mint')^[e](colored: 'purple') ^[Buttons](colored: 'white'): You can now assign colors to each button! Tap on the button to reveal a color palette button on the lower left corner of the button, and tap it to select a color.

- ^[Added Keyboard Keys](colored: 'white'): Keyboard keys can now be added as touch buttons! When adding a control, tap the keyboard icon on the lower left to switch to a keyboard. Since there are many keys, you may need to scroll to the right to see more of them.

^[°°±±²²ÛÛ Fixes ÛÛ²²±±°°](colored: 'cyan')

- Added transition animations when selecting a base game and going back so it's less jarring.


Version 2024.8.5

^[°°±±²²ÛÛ Bug Fixes ÛÛ²²±±°°](colored: 'cyan')

- ^[Gyroscope Aiming](colored: 'white'): Fixed issue where flipping your device upside down reversed aiming with the gyroscope.

- ^[Virtual Keyboard](colored: 'white'): The Shift, Control and Alt buttons now are toggle-able and work.

- ^[Physical Keyboard](colored: 'white'): Fixed issue where you could not type in the console opening it using the ~ key.

- ^[Console](colored: 'white'): Increased the default text size of the in-game console so it's more readable. Open the console using the ^[~](colored: 'white') key on the keyboard to enter cheats and other commands. The fixed text size only show up on fresh installs for now. You can manually update this by editing the ^[gzdoom.ini](colored: 'gray') in the Preferences folder of GenZD, by setting ^[con_scale=4](colored: 'gray').

You can now view this ^[What's New](colored: 'white') content in the ^[Help](colored: 'white') screen, by tapping on the ^[What's New](colored: 'white') button in the upper left corner.


Version 2024.8.4

Fixed enabling iPad support

^[               °°±±²²ÛÛÛÛ²²±±°°](colored: 'white')

Version 2024.8.3
 
^[°°±±²²ÛÛ Better iPad Support ÛÛ²²±±°°](colored: 'cyan')

- Improved controls with Magic Keyboard + Touchpad or Physical Mouse:
  - Fixed mouse movement using a touch pad or physical mouse.
  - Interacting with a physical keyboard will automatically hide touch controls, and touching the screen will show the touch screen controls again.

If you're updating the app and playing with an iPad for the first time, you may need to manually map the primary tap or left click button to the Fire/Attack control.

^[°°±±²²ÛÛ Touch Controller ÛÛ²²±±°°](colored: 'cyan')

- You can now shoot and aim at the same time by ^[touch and dragging](colored: 'yellow') a button that is on the aiming side (right side).
- Removed the double-tap to shoot option because the above method to shoot and aim is more intuitive.
- Disable the Move/Aim overlay guide: Now a configurable option to disable the Move/Aim guidance overlay that's displayed if you do not interact with the screen. This is displayed once when running the app but now there's an option to disable it completely.
- Joystick Deadzone: If you find the movement joystick too sensitive, there's now an option "Movement Joystick Deadzone" to adjust this.

^[°°±±²²ÛÛ Game Controller ÛÛ²²±±°°](colored: 'cyan')

- Fixed aiming with the right stick when gyro aiming is enabled.


^[               °°±±²²ÛÛÛÛ²²±±°°](colored: 'white')

Version 2024.8.2

^[°°±±²²ÛÛ Gyroscope Aiming! ÛÛ²²±±°°](colored: 'cyan')

Gyroscope aimimg is on by default, and can be enabled/disabled in the Control Options screen. You can also adjust the gyroscope sensitivity here as well.

^[°°±±²²ÛÛ Miscellaneous ÛÛ²²±±°°](colored: 'cyan')

I re-did the internals of the control option settings, and your previously saved settings may be reset back to the defaults. This will not happen in future updates, and I apologize for the inconvenience.

^[               °°±±²²ÛÛÛÛ²²±±°°](colored: 'white')

Version 2024.8.1

^[°°±±²²ÛÛ New Touch Controls ÛÛ²²±±°°](colored: 'cyan')

Thank you for your patience, as the touch controls has been given an extreme makeover: 

- ^[Movement](colored: 'white') by touch and dragging on the ^[left half of the screen](colored: 'white') - a virtual joystick appears where you touch.

- ^[Aiming](colored: 'white') by touch and dragging on the ^[right half of the screen](colored: 'white')

- ^[Custom Button Arrangement](colored: 'white'): Button layout can be added and/or arranged using the arrange controls button (it looks like arrows pointing diagonally).

- ^[Control Transparency of Buttons](colored: 'white'): A slider control in the button arrangement screen lets you adjust the transparency of the buttons.

^[°°±±²²ÛÛ Game Controller Fixes ÛÛ²²±±°°](colored: 'cyan') 

- Aiming using the right stick is no longer "jerky" and is now much smoother.

- Improved handling of connecting and disconnecting controller.

^[°°±±²²ÛÛ New Control Settings Screen ÛÛ²²±±°°](colored: 'cyan')

A plethora of helpful settings have been added!

- ^[Aim Sensitivity](colored: 'white'): Affects the sensitivity of aiming for both the touch screen and game controller.

- ^[Opacity](colored: 'white'): The opacity of the touch controls. This is also shown in the "Arrange Controls" screen.
 
- ^[Double Tap and Hold](colored: 'white'): Assigning a button for this lets you double tap and hold on the right side of the screen. Useful for when you want to move and fire at the same time (circle-strafing).

- ^[Haptic Feedback](colored: 'white'): On by default, this gives you a light haptic feedback when touching a button.

- ^[Invert Y-Axis](colored: 'white'): Inverts vertical aiming for the game controller.
