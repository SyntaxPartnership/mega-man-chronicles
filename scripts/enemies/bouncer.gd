extends KinematicBody2D

signal dead

#Get the player and world nodes.
onready var world = get_parent().get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var id = 1
const CHOKE = 8

#Starting X and Y coordinates. To allow the enemy to respawn when off screen.
var start_pos = Vector2()

#The distance between the player and enemy.
var dist

#Enemy HP.
const DEFAULT_HP = 200
var hp

#Damage enemy does to the player.
var touch = false
var damage = 60

var overlap = []

var dead = false
var flash = false
var f_delay = 0

#Variables for this enemy
#Velocity
var velocity = Vector2()
var x_speed = 0
const GRAVITY = 900
const JUMP_SPEED = -400

#AI
var state = 0
const DEF_TIME = 60
var time = 60
var attack = false
var reset = false
var dash_time = 0
var nod_time = 80

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	hp = DEFAULT_HP
	
	dist = global_position.distance_to(player.global_position)
	
	if global_position.x > player.global_position.x:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false
	
	print(world.bncr_aggro)
	
	if world.bncr_aggro == 0:
		state = 10
		$hitbox/box.set_deferred("disabled", true)
	
	$anim.play("idle")

func _physics_process(delta):
	print(state,', ',time)
	
	
	if !dead:
		if state != 10:
			if time > -1:
				time -= 1
		else:
			if nod_time > -1:
				nod_time -= 1
	
	if time == 30:
		if global_position.x > player.global_position.x:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
	
	if time == 0:
		state = round(rand_range(0, 1))
		attack = true
		pick_attack()
	
	if nod_time == 0:
		pass
	
	if state == 3:
		if dash_time == 1 or is_on_wall():
			$screech.play()
		
		if dash_time > 0:
			dash_time -= 1
		
		if dash_time == 0:
			if x_speed < 0:
				x_speed += 10
			elif x_speed > 0:
				x_speed -= 10
		
		if is_on_wall():
			x_speed = 0
			dash_time = 0
			$anim.play_backwards("jets")
			reset = true
		
		if x_speed == 10 or x_speed == -10:
			$anim.play_backwards("jets")
			reset = true
	
	if state == 2:
		if velocity.y > 0:
			state = 4
	
	if state == 4:
		if is_on_floor() and $anim.get_current_animation() == "jump":
			x_speed = 0
			$land.play()
			$anim.play("squat")
			reset = true
			state = 6
	
	velocity.x = x_speed
	velocity.y += GRAVITY * delta
	
	position.x = clamp(position.x, camera.limit_left, camera.limit_right)
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Check to see if weapons or the player is overlapping.
	overlap = $hitbox.get_overlapping_bodies()
	
	#if true
	if overlap != []:
		for body in overlap:
			if body.is_in_group("weapons") or body.is_in_group("adaptor_dmg"):
				if !dead and !flash:
					world.enemy_dmg(id, body.id)
					if world.damage != 0 and !body.reflect:
						if !body.reflect:
						#Weapon behaviors.
							match body.property:
								0:
									body._on_screen_exited()
								2:
									if world.damage < hp:
										body._on_screen_exited()
								3:
									if world.damage < hp:
										body.choke_check()
										body.choke_max = CHOKE
										body.choke_delay = 6
										body.velocity = -velocity
							hp -= world.damage
							$sprite.hide()
							flash = true
							f_delay = 2
							#Play sounds for taking damage.
							if hp > 0:
								world.sound("hit")
							else:
								world.sound("explode_a")
						else:
							if body.property != 3:
								body.reflect = true
							else:
								if !body.ret:
									body.ret()
			
			if body.name == "mega_arm" and body.choke:
				body.global_position = global_position
				if !dead and !flash and body.choke_delay == 0:
					if body.choke_max > 0:
						hp -= 10
						body.choke_max -= 1
						body.choke_delay = 6
						$sprite.hide()
						flash = true
						f_delay = 2
						#Play sounds for taking damage.
						if hp > 0:
							world.sound("hit")
						else:
							world.sound("explode_a")
				elif dead or body.choke_max == 0:
					body.choke = false
					body.choke_delay = 0
							
			if body.name == "player" and !dead:
				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
					global.player_life[int(player.swap)] -= damage
					player.damage()
	
	if flash and f_delay > 0:
		f_delay -= 1
	
	if f_delay == 0 and flash:
		$sprite.show()
		flash = false
	
	if hp <= 0 and !dead:
		spawn_item()
		$sprite.hide()
		$anim.play("idle")
		dead = true
		flash = false
		state = 0
		time = DEF_TIME
		f_delay = 0
		reset = 0
		emit_signal("dead")
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/l_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		
func pick_attack():
	if attack:
		if state == 0:
			$anim.play("squat")
			state = 2
		else:
			$anim.play("jets")
			state = 3
		attack = false

func _on_anim_finished(anim_name):
	if anim_name == "squat":
		if state == 2:
			$anim.play("jump")
			x_speed = lerp(0, position.distance_to(player.position), 1)
			
			if player.global_position.x < global_position.x:
				x_speed = -x_speed
				
			velocity.y = JUMP_SPEED
		if state == 6:
			$anim.play("idle")
			time = DEF_TIME
			reset = false
	
	if anim_name == "jets":
		if !reset:
			if $sprite.flip_h:
				x_speed = -250
			else:
				x_speed = 250
			dash_time = 20
			$dash.play()
			$anim.play("dash")
		else:
			$anim.play("idle")
			time = DEF_TIME
			reset = false

func spawn_item():
	world.item_drop()
	
	if world.item[0] != '':
		var spawn = load("res://scenes/objects/"+world.item[0]+".tscn").instance()
		spawn.global_position = global_position
		spawn.type = world.item[1]
		spawn.time = 420
		spawn.velocity.y = spawn.JUMP_SPEED
		world.get_child(1).add_child(spawn)

func _on_screen_exited():
	if dead:
		dead = false
		$sprite.show()
		hp = DEFAULT_HP
