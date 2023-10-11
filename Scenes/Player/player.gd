extends Node2D

var currentSpawnableScene : PackedScene = null
@onready var menuZone : Control = $Camera2D/CanvasLayer/PlayerUI.menuZone
@onready var enemy : CharacterBody2D = $"../Enemy"

func _process(delta):
	handle_menu_inputs()
	handle_spawn()

func handle_menu_inputs():
	if Input.is_action_just_pressed("fullscreen_toggle"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN

func handle_spawn():
	if Input.is_action_just_pressed("place_spawnable"):
		spawn_current()

func spawn_current():
	if is_in_menu() || currentSpawnableScene == null:
		return
	var spawnable = currentSpawnableScene.instantiate()
	spawnable.global_position = get_global_mouse_position()
	$"..".add_child(spawnable)
	if enemy != null:
		enemy.add_foe(spawnable)
	
	
func is_in_menu():
	return menuZone.get_rect().has_point(get_local_mouse_position())
	



func _on_player_ui_button_changed(currentButton):
	if currentButton == null:
		currentSpawnableScene = null
		return
	
	currentSpawnableScene = currentButton.spawnableScene
	
