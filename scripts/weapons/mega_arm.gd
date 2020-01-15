extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 350
var level = 0
var dir = Vector2()
var id = 0
var dist = 0
var ret = false
var choke = false
var choke_max = 0
var choke_delay = 0
var reflect = false
var x_lock = false
var y_lock = false

var velocity = Vector2()

#This is a new variable that will dictate how the shot reacts when striking an enemy.
#0: Disappear
#1: Pierce
#2: Pierce if HP is equal or lower than damage.
#3: Pierce if HP is equal or lower than damage. Begin return script.
var property = 3

func _ready():
	$anim.play("idle")
	world.sound("shoot_b")
	
	if level == 0:
		id = 0
		dist = 10
	else:
		id = 1
		dist = 24
	
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		dir.x = -1
	else:
		dir.x = 1
	
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)

func _physics_process(delta):
	
	if !choke:
		if !ret:
			velocity.x = dir.x * SPEED
		else:
			if !x_lock:
				if global_position.x >= player.global_position.x and dir.x == 1:
					x_lock = true
				elif global_position.x <= player.global_position.x and dir.x == -1:
					x_lock = true

				if global_position.x < player.global_position.x and dir.x == 0:
					dir.x = 1
				elif global_position.x > player.global_position.x and dir.x == 0:
					dir.x = -1

				velocity.x = dir.x * SPEED

			if !y_lock:
				if global_position.y >= player.global_position.y and dir.y == 1:
					y_lock = true
				elif global_position.y <= player.global_position.y and dir.y == -1:
					y_lock = true

				if global_position.y < player.global_position.y:
					dir.y = 1
					velocity.y = SPEED
				else:
					dir.y = -1
					velocity.y = -SPEED

			if x_lock:
				velocity.x = 0
				global_position.x = player.global_position.x

			if y_lock:
				velocity.y = 0
				global_position.y = player.global_position.y
		
		velocity = move_and_slide(velocity, Vector2(0, -1))
	
	dist -= 1
	
	if dist == 0 and !choke:
		$anim.play("return")
		dir.x = 0
		reflect = true
		ret = true
	
	if choke:
		if $sprite.flip_h:
			$sprite.offset.x -= 0.25
		else:
			$sprite.offset.x += 0.25
			
		if $sprite.offset.x < -1.75 or $sprite.offset.x > 1.75:
			$sprite.offset.x = 0
	
		if choke_delay > 0:
			choke_delay -= 1
	
	print(choke_delay)
	
func _on_player_detect_body_entered(body):
	if body.name == "player":
		if ret:
			world.sound("connect")
			player.shot_state(player.NORMAL)
			world.shots = 0
			player.cooldown = false
			queue_free()

func choke_check():
	if global.perma_items.has('choke_hand'):
		if !choke:
			velocity = Vector2(0, 0)
			dir.x = 0
			dir.y = 0
			$anim.play('choke')
			choke = true
			reflect = true
			ret = true
			dist = 0
	else:
		dist = 1
		reflect = true
