extends Node2D

var length: int = 0
var time: int = 0
var countdown: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	length = $Music.stream.get_length()
	$Time.text = str(length)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	countdown += delta
	if countdown > 1:
		countdown -= 1
		time = $Music.get_playback_position()
		$Time.text = str(length - time - 1)
	pass

func win_screen():
	var enemy = $Enemy
	var end = load("res://Scenes/ending.tscn").instantiate()
	end.killcount = enemy.killcount
	end.level = enemy.level
	end.exp = enemy.experience
	end.message = "Fabio le chevalier est mort, bravo."
	self.queue_free()
	get_tree().root.add_child(end)
	
func lose_screen():
	var enemy = $Enemy
	var end = load("res://Scenes/ending.tscn").instantiate()
	end.killcount = enemy.killcount
	end.level = enemy.level
	end.exp = enemy.experience
	end.is_win = false
	end.message = "Fabio le chevalier et futur roi t'a torché... royalement. (HA!)"
	self.queue_free()
	get_tree().root.add_child(end)

func _on_music_finished():
	lose_screen()
