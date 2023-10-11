extends Node2D

const BASE_BLOOD_GEN = 10
const STARTING_BLOOD_AMOUNT = 100

var currentBloodAmount : int = 0
var currentBloodGen : float = 0
var currentSpawnableScene : PackedScene = null
var currentRefInstance : TemplateSpawnable = null
var currentStateIcon : Texture2D = null
var allSpawnedMonsters : Dictionary = {}
var currentSpawnedMonsters : Array = []
@onready var menuZone : Control = $Camera2D/CanvasLayer/PlayerUI.menuZone
@onready var enemy : CharacterBody2D = $"../Enemy"
@onready var playableArea : Area2D = $"../PlayableArea"
@onready var cursorState : Node2D = $CursorState

var isInPlayableArea : bool = false

func _ready():
	currentBloodAmount = STARTING_BLOOD_AMOUNT
	currentBloodGen = BASE_BLOOD_GEN
	
	playableArea.mouse_entered.connect(entered_playable_area)
	playableArea.mouse_exited.connect(exited_playable_area)

func _process(delta):
	handle_menu_inputs()
	handle_spawn()
	handle_cursor_state()
	

func add_monster(monster : TemplateSpawnable):
	currentSpawnedMonsters.append(monster)
	if !allSpawnedMonsters.has(monster.monsterName):
		allSpawnedMonsters[monster.monsterName] = 0
	allSpawnedMonsters[monster.monsterName] += 1

func remove_monster(monster : TemplateSpawnable):
	currentSpawnedMonsters.erase(monster)

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
	spawnable.signal_death.connect(monster_death)
	add_monster(spawnable)
	if enemy != null:
		enemy.add_foe(spawnable)

func monster_death(monster):
	remove_monster(monster)
	
func is_in_menu():
	return menuZone.get_rect().has_point(get_local_mouse_position())
	

func _on_player_ui_button_changed(currentButton):
	if currentButton == null:
		currentSpawnableScene = null
		currentStateIcon = null
		cursorState.set_cursor_state("", null)
		return
	
	if currentRefInstance != null:
		currentRefInstance.queue_free()
		currentRefInstance = null
	
	currentSpawnableScene = currentButton.spawnableScene
	currentRefInstance = currentSpawnableScene.instantiate()
	currentStateIcon = currentRefInstance.monsterIcon
	cursorState.set_cursor_state("", currentStateIcon)
	
