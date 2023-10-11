extends Control

@onready var menuZone : Control = $MenuZone
@export var buttonGroup : ButtonGroup 

signal button_changed(currentButton : Button)

func _ready():
	for i in buttonGroup.get_buttons():
		i.pressed.connect(on_button_changed)

func on_button_changed():
	button_changed.emit(buttonGroup.get_pressed_button()) 
