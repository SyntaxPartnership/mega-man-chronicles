extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(8)

const X_VEL = 25
const Y_VEL = 25
const BEAM_SPD = 400

var time = 240
var f_delay = 0
var use_energy = 0
var x_dir = 0
var y_dir = 0
var on_floor = false
var leave = false
var flying = false
var wall = false
var velocity = Vector2()

func _ready():
	$anim.play("beam")

func _physics_process(delta):
	#Check to see if Rush has room to land.
	if position.y > player.position.y - 32 and $block_det.get_overlapping_bodies() == []:
		if !leave and !on_floor:
			$floor_det.set_disabled(false)
	
	#Handle the up and down movement when flying.
	y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	#Set Rush's velocity.
	if flying:
		if $sprite.flip_h:
			x_dir = -1 * X_VEL
		else:
			x_dir = 1 * X_VEL
			
		var collision = move_and_collide(Vector2((x_dir) * delta, (y_dir * Y_VEL) * delta))
		
		if collision:
			pass
	
	else:
		if !on_floor:
			velocity.y = BEAM_SPD
		else:
			if leave:
				velocity.y = -BEAM_SPD
		
		velocity = move_and_slide(velocity, Vector2(0, -1))
	
	
	#Begin jet functions.
	if is_on_floor() and !on_floor:
		$anim.play("appear")
		on_floor = true
		$block_det/box.set_disabled(true)
		$floor_det.queue_free()

func _on_anim_finished(anim_name):
	if anim_name == "appear":
		if !flying and time > 0:
			$anim.play("transform")
			$sprite.flip_h = player.get_child(3).flip_h
			$jet_box/box.set_disabled(false)
		
		if time <= 0 or wall:
			$anim.play("beam")
			leave = true
			$jet_box/box.set_disabled(true)
	
	if anim_name == "transform":
		$anim.play("idle")
