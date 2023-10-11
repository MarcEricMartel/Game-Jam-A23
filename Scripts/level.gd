extends Node2D

var length: int = 0
var time: int = 0
var countdown: float = 0
@onready var player := $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	length = $Music.stream.get_length()
	player.set_time(str(length))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	countdown += delta
	if countdown > 1:
		countdown -= 1
		time = $Music.get_playback_position()
		player.set_time(str(length - time - 1))

func win_screen():
	var enemy = $Enemy
	var end = load("res://Scenes/ending.tscn").instantiate()
	end.remainingTime = str(length - time - 1)
	end.totalBlud = player.totalBludGenerated
	end.army = player.allSpawnedMonsters
	end.killcount = enemy.killcount
	end.level = enemy.level
	end.exp = enemy.experience
	end.message = "The holy knight Fabio is defeated, Evil has won and your magic staff is safe."
	end.maxBludGen = player.maxBludGen
	self.queue_free()
	get_tree().root.add_child(end)
	
func lose_screen():
	var enemy = $Enemy
	var end = load("res://Scenes/ending.tscn").instantiate()
	end.totalBlud = player.totalBludGenerated
	end.army = player.allSpawnedMonsters
	end.killcount = enemy.killcount
	end.level = enemy.level
	end.exp = enemy.experience
	end.is_win = false
	end.message = "The holy knight Fabio destroyed you army of evil and left with your magic staff..."
	end.maxBludGen = player.maxBludGen
	self.queue_free()
	get_tree().root.add_child(end)

func _on_music_finished():
	lose_screen()
