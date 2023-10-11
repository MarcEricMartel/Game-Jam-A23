class_name PlayerUI
extends Control

@export var buttonGroup : ButtonGroup 
@onready var bludGen : Label = $UIRoot/ControlPanel/StatPanel/Blud/HBoxContainer/VBoxContainer/BludGenContainer/BludGen
@onready var bludTotal : Label = $UIRoot/ControlPanel/StatPanel/Blud/HBoxContainer/VBoxContainer/BludTotalContainer/BludTotal
@onready var enemyXPBar : ProgressBar = $UIRoot/ControlPanel/StatPanel/Other/MarginContainer/GridContainer/EnemyXPBar
@onready var enemyXPLabel : Label = $UIRoot/ControlPanel/StatPanel/Other/MarginContainer/GridContainer/EnemyXPBar/EnemyXPLabel
@onready var enemyHPBar : ProgressBar = $UIRoot/ControlPanel/StatPanel/Other/MarginContainer/GridContainer/EnemyHPBar
@onready var enemyHPLabel : Label = $UIRoot/ControlPanel/StatPanel/Other/MarginContainer/GridContainer/EnemyHPBar/EnemyHPLabel


signal button_changed(currentButton : Button)

func _ready():
	for i in buttonGroup.get_buttons():
		i.pressed.connect(on_button_changed)

func on_button_changed():
	button_changed.emit(buttonGroup.get_pressed_button()) 
	
func set_blud(gen, total):
	bludGen.text = str(floor(gen))
	bludTotal.text = str(floor(total))
	
func set_blud_gen(gen):
	bludGen.text = str(floor(gen))

func set_blud_total(total):
	bludTotal.text = str(floor(total))
	
func set_hp(current, total):
	enemyHPBar.max_value = total
	enemyHPBar.value = current
	enemyHPLabel.text = str(current) + "/" + str(total) + " HP"

func set_xp(current, min, max, level):
	enemyXPBar.max_value = max
	enemyXPBar.min_value = min
	enemyXPBar.value = current
	enemyXPLabel.text = "Lvl " + str(level) + " (" + str(current) + "/" + str(max) + "xp)" 
