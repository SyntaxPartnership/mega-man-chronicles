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
Quick Select (1) | N/A | [R Analog]
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


Credits:
--

Special Thanks

harraps  
N64Mario  
Marc Wyzomirski  
Duane Von Voorst  
GDQuest  
KidsCanCode  
GamesFromScratch  