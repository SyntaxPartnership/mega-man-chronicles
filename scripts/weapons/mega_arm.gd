extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 350
const RET_SPD = 700
const ST_FORCE = 30
const RET_FORCE = 90
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

var overlap = []
var targets = []
var nearest
var f_target

var velocity = Vector2()
var accel = Vector2.ZERO

#This is a new variable that will dictate how the shot reacts when striking an enemy.
#0: Disappear
#1: Pierce
#2: Pierce if HP is equal or lower than damage.
#3: Pierce if HP is equal or lower than damage. Begin return script.
var property = 3

func _ready():
	$anim.play("idle")
	world.sound("shoot_b")
	
	get_targets()
	
	if level == 0:
		id = 0
		dist = 5
	else:
		id = 1
		dist = 20
	
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		dir.x = -1
	else:
		dir.x = 1
	
	velocity.x = dir.x * SPEED
	
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)

func _physics_process(delta):
	
	if !choke:
		if !ret:
			if global.perma_items.get("seeker_hand") and f_target != null:
				accel = seek()
				velocity += accel
				velocity.clamped(SPEED)
		else:
			if f_target != player:
				f_target = player
			
			accel = seek()
			velocity += accel
			velocity.clamped(RET_SPD)
		
		position += velocity * delta
		
	dist -= 1

	if dist == 0 and !choke:
		$anim.play("return")
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
	
	#If the player has acquire the magnet hand...
	if global.perma_items.get('magnet_hand'):
		overlap = $player_detect.get_overlapping_bodies()
		
		if overlap != []:
			for body in overlap:
				if body.is_in_group('items') and body.grab == 0:
					body.global_position = global_position
	
func _on_player_detect_body_entered(body):
	if body.name == "player":
		if ret:
			world.sound("connect")
			player.shot_state(player.NORMAL)
			world.shots = 0
			player.cooldown = false
			queue_free()

func choke_check():
	if global.perma_items.get('choke_hand'):
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

func seek():
	var steer = Vector2.ZERO
	var desired = Vector2.ZERO
	if !ret:
		desired = (f_target.position - position).normalized() * SPEED
		steer = (desired - velocity).normalized() * ST_FORCE
	else:
		desired = (f_target.position - position).normalized() * RET_SPD
		steer = (desired - velocity).normalized() * RET_FORCE
	return steer

func get_targets():
	targets = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("boss")
	
	nearest = targets[0]
	
	for t in targets:
		if !t.dead:
			if t.global_position.distance_to(global_position) < nearest.global_position.distance_to(global_position):
				f_target = t