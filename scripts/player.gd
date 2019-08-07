extends KinematicBody2D

signal teleport

#Use this to pull values from the World script.
onready var world = get_parent()
#Use this to get TileMap data.
onready var tiles = world.get_child(0).get_child(1)

#Player velocity constants
const RUN_SPEED = 90
const JUMP_SPEED = -310
const GRAVITY = 900

#Determines if the player can move or not.
var start_stage = false
var can_move = false
var lock_ctrl = false
var gate = false

#Handles the direction behing held on the D-Pad/Analog stick.
var x_dir
var y_dir
var left_tap
var right_tap
var jump
var jump_tap
var dash
var dash_tap
var fire
var fire_tap
var prev
var next
var select
var start

#Velocity and Position
var x_speed
var x_spd_mod = 1
var ice = false
var conveyor = 0
var grav_mod = 1
var velocity = Vector2()

#Animation and FSM
var play_anim = ''
var anim_st
var act_st
var shot_st
var player = ''
var texture = ''
var final_tex = ''

#Miscellaneous variables
var force_idle = true
var jumps = 1
var slide_timer = 0
var slide_act = 0
var slide_delay = 0
var slide_tap_dir
var slide_top = false
var wall = false
var slide = false
var shot_rapid = 0
var shot_delay = 0
var bass_dir = ''
var swap = false
var tile_pos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top = 0
var ladder_dir = 0
var lad_top_detect
var lad_top_overlap
var hurt_timer = 0
var blink_timer = 0
var blink = 0
var charge = 0
var c_flash = 0
var w_icon = 0

var dmg_button = false

#Player States
enum {
	BEAM,
	APPEAR,
	IDLE,
	LILSTEP,
	RUN,
	JUMP,
	SLIDE,
	CLIMB,
	CLIMBTOP,
	HURT,
	FALL,
	DEAD,
	STANDING,
	CLIMBING,
	NORMAL,
	SHOOT,
	HAND,
	BASSSHOT,
	THROW
	}

#Set the appropriate states and values
func _ready():
	anim_state(BEAM)
	act_state(STANDING)
	shot_state(NORMAL)
	change_char()
	
	#Set appropriate palette
	#Get the colors to be replaced.
	$sprite.material.set_shader_param('t_col1', global.t_color1)
	$sprite.material.set_shader_param('t_col2', global.t_color2)
	$sprite.material.set_shader_param('t_col3', global.t_color3)
	$sprite.material.set_shader_param('t_col4', global.t_color4)
	#Set transparent pixels.
	$sprite.material.set_shader_param('trans', global.trans)
	#Set colors
	world.palette_swap()
	

func _physics_process(delta):

	#Make the inputs easier to handle.
	if !lock_ctrl:
		x_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		left_tap = Input.is_action_just_pressed("left")
		right_tap = Input.is_action_just_pressed("right")
		jump = Input.is_action_pressed("jump")
		jump_tap = Input.is_action_just_pressed("jump")
		dash = Input.is_action_pressed("dash")
		dash_tap = Input.is_action_just_pressed("dash")
		fire = Input.is_action_pressed("fire")
		fire_tap = Input.is_action_just_pressed("fire")
		prev = Input.is_action_just_pressed("prev")
		next = Input.is_action_just_pressed("next")
		select = Input.is_action_just_pressed("select")
		start = Input.is_action_just_pressed("start")
	else:
		x_dir = 0
		y_dir = 0
		left_tap = false
		right_tap = false
		jump = false
		jump_tap = false
		dash = false
		dash_tap = false
		fire = false
		fire_tap = false
		prev = false
		next = false
		select = false
		start = false
	
	
	#TileMap Data function
	get_data()

	if w_icon > 0:
		if !$sprite/weap_icon_lr.visible:
			$sprite/weap_icon_lr.show()
		w_icon -= 1
	
	if w_icon == 0:
		$sprite/weap_icon_lr.hide()

	if !can_move:
		#Bring the sprite down aftfer READY vanishes.
		#NOTE: This will have to be modified when character swapping is implemented.
		if start_stage and $sprite.offset.y < -1:
			$sprite.offset.y += 8
		elif start_stage and $sprite.offset.y == -1:
			anim_state(APPEAR)
			start_stage = false

		if !start_stage and !$anim.is_playing() and anim_st == APPEAR:
			anim_state(IDLE)
			can_move = true
	else:
		if hurt_timer == 0:

			#Make the character blink after taking damage.
			if blink_timer > 0:

				blink += 1

				if blink == 2:
					hide()
				elif blink == 4:
					blink = 0
					show()

				blink_timer -= 1

				if blink_timer == 0:
					show()
		
			#Begin weapon functions.
			if slide_timer == 0:
				if fire_tap and global.player != 2 and global.player_weap[int(swap)] == 0 or fire_tap and global.player_weap[int(swap)] != 0:
					weapons()

				if fire and global.player == 2 and global.player_weap[int(swap)] == 0:
					shot_state(BASSSHOT)
					shot_rapid += 1

					if shot_rapid == 1:
						weapons()

					if shot_rapid >= 4:
						shot_rapid = 0

				if !fire and global.player == 2 and global.player_weap[int(swap)] == 0:
					shot_rapid = 0
			
			#Charge functions. Mega/Proto Man only.	
			if fire and charge < 99:
				charge += 1
				
			if charge >= 32:
				c_flash += 1
			
			if charge < 96 and c_flash > 3:
				c_flash = 0
			elif charge >= 96 and c_flash > 7:
				c_flash = 0

			if c_flash == 0 or c_flash == 2 or c_flash == 4 or c_flash == 6:
				world.palette_swap()
			
			if !fire and charge > 0 and global.player != 2:
				weapons()
				world.palette_swap()

			#Code to revert back to normal sprites.
			if shot_delay > 0:
				#Fix the animations.
				if shot_st == THROW or shot_st == BASSSHOT:
					if is_on_floor() and anim_st != IDLE:
						anim_state(IDLE)

				shot_delay -= 1

			if shot_delay == 0:
				bass_dir = ''
				shot_state(NORMAL)

			#The player's actions are divided into 3 main sections. Standing, Climbing and Sliding.
			if act_st == STANDING:
				
				#Set velocity.x to 0 if not standing on ice.
				if !ice:
					x_speed = 0
				
				#Transition to the little step.
				if x_dir != 0 and shot_st != THROW and shot_st != BASSSHOT and anim_st == IDLE and is_on_floor():
					anim_state(LILSTEP)
					if !ice:
						x_speed = (x_dir * RUN_SPEED) / x_spd_mod
				
				#Transition to the running animation.
				if play_anim == 'lilstep' and !$anim.is_playing() and x_dir != 0:
					anim_state(RUN)
				
				#Set X Velocity.
				if !slide:
					if anim_st == RUN:
						if shot_st != THROW and shot_st != BASSSHOT:
							if !ice:
								x_speed = (x_dir * RUN_SPEED) / x_spd_mod
							else:
								if x_dir == -1 and x_speed > -RUN_SPEED:
									x_speed -= 1
									if x_dir == -1 and x_speed > 0:
										x_speed -= 1
								elif x_dir == 1 and x_speed < RUN_SPEED:
									x_speed += 1
									if x_dir == 1 and x_speed < 0:
										x_speed += 1
					if anim_st == IDLE or anim_st == LILSTEP:
						if ice:
							if x_dir == 0 and x_speed > 0:
								x_speed -= 1
							elif x_dir == 0 and x_speed < 0:
								x_speed += 1
					if anim_st == JUMP:
						x_speed = (x_dir * RUN_SPEED) / x_spd_mod
				else:
					if is_on_floor():
						if $sprite.flip_h == true:
							x_speed = (-RUN_SPEED * 2) / x_spd_mod
						else:
							x_speed = (RUN_SPEED * 2) / x_spd_mod
					elif !is_on_floor():
						x_speed = ((x_dir * RUN_SPEED) * 2) / x_spd_mod
						
				#Transition back to idle if no longer running.
				if x_dir == 0 and anim_st == RUN and is_on_floor():
					anim_state(LILSTEP)
				if play_anim == 'lilstep' and !$anim.is_playing() and x_dir == 0:
					anim_state(IDLE)
				
				#Reset the jumps counter. Cancel sliding.
				if !jump and is_on_floor() and jumps == 0:
					jumps = 1
					slide = false
					slide_timer = 0
					x_speed = (x_dir * RUN_SPEED) / x_spd_mod
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
				
				#When the slide timer reaches 0. Cancel slide.
				if slide_timer == 0 and slide and is_on_floor() and !slide_top:
					if x_dir == 0:
						anim_state(IDLE)
					else:
						anim_state(RUN)
					if ice:
						if $sprite.flip_h == true:
							x_speed = -RUN_SPEED
						else:
							x_speed = RUN_SPEED
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				#When the player touches a wall. cancel sliding.
				if slide and is_on_wall() and !slide_top:
					anim_state(IDLE)
					slide_timer = 0
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				#When the player is no longer on the floor, cancel slide.
				if slide and !is_on_floor() and jumps > 0:
					slide = false
					slide_timer = 0
					jumps = 0
					anim_state(JUMP)
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
				
				#When the opposite direction is pressed on the ground, cancel slide.
				if slide:
					if !slide_top and $sprite.flip_h == true and x_dir == 1 or !slide_top and $sprite.flip_h == false and x_dir == -1:
						anim_state(IDLE)
						slide_timer = 0
						$standbox.set_disabled(false)
						$slidebox.set_disabled(true)
						slide = false

				#Change the player's animation based on if they're on the floor or not.
				if !is_on_floor() and anim_st != JUMP and !force_idle:
					anim_state(JUMP)
					jumps = 0
				elif is_on_floor() and anim_st == JUMP and x_dir == 0:
					anim_state(IDLE)
				elif is_on_floor() and anim_st == JUMP and x_dir != 0:
					anim_state(RUN)
					
				#Make the player jump.
				if global.player == 0 and y_dir != 1 and jump_tap and is_on_floor() and jumps > 0 and !slide_top:
					jumps -= 1
					velocity.y = JUMP_SPEED
					slide = false
				elif global.player != 0 and jump_tap and is_on_floor() and jumps > 0:
					if slide_timer > 0:
						if global.player != 2:
							slide_timer = 0
							slide = false
						else:
							slide_timer = 0
					jumps -= 1
					velocity.y = JUMP_SPEED
				
				#Set gravity modifier
				if overlap == 6 or overlap == 7 or overlap == 12 or overlap == 13 or global.low_grav:
					grav_mod = 3
				else:
					grav_mod = 1
				
				#Set velocity.y to 0 when releasing the jump button before reaching the peak of a jump.;
				if !jump and velocity.y < 0:
					velocity.y = 0
				
				#This is a small fix to prevent the jumping sprite from appearing during some animations.
				if force_idle and is_on_floor():
					force_idle = false
				
				#Change the player direction.
				if x_dir < 0:
					$sprite.flip_h = true
					$slide_wall.position.x = -7
				elif x_dir > 0 :
					$sprite.flip_h = false
					$slide_wall.position.x = 7
				
				if slide:
					if global.player == 0:
						$slide_top/area.set_disabled(false)
					else:
						$slide_top/area.set_disabled(true)
				else:
					$slide_top/area.set_disabled(true)
					
				#Begin sliding functions.
				if global.player == 0:
					if y_dir == 1 and jump_tap and is_on_floor() and !wall:
						anim_state(SLIDE)
						slide_timer = 15
						slide = true
						$standbox.set_disabled(true)
						$slidebox.set_disabled(false)
				else:
					if dash_tap and is_on_floor() and !wall:
						anim_state(SLIDE)
						slide_timer = 15
						slide = true
						shot_state(NORMAL)
						bass_dir = ''
					
					if is_on_floor() and y_dir == 0 and !wall:
						if slide_act == 0:
							if left_tap or right_tap:
								slide_delay = 16
								slide_tap_dir = x_dir
								slide_act += 1
						
						if slide_act == 1:
							if !left_tap and !right_tap:
								slide_act += 1
								
						if slide_act == 2:
							if left_tap and slide_tap_dir == -1 or right_tap and slide_tap_dir == 1:
								slide = true
								slide_timer = 15
								anim_state(SLIDE)
								slide_delay = 0
								slide_act = 0
								slide_tap_dir = 0
								shot_state(NORMAL)
								bass_dir = ''
							elif left_tap and slide_tap_dir == 1 or right_tap and slide_tap_dir == -1:
								slide_delay = 0
								slide_act = 0
								slide_tap_dir = 0
						
						if slide_delay > 0:
							slide_delay -= 1
						
						if slide_delay == 0:
							slide_act = 0
							slide_tap_dir = 0
				
				if slide_timer > 0:
					slide_timer -= 1
				
				#Begin climbing functions.
				#When the player presses up while overlapping a ladder.
				if overlap == 3 or overlap == 4 or overlap == 12 or overlap == 13:
					if y_dir == -1:
						#Lock the direction the sprite was facing.
						if $sprite.flip_h == true:
							ladder_dir = -1
						else:
							ladder_dir = 1
						$sprite.flip_h = false
						anim_state(CLIMB)
						x_speed = 0
						position.x = ladder_set
						velocity = Vector2(0, 0)
						jumps = 1
						slide = false
						slide_timer = 0
						force_idle = true
						act_state(CLIMBING)
				
				#If the player presses down while on a ladder.
				if stand_on == 3 or stand_on == 12:
					if y_dir == 1 and is_on_floor() and !slide and !fire:
						shot_state(NORMAL)
						if $sprite.flip_h == true:
							ladder_dir = -1
						else:
							ladder_dir = 1
						$sprite.flip_h = false
						anim_state(CLIMB)
						x_speed = 0
						position.x = ladder_set
						position.y += 6
						ladder_top = (tile_pos.y * 16) + 9
						velocity = Vector2(0, 0)
						jumps = 1
						slide = false
						slide_timer = 0
						force_idle = true
						act_state(CLIMBING)

			elif act_st == CLIMBING:
				
				if $standbox.is_disabled():
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					
				#Change the direction based on if the player is shooting or not.
				if x_dir != 0:
					ladder_dir = x_dir

				if shot_st == NORMAL or shot_st != NORMAL and ladder_dir == 1:
					$sprite.flip_h = false
				elif shot_st != NORMAL and ladder_dir == -1:
					$sprite.flip_h = true

				#Set the appropriate animation.
				if lad_top_overlap != -1 and lad_top_overlap != 6 and lad_top_overlap != 7:
					if anim_st != CLIMB:
						anim_state(CLIMB)
				elif lad_top_overlap == -1 or lad_top_overlap == 6 or lad_top_overlap == 7:
					if anim_st != CLIMBTOP:
						anim_state(CLIMBTOP)
						if ladder_top == 0:
							ladder_top = (tile_pos.y * 16) - 7

				#Move the player.
				if y_dir != 0 and shot_st == NORMAL:
					$anim.play()
					velocity.y = (y_dir * RUN_SPEED) * 0.9
				else:
					$anim.stop(false)
					velocity.y = 0

				#End ladder functions.
				#When the player reaches the top of a ladder.
				if y_dir == -1 and floor(position.y) <= ladder_top:
					ladder_top = 0
					position.y -= 6
					velocity.y = 300
					act_state(STANDING)
					anim_state(IDLE)

				#When the player reaches the bottom of a ladder.
				if y_dir == 1 and lad_top_overlap == -1 and stand_on == -1:
					ladder_top = 0
					act_state(STANDING)
					anim_state(JUMP)

				#When the player touches the floor while climbing.
				if y_dir == 1 and is_on_floor():
					if overlap == 3 or overlap == 4 or overlap == 6 or overlap == 7:
						ladder_top = 0
						velocity.y = 300
						act_state(STANDING)
						anim_state(IDLE)

				#When the player presses jump.
				if jump_tap:
					ladder_top = 0
					act_state(STANDING)
					anim_state(JUMP)
				
		else:
			#Kick the player back to the Standing action state unless they are trapped under a low ceiling.
			if !slide_top:
				act_state(STANDING)
				slide_timer = 0
				slide = false

			#Move the player backwards, unless they are caught in the sliding animation.
			if slide_top:
				x_speed = 0
			else:
				if $sprite.flip_h == true:
					velocity.x = (RUN_SPEED * 0.8) / x_spd_mod
					x_speed = RUN_SPEED
				else:
					velocity.x = (-RUN_SPEED * 0.8) / x_spd_mod
					x_speed = -RUN_SPEED

			hurt_timer -= 1
			#When hurt_timer reaches 0, start blinking functions.
			if hurt_timer == 0:
				blink_timer = 96
				if is_on_floor() and !slide_top:
					anim_state(IDLE)
				elif !is_on_floor():
					anim_state(JUMP)
				elif is_on_floor() and slide_top:
					anim_state(SLIDE)

		#Use GRAVITY to pull the player down.
		if act_st != CLIMBING:
			velocity.x = x_speed
			velocity.y += (GRAVITY / grav_mod) * delta

		#Set the maximum downward velocity.
		if velocity.y > 500:
			velocity.y = 500

		#Gravity/Conveyors affect the player so long as they are not climbing.
		if act_st != CLIMBING:
			#Move the player if on a conveyor.
			if conveyor == 1:
				# warning-ignore:integer_division
				velocity.x += RUN_SPEED / 2
			if conveyor == 2:
				# warning-ignore:integer_division
				velocity.x -= RUN_SPEED / 2
			if conveyor == 3:
				velocity.x += RUN_SPEED
			if conveyor == 4:
				velocity.x -= RUN_SPEED

		#WARNING! DEBUG FUCKERY AHEAD!
		#Replace this with an Area Enter Body code when enemies and hazards are in place.
		if Input.is_key_pressed(KEY_SPACE) and anim_st != HURT and !dmg_button:
			dmg_button = true
			velocity.y = 0

			anim_state(HURT)
			hurt_timer = 16

		if !Input.is_key_pressed(KEY_SPACE) and anim_st != HURT and dmg_button:
			dmg_button = false

		#Move the player
		velocity = move_and_slide(velocity, Vector2(0, -1))
		#Get what the player is standing on.
		for idx in range(get_slide_count()):
			var collision = get_slide_collision(idx)

			if is_on_floor() and collision.collider.name == 'tiles' or is_on_floor() and collision.collider.name == 'death':
				x_spd_mod = 1
				conveyor = 0
				ice = false

			if is_on_floor() and collision.collider.name == 'snow':
				x_spd_mod = 2

			if is_on_floor() and  collision.collider.name == 'slw_conv_r':
				conveyor = 1
			elif is_on_floor() and collision.collider.name == 'slw_conv_l':
				conveyor = 2
			elif is_on_floor() and collision.collider.name == 'fst_conv_r':
				conveyor = 3
			elif is_on_floor() and collision.collider.name == 'fst_conv_l':
				conveyor = 4

			if is_on_floor() and collision.collider.name == 'ice':
				ice = true

		#This is a small fix to handle the x speed modifier.
		if !is_on_floor():
			x_spd_mod = 1
			conveyor = 0
			ice = false

		#Print Shit
		

#There are 3 states that the player will call. Animation, Action, and Shot
#Pull the matching Animation State and set the animation accordingly.
func anim_state(new_anim_state):
	anim_st = new_anim_state
	match anim_st:
		BEAM:
			change_anim('beam')
		APPEAR:
			if global.player != 2:
				change_anim('appear1')
			else:
				change_anim('appear2')
		IDLE:
			if global.player != 1:
				change_anim('idle1')
			else:
				change_anim('idle2')
		LILSTEP:
			change_anim('lilstep')
		RUN:
			change_anim('run')
		JUMP:
			change_anim('jump')
		SLIDE:
			change_anim('slide')
		CLIMB:
			change_anim('climb')
		CLIMBTOP:
			change_anim('climbtop')
		HURT:
			change_anim('hurt')
		FALL:
			change_anim('fall')


func change_anim(new_anim):
	play_anim = new_anim
	$anim.play(play_anim)

#Pull the action state.
func act_state(new_act_state):
	act_st = new_act_state
	match act_st:
		DEAD:
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()

#Pull the shooting/throwing state and set the appropriate texture.
func shot_state(new_shot_state):
	shot_st = new_shot_state
	match shot_st:
		NORMAL:
			texture = '-norm'
			change_char()
		SHOOT:
			texture = '-shoot'
			change_char()
		BASSSHOT:
			texture = '-shoot'
			change_char()
		THROW:
			texture = '-throw'
			change_char()

#Pull the player's texture sheet.
func change_char():
	global.player = global.player_id[int(swap)]
	
	if global.player == 0:
		$slide_wall.position.y = 5
	else:
		$slide_wall.position.y = 0

	if global.player == 2 and shot_st == BASSSHOT:
		if global.player_weap[int(swap)] == 0:
			if x_dir == 0 and y_dir == -1:
				bass_dir = '-up'
			elif x_dir != 0 and y_dir == -1:
				bass_dir = '-d-up'
			elif x_dir != 0 and y_dir == 1 or x_dir == 0 and y_dir == 1:
				bass_dir = '-d-down'
			elif x_dir != 0 and y_dir == 0 or x_dir == 0 and y_dir == 0:
				bass_dir = ''

	if global.player == 0:
		player = 'mega'
	elif global.player == 1:
		player = 'proto'
	elif global.player == 2:
		player = 'bass'

	final_tex = str(player+texture+bass_dir)

	$sprite.texture = load('res://assets/sprites/player/'+final_tex+'.png')

#Disable player input during camera transitions.
func _on_world_scrolling():
	if !can_move:
		can_move = true
	else:
		can_move = false

#Begin stage start functions.
func _on_ready_start():
	start_stage = true

#Pull needed data
func get_data():
	#Get tile position
	tile_pos = tiles.world_to_map(position)

	#Get the tile that the player is standing on.
	stand_on = tiles.get_cellv(Vector2(tile_pos.x, tile_pos.y + 1))

	#Get the tile that the player is overlapping.
	overlap = tiles.get_cellv(tile_pos)

	#Get the X coordinate that the player will snap to when grabbing a ladder.
	ladder_set = (tile_pos.x * 16) + 8

	#Get the position and overlap of the ladder top detector
	lad_top_detect = tiles.world_to_map($lad_top_detect.global_position)
	lad_top_overlap = tiles.get_cellv(lad_top_detect)

#Determine whether the slide_top detector is overlapping an obstacle.
# warning-ignore:unused_argument
func _on_slide_top_body_entered(body):
	slide_top = true

# warning-ignore:unused_argument
func _on_slide_top_body_exited(body):
	slide_top = false

# warning-ignore:unused_argument
func _on_slide_wall_body_entered(body):
	wall = true

# warning-ignore:unused_argument
func _on_slide_wall_body_exited(body):
	wall = false

func weapons():
	#Set timer for the shooting/throwing sprites.
	shot_delay = 20

	#NOTE: Edit this section as weapons become usable.
	if global.player != 2:
		if !slide:
			#Mega Buster/Proto Strike
			if global.player_weap[int(swap)] == 0 and charge < 32:
				shot_state(SHOOT)
			elif global.player_weap[int(swap)] == 0 and charge >= 32 and charge < 96:
				shot_state(SHOOT)
			elif global.player_weap[int(swap)] == 0 and charge >= 96:
				shot_state(SHOOT)
		charge = 0
		c_flash = 0

	#Bass Only
	if global.player == 2:
		#Bass Buster
		pass


func _on_anim_animation_finished(appear1):
	print('next area!')
	emit_signal('teleport')
