extends Control

@onready var healthBar : ProgressBar = $HealthBar
@onready var hpLabel : Label = $HealthBar/HP

func setHP(currentHp, maxHp):
	healthBar.min_value = 0
	healthBar.max_value = maxHp	
	healthBar.value = currentHp
	hpLabel.text = str(currentHp) + "/" + str(maxHp)
