extends Control

var killcount: int = 0
var level: int = 1
var exp: int = 0
var message: String = ""
var is_win: bool = true
var army: Dictionary = {}
var totalBlud: float = 0
var remainingTime: String = "0"
var maxBludGen = 0

func _ready():
	if is_win:
		$WinningEnemy.hide()
		$DeadEnemy.show()
		$DeadEnemy.play("default")
		$Time.show()
		$Time/HBoxContainer/TimeLabel.text = remainingTime + " Seconds Remained"
	if !is_win:
		$Time.hide()
		$WinningEnemy.show()
		$DeadEnemy.hide()
		$WinningEnemy.play("default")	
	$Message.text = message
	$AmtKill.text = str(killcount)
	$AmtLvl.text = str(level)
	$AmtExp.text = str(exp)
	$TotalArmyComp/Separation/ArmyTotals/Bats/Control/AnimatedSprite2D.play("default")
	$TotalArmyComp/Separation/ArmyTotals/Wolves/Control/AnimatedSprite2D.play("default")
	$TotalArmyComp/Separation/ArmyTotals/Necromancers/Control/AnimatedSprite2D.play("default")
	$"TotalArmyComp/Separation/ArmyTotals/Pit Fiends/Control/AnimatedSprite2D".play("default")
	$TotalArmyComp/Separation/ArmyTotals/Bats/AmtBat.text = "0" if !army.has("Bat") else str(army["Bat"])
	$TotalArmyComp/Separation/ArmyTotals/Wolves/AmtWolves.text = "0" if !army.has("Wolf") else str(army["Wolf"])
	$TotalArmyComp/Separation/ArmyTotals/Necromancers/AmtNecromancer.text = "0" if !army.has("Necromancer") else str(army["Necromancer"])
	$"TotalArmyComp/Separation/ArmyTotals/Pit Fiends/AmtPitFiend".text = "0" if !army.has("Pit Fiend") else str(army["Pit Fiend"])
	$TotalArmyComp/Separation/TotalBludGen/AmtBlud.text = str(floor(totalBlud))
	$TotalArmyComp/Separation/MaxBludGen/MaxBludGen.text = str(maxBludGen) + "/s"
	
func _on_quit_pressed():
	get_tree().quit()
