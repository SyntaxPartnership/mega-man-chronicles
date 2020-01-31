extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(9)
onready var behind = world.get_child(1).get_child(1)
onready var front = world.get_child(1).get_child(2)

var start_pos = Vector2()

var id = 1
#Choke Hand value. Standard is 8 for enemies. 3 for bosses.
const CHOKE = 8

var dist

#Enemy HP.
const DEFAULT_HP = 40
var hp = 40

#Damage enemy does to the player.
var touch = false
var damage = 20

#Other
var dead = false
var flash = false
var f_delay = 0

var begin = false
var safety = false
var dbl_safety = false
var state = 0
var toss = false

const JUMP_SPEED = -210
const GRAVITY = 900

var overlap = []

var velocity = Vector2()

func _ready():
	start_pos = position

func _physics_process(delta):
	
	var cam_pos = camera.get_camera_position()
	
	#Begin movement.
	if !begin:
		if player.global_position > global_position and global_position.distance_to(player.global_position) < 96:
			$anim.play("shock")
			world.sound("shock")
			$sprite/shock.show()
			begin = true
	
	if begin:
		if velocity.y > 0 and state == 0:
			state = 1
			$anim.play("jump-front")
			$hitbox/box.disabled = false
			behind.remove_child(self)
			front.add_child(self)
			safety = true
		
		if state == 1 and is_on_floor() and !dead:
			$anim.play('throw')
			state = 2
		
		if $sprite.frame == 4 and !toss:
			world.sound("throw")
			
			var bull_vel = lerp(0, position.distance_to(player.position), 1.2)
			
			var stick = load("res://scenes/enemies/rave_bullet.tscn").instance()
			stick.get_child(2).flip_h = $sprite.flip_h
			stick.x_spd = bull_vel
			stick.global_position = global_position
			world.get_child(1).add_child(stick)
			
			toss = true
		
		if $sprite.frame != 4 and toss:
			toss = false
	
	velocity.y += GRAVITY * delta
	
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
						world.sound("hit")
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
						world.sound("hit")
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
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	if hp <= 0 and !dead:
		spawn_item()
		$anim.play("idle")
		dead = true
		flash = false
		f_delay = 0
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
	
	if dbl_safety:
		front.remove_child(self)
		behind.add_child(self)
		dbl_safety = false

	if dead:
		return

func _on_anim_finished(anim_name):
	
	if anim_name == "shock":
		$sprite/shock.hide()
		$anim.play("jump-back")
		velocity.y = JUMP_SPEED
	
	if anim_name == 'throw':
		if player.global_position < global_position:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
		$anim.play("throw")
		

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
	if safety:
		dbl_safety = true
		$anim.play('idle')
		state = 0
		$hitbox/box.disabled = true
		position = start_pos
		begin = false
		safety = false

