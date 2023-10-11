class_name SpawnableButton
extends Button

@export var spawnableScene : PackedScene = null

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
	
func _on_mouse_entered():
	animationPlayer.play("AnimateTextureRect")


func _on_mouse_exited():
	animationPlayer.stop()
