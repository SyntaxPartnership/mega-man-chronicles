extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for set in (10):
		var overlap = $hit_box_top.get_overlapping_bodies()
		$hit_box_top.position.y -= 16
		$sprite_top.position.y -= 16
		print(overlap)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
