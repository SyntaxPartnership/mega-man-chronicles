extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var tile_map = world.get_child(0)
onready var mstr_map = tile_map.get_child(1)
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 300
var dir = Vector2(1, 1)
var velocity = Vector2()

var prev_tile_pos = Vector2()
var tile_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("idle")
	
	if p_sprite.flip_h:
		$sprite.flip_h = true
		dir.x = -1

func _physics_process(delta):
	
	tile_pos = mstr_map.world_to_map(global_position)
	
	velocity = dir * SPEED
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_wall():
		print('wall')
