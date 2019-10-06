MEGA MAN CHRONICLES
--

This is a fan game currently in development and is purely a
passion project. This game is being constructed using the
Godot Game Engine.

Controls:
--
The game is mapped to use XBox, PlayStation, and Nintendo
Switch controllers. Wherever the button is located on one,
it will be the same button location on the others. Below
will display the controls as if you are using an XBox 360
or XBox One controller.

Action | Keyboard | Controller
-------|----------|-----------
Movement | [WASD] | [L analog]/[D Pad]
Jump | [.] | [A]
Fire | [,] | [X]
Prev Weapon | [;] | [LB]
Next Weapon | ['] | [RB]
Quick Select (1) | [NumPad] | [R Analog]
Select | [Shift] | [Select]
Start | [Enter] | [Start]

- Slide (As Mega Man): Down + Jump
- Dash (As Proto Man/Bass): Dash button or double tap the direction you wish to dash.

1. Has not been implemented, if at all.

Debug Information:
--
(Under Construction)


Changes - Version 0.0.1 ():
--
- Camera system started.
- READY at start of stage is complete.
- Added player spawn point functions.
- Added basic animations.
- Added the ground work for the swap mechanic.
- Running added.
- Tweaked the run function to use fewer lines of code.
- Jumping added.
- Fixed an issue where the jump sprite would briefly appear after the player beams in. This will potentially help fix the same issue when reaching the top of a ladder.
- Added a function to determine what kind of floor the player is standing on.
- Added function to determine what type of tile the player is overlapping.
- Fixed an issue where the player's Y velocity would keep increasing the more they fell.
- Added water physics.
- Tweaked jump code to make it easier to read.
- Fixed an issue where holding jump would let the player jump repeatedly.
- Fixed an issue where holding jump after falling off a platform would make the player jump upon contact with an obstacle.
- Ice physics added.
- Fixed an issue where the player's "little step" would not move them in the direction the player is facing.
- Fixed and issue where the player would stop at the edge of ice/conveyor tiles instead of falling off the side.
- Added ladders.
- Added a function to determine what type of tile the player is colliding with. (Mostly will be used for death traps).
- Tweaked water gravity to be more in line with the NES games.
- Added ladder tiles specifically for use in water.
- Fixed an issue where pulling the tile_name of a tile would spit out THOUSANDS of errors when not colliding.
- Sliding added for Mega Man.
- Fixed issues with sliding on certain tiles.
- COMPLETELY redid the X and Y movements for running. I totally overcomplicated the whole thing.
- Redid the top of ladder detection. Makes for a more stable dismount.
- Moved gravity functions outside of the main 3 states, as gravity will affect players unless they are climbing.
- Fixed an issue when the player reaches the top of an underwater ladder.
- Dashing added for Proto Man/Bass.
- Fixed an issue regarding the X Speed Modifier not resetting when no collision is taking place.
- Fixed ANOTHER issue with the tops of ladders after the last fix broke ALL ladders.
- Fixed an issue where the player would continue being pushed along as if on a conveyor when standing on 'Death' tiles. (Hilarious. But had to go).
- Damage functions added.
- Fixed an issue when taking damage while caught under a low ceiling.
- Fixed an issue where taking damage while sliding, but the player was NOT under a low ceiling, caused the player to continue their slide when the hurt animation was finished.
- Fixed an issue with how direction swapping is handled on ladders.
- Fixed an issue where the player would still climb ladders while in a shooting/throwing state.
- Fixed an issue when using a throwing weapon or Bass defaut buster displaying the wrong animations.
- Added shoot functions.
- Added throw functions.
- Added bass buster shot functions.
- Deleted and redid Bass' Buster functions because he's an asshole and every time I try to add something new it's BASS that breaks something and FUCK that fish headed ass hat I HATE HIM WITH EVERY OUNCE OF MY BEING!! )()$&&%^%&$(^$($^(^(&%%&!!! ... I'm better now.
- FINALLY fixed Bass' Buster behaviors.
- Fixed an issue where dashing against a wall would allow the player to dash endlessly along the floor when no obstacle is present.
- Fixed dash jumping for Bass so he could grab ladders and shoot.
- Added functions for debugging.
- Merged Standing and Sliding into a single function to help clean up code and make it more manageable.
- Fixed multiple bugs as a result of the merger.
- Fixed an issue where dashing while shooting as Bass would cause him to dash and shoot at the same time rather than cancel the shooting action.
- Started title screen.
- Redid the Fade In scene to use tweens instead of setting the opacity manually. Much smoother looking now
- Fixed an issue where the player's sprite would disappear while shooting, holding up or down, then double tapping a direction to make Bass dash.
- Fixed an issue where Mega Man could jump while under a low ceiling, therefore getting stuck.
- Fixed an issue where Mega Man retained his slide momentum when jumping after a slide.
- Fixed an issue where the player's slide momentum would still be active after falling from a platform during a slide.
- Redid the global values to take up fewer lines of code. For example, the playser_1d variable is now an array which stores both player's IDs when entering a level, rather than making them two separate variables.
- Fixed an issue where the player's sprite would sometimes fall down a one-block wide hole when sliding as Mega Man.
- Added color swapping functions.
- Fixed an issue where sliding above a ladder would trigger ladder functions and break normal movement.
- Fixed an issue where using a hitbox longer than the floor/wall tiles made the player's wobble ever so slightly up and down during a slide. Reducing the size of the slide hitbox fixed this. Most likely happened due to the move_and_slide() function.
- Fixed an issue where the player could not jump while up against a wall due to the slide_top node overlapping an obstacle. Regardless of sliding state.
- Made it so that player's could not activate a slide or dash when facing up against a wall.
- Added Mega/Proto Man's charge shot animations.
- Fixed a miscolored pixel in Proto Man's sprite sheet which caused part of his visor to swap colors.
- Fixed an issue where the player would get stuck under a low ceiling is they collide with a wall.
- Added quick swapping
- Fixed an issue when swapping weapons as Bass that turned him into a sweet walking rave party.
- Added weapon icons for L and R swapping.
- Made weapon firing more specific so that the functions only needs to be called a couple of times.
- Fixed an issue where Bass would go into a shooting stance regardless of the weapon equipped.
- Fixed a issue where releasing the fire button would keep Bass in his shooting frames.
- Started options menu.
- Added more to the options menu.
- Added graphics for the options menu and stage select.
- Global options and controls now load when the app starts. if a config file is not present one will be generated.
- Started on the stage select screen. Using a tilemap for the graphics instead of each mugshot being it's own separate object.
- Added transition from Stage Select to Player Select.
- Fixed an issue where tapping down on a ladder would set the incorrect ladder top coordinate.
- Added another portion of the map to help test the stage select/continue points.
- Fixed an issue where the camera.bottom_limit value was incorrectly assigned. Causing the camera to glitch when loading a different stage.
- Tweaked the camera function to allow for special scrolling conditions. (IE: Allowing the camera to scroll through a stage based on the player's Y position.)
- Added function to count screens for a potential endless mode.
- Fixed an issue where the incorrect room value would load at the beginning of a stage.
- Fixed the Screens counter issue caused by the previous bug.
- Made Rooms, Collision Mask, and Graphic control nodes to help make the tilesets more manageable.
- Added a tileset just for stage graphics.
- Removed duplicate tiles from stage graphics.
- Added another test stage modeled after Shadow Man's from Mega Man III.
- Started boss gate coding.
- Added a script that will load stage objects from a tilemap to make placement easier.
- Vertical boss gates completed.
- Horizontal boss gates completed.
- Fixed an issue where the climbing function would no cease when touching a floor from a one tile high ladder.
- Fixed an issue where the climbing function would not cease when touching the floor underwater.
- Started expanding the test stage to encompass more objects and make it easier for the player to return to the beginning.
- Splash effect added to water tiles.
- Bubble effect added to water tiles
- Added code to kill special effect sprites if off screen or panning the camera.
- Fixed an issue where the splash effect would not be centered on the player's X position.
- Started teleporter functions.
- Fixed a few issues with the fade in/out node.
- Added a graphic skin for the water section to resemble Wily Stage 3 from Mega Man 2.
- Fixed an issue where the player could slide through a teleporter and still trigger it's functions.
- Fixed an issue where the teleporter timer did not reset with repeated use.
- Added a table to help with player spawn and teleport points.
- Player now spawns from above mentioned table at the beginning of a stage.
- Fixed an issue where the player overlapping a teleport/spawn tile was not properly centered.
- Adjusted teleport animation play speed.
- Teleporters and continue points added.
- Relocated teleporter and player spawning script to the World script for ease of access.
- Adjusted the Y speed of the player during vertical scrolling.
- Added damage spark.
- Added slide smoke.
- Adjusted X movement when taking damage.
- Added the player's Death Boom.
- Made death tiles capable of killing the player.
- Fixed an issue where the player would sometimes get stuck in the floor if sliding immediately after landing on the floor.
- Added the HUD.
- Life Meter added.
- Weapon Meters added.
- Boss Meter added.
- Pits now kill the player.
- Life energy is restored when the stage restarts after a death.
- Fixed a 'Can't change state while flushing queries' error with the boss gates.
- Started pause menu.
- Added ability to change weapons in the pause menu.
- Fixed several issues with palette swapping and blinking of icons for the pause menu.
- Added lives counter.
- Made the player's hitbox slightly smaller.
- Reorganized scenes folder to make finding scenes and nodes easier.
- Started swap mechanic.
- Player is now forced into a swap if their HP hits 0, but not when contacting with a death tile.
- Added nodes to help animate the swap.
- Fixed an issue where the beam in animation didn't leave upon finishing.
- Fixed an issue where the player's sprite and the beam out animation could collide with one another.
- Fixed an issue where the incorrect idle animation would play depending on who the player swapped to.
- Started adding sound effects
- Moved code from _process() to _input() in the title screen.
- Simplified code in title screen.
- Start Mega/Proto/Bass Buster coding.
- Fixed an issue where the charge up sound would play when a different weapon was equipped.
- Fixed an issue where the charge loop would separate itself from the charge start sounds.
- Level 1 buster shots complete.
- Fixed an issue where Bass Buster bullets would not spawn at correct points.
- Fixed an issue where the player could dash as Bass while shooting.
- Fixed an issue where bullets would not pause when the rest of the game normally would.
- Exiting the pause menu with a different weapon than what was originally equipped kills all weapons on screen.
- Using weapon quick swap kills all weapons on screen.
- Fixed an iss where jumping the jump button would not allow the landing sound to play.
- Added level 2 shots to Mega/Proto Man
- Added level 3 shots for Mega/Proto Man
- Forced Proto Man's level 3 shot to stay on the player sprite as it's appear animation is playing.
- Fixed an issue where swapping while shooting sometimes causes the other player to have the previous one's palette.
- Fixed an issue where Proto Man could dash jump is both buttons were pressed at the same time.
- Weapons on screen are now destroyed upon swapping.
- Fixed an issue where the charge sound loop wouldn't loop.
- Rush Coil added.
- Fixed an issue where continuous shooting of the buster would prevent Rush from being called.
- Fixed an issue where weapons could interact with doors.
- Fixed an issue where energy meters only displayed 27 units instead of 28.
- Rush Coil completed.
- Started Rush Jet... And subsequently ran into a LOT of problems.
- Completely redid Rush Jet. Works more like it should.
- Fixed an issue where the player could turn around while riding Rush.
- Fixed an issue where the player could walk on Rush while riding him.
- Fixed an issue where the player's bullets would no sync up with the direction of the player's sprite.
- Fixed an issue where Rush's hitbox would prevent him from leaving the screen if a ceiling is in place.
- Rush Jet complete.
- Added Stationary met.
- Fixed an issue that allowed players to fire more than the normal amount of bullets on screen after a swap.
- Removed the spacebar dealing damage to the player.
- Added damage functions when coming in contact with enemies.
- Added death and respawn functions for enemies.
- Fixed an issue where the player would take additional damage upon a forced swap if the player was overlapping an enemy.
- Fixed an issue where the player would force swap endlessly.
- The player can now be killed by enemies.
- Fixed an issue where touching another obstacle type while standing on another (IE: Standing on snow, but walked into ice) would set the player to have the properties of the newly touched tile.
- Fixed an issue where Rush Coil could interact with the floor in rooms below the player.
- Completely redid the room data and enemy spawn code to make it more efficient.
- Enemies now spawn after a screen transition and are wiped when touching a screen edge or gate.
- Added a basic screen shake effect.
- Fixed a couple issues involving single room areas of the map. Both camera settings and enemy spawning.
- Fixed an issue where the game would crash if Rush touched an enemy.
- Fixed an issue where the player's charge value would prevent the default player palette from loading during a weapon swap.


Credits:
--

Special Thanks

harraps  
N64Mario  
Marc Wyzomirski  
Duane van Voorst  
GDQuest  
KidsCanCode  
GamesFromScratch  
Dlean Jeans  