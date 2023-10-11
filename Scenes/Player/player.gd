class_name Player
extends Node2D

const BASE_Blud_GEN = 10
const STARTING_Blud_AMOUNT = 100

var currentBludAmount : float = 0
var currentBludGen : float = 0
var currentSpawnableScene : PackedScene = null
var currentRefInstance : TemplateSpawnable = null
var currentCost : float = 0
var currentStateIcon : Texture2D = null
var allSpawnedMonsters : Dictionary = {}
var currentSpawnedMonsters : Array = []
@onready var menuZone : Control = $Camera2D/CanvasLayer/PlayerUI/MenuZone
@onready var playerUI : Control = $Camera2D/CanvasLayer/PlayerUI
@onready var enemy : Fabio = $"../Enemy"
@onready var playableArea : Area2D = $"../PlayableArea"
@onready var cursorState : Node2D = $CursorState

var isInPlayableArea : bool = false

func _ready():
	currentBludAmount = STARTING_Blud_AMOUNT
	currentBludGen = BASE_Blud_GEN
	
	enemy.exp_gained.connect(playerUI.set_xp)
	enemy.hp_changed.connect(playerUI.set_hp)
	
	playerUI.set_blud(currentBludGen, currentBludAmount)
	
	playableArea.mouse_entered.connect(entered_playable_area)
	playableArea.mouse_exited.connect(exited_playable_area)

func _process(delta):
	handle_menu_inputs()
	handle_spawn()
	handle_cursor_state()
	currentBludAmount += currentBludGen * delta
	playerUI.set_blud_total(currentBludAmount)

func set_time(text : String):
	playerUI.set_time(text)

func add_monster(monster : TemplateSpawnable):
	currentSpawnedMonsters.append(monster)
	
	currentBludGen += monster.BludGen
	playerUI.set_blud_gen(currentBludGen)
	
	if !allSpawnedMonsters.has(monster.monsterName):
		allSpawnedMonsters[monster.monsterName] = 0
	allSpawnedMonsters[monster.monsterName] += 1
	
	playerUI.set_army_count(currentSpawnedMonsters.size())

func remove_monster(monster : TemplateSpawnable):
	currentSpawnedMonsters.erase(monster)
	
	currentBludGen -= monster.BludGen
	playerUI.set_blud_gen(currentBludGen)
	playerUI.set_army_count(currentSpawnedMonsters.size())

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
	if cursorState.infoLabel.text != "out of bounds":
		if currentBludAmount < currentCost:
			cursorState.set_cursor_state_info("not enough blud")
		else:
			cursorState.set_cursor_state_info("")
	cursorState.visible = !is_in_menu()
	cursorState.global_position = get_global_mouse_position()

func spawn_current():
	if !isInPlayableArea || is_in_menu() || currentSpawnableScene == null:
		return
	
	if currentBludAmount < currentCost:
		if cursorState.infoLabel.text == "":
			cursorState.set_cursor_state_info("not enough blud")
		return
	
	currentBludAmount -= currentCost
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
	currentCost = currentRefInstance.cost
	cursorState.set_cursor_state("", currentStateIcon)
	
