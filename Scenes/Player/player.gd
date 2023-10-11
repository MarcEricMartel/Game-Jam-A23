extends Node2D

var currentSpawnableScene : PackedScene = null
var currentStateIcon : Texture2D = null
var spawnedMonsters : Array = []
@onready var menuZone : Control = $Camera2D/CanvasLayer/PlayerUI.menuZone
@onready var enemy : CharacterBody2D = $"../Enemy"
@onready var playableArea : Area2D = $"../PlayableArea"
@onready var cursorState : Node2D = $CursorState

var isInPlayableArea : bool = false

func _ready():
	playableArea.mouse_entered.connect(entered_playable_area)
	playableArea.mouse_exited.connect(exited_playable_area)

func _process(delta):
	handle_menu_inputs()
	handle_spawn()
	handle_cursor_state()
	
func add_monster(monster : TemplateSpawnable):
	spawnedMonsters.append(monster)

func remove_monster(monster : TemplateSpawnable):
	spawnedMonsters.erase(monster)

func entered_playable_area():
	cursorState.set_cursor_state("", currentStateIcon)
	isInPlayableArea = true

func exited_playable_area():
	cursorState.set_cursor_state("out of bounds", null)
	isInPlayableArea = false

func handle_menu_inputs():
	if Input.is_action_just_pressed("fullscreen_toggle"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()

func handle_spawn():
	if Input.is_action_just_pressed("place_spawnable"):
		spawn_current()

func handle_cursor_state():
	cursorState.visible = !is_in_menu()
	cursorState.global_position = get_global_mouse_position()

func spawn_current():
	if !isInPlayableArea || is_in_menu() || currentSpawnableScene == null:
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
		currentStateIcon = null
		cursorState.set_cursor_state("", null)
		return
	
	currentStateIcon = currentButton.spawnableIcon
	currentSpawnableScene = currentButton.spawnableScene
	cursorState.set_cursor_state("", currentStateIcon)
