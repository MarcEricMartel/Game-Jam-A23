extends Node2D

@export var batTemplatePath : PackedScene

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("place_spawnable"):
		spawnBat()

func spawnBat():
	var bat = batTemplatePath.instantiate()
	bat.global_position = get_global_mouse_position()
	$"..".add_child(bat)
	$"../Enemy".add_foe(bat)
