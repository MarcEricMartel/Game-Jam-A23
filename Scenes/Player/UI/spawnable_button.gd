class_name SpawnableButton
extends Button

@export var spawnableScene : PackedScene = null

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var label : Label = $Label
@onready var toolTip : Control = $ToolTip
@onready var toolTipLabel : Label = $ToolTip/ToolTipLabel

func _ready():
	if spawnableScene == null:
		return
		
	var temp : TemplateSpawnable = spawnableScene.instantiate()
	label.text = str(temp.monsterName) + " (" + str(temp.cost) + ")"
	generate_tooltip(temp)
	temp.queue_free()

	
func _on_mouse_entered():
	animationPlayer.play("AnimateTextureRect")
	toolTip.visible = true

func _on_mouse_exited():
	animationPlayer.stop()
	toolTip.visible = false	

func generate_tooltip(monster : TemplateSpawnable):
	var toolTipText = """-{monsterName}-
	HP: {hp}
	Mv. Spd: {spd}
	Dmg: {dmg}
	Atk Spd: {atkSpd}
	Cost: {cost}
	Blud Gen: {bludGen}/s
	"""
	
	toolTipLabel.text = toolTipText.format({"monsterName" : monster.monsterName, "hp" : monster.maxHp, "spd" : monster.speed, "dmg" : monster.damage, "atkSpd" : monster.attackSpeed, "cost" : monster.cost, "bludGen" : monster.BludGen})
