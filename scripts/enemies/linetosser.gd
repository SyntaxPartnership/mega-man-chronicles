extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var behind = world.get_child(1).get_child(1)
onready var front = world.get_child(1).get_child(2)

func _ready():
	behind.remove_child(self)
	front.add_child(self)