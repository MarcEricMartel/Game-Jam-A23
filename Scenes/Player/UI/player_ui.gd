extends Control

@export var buttonGroup : ButtonGroup 
@onready var bludGen : Label = $UIRoot/ControlPanel/StatPanel/Blud/HBoxContainer/VBoxContainer/BludGenContainer/BludGen
@onready var bludTotal : Label = $UIRoot/ControlPanel/StatPanel/Blud/HBoxContainer/VBoxContainer/BludTotalContainer/BludTotal

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
