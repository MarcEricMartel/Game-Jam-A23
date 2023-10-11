class_name SpawnableButton
extends Button

@export var spawnableScene : PackedScene = null

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var label : Label = $Label

func _ready():
	if spawnableScene == null:
		return
		
	var temp : TemplateSpawnable = spawnableScene.instantiate()
	label.text = str(temp.monsterName) + " (" + str(temp.cost) + ")"
	temp.queue_free()

	
func _on_mouse_entered():
	animationPlayer.play("AnimateTextureRect")


func _on_mouse_exited():
	animationPlayer.stop()
