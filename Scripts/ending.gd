extends Control

var killcount: int = 0
var level: int = 1
var exp: int = 0
var message: String = ""
var is_win: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_win:
		$Enemy.hide()
	$Message.text = message
	$AmtKill.text = str(killcount)
	$AmtLvl.text = str(level)
	$AmtExp.text = str(exp)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()
