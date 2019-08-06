extends Node2D

func _ready():
	$anim.play('splash')

func _on_anim_animation_finished(splash):
	queue_free()
