extends Node2D

@export var batTemplatePath : PackedScene

func _ready():
	pass
	
func _process(delta):
	handle_menu_inputs()
	
	if Input.is_action_just_pressed("place_spawnable"):
		spawn_bat()

func handle_menu_inputs():
	if Input.is_action_just_pressed("fullscreen_toggle"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN

func spawn_bat():
	var bat = batTemplatePath.instantiate()
	bat.global_position = get_global_mouse_position()
	$"..".add_child(bat)
	$"../Enemy".add_foe(bat)
