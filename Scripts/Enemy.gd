extends CharacterBody2D

@onready var levelup = [300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000]

@onready var is_facing_left: bool = false
@onready var is_attacking: bool = false
@onready var is_dying: bool = false

@export var level: int = 1
@export var hp: int = 100
@export var maxhp: int = 100
@export var maxvel: float = 2
@export var experience: int = 0
@export var state: String = "Idle"

@onready var anim: Node = get_node("Sprite")
@onready var cooldown: Node = get_node("Atk_cooldown")
@onready var lvlanim: Node = get_node("LvlUp")
@onready var lvlsnd: Node = get_node("LvlUpSnd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(velocity.x) < 0.1 && abs(velocity.y) < 0.1 && !is_attacking:
		setAnimState("Idle")
	elif !is_attacking:
		setAnimState("Run")
	
	is_facing_left = velocity.x >= 0

	# AI STUFF
	#velocity = processAI(objects,velocity,delta)
	
	velocity.x += delta
	velocity.y += delta
	
	if abs(velocity.x + velocity.y) > maxvel:
		velocity.x *= maxvel / velocity.x
		velocity.y *= maxvel / velocity.y
	
	position += velocity
	

func processAI(objs, delta):
	var vec: Vector2 = Vector2(0,0)
	for obj in objs:
		vec += obj.vecpos * obj.weight * (1 / (position - obj.vecpos)) * delta
	return vec.normalized()
	

func attack():
	is_attacking = true
	if (level > 1):
		setAnimState("Attack2")
		if is_facing_left:
			get_node("AttackArea/Attack2CollisionL").set_disabled(false)
		else:
			get_node("AttackArea/Attack2CollisionR").set_disabled(false)
	else:
		setAnimState("Attack")
		if is_facing_left:
			get_node("AttackArea/Attack1CollisionL").set_disabled(false)
		else:
			get_node("AttackArea/Attack1CollisionR").set_disabled(false)
	

func stop_attack():
	is_attacking = false
	get_node("AttackArea/Attack1CollisionL").set_disabled(true)
	get_node("AttackArea/Attack1CollisionR").set_disabled(true)
	get_node("AttackArea/Attack2CollisionL").set_disabled(true)
	get_node("AttackArea/Attack2CollisionR").set_disabled(true)
	

func setAnimState(newstate):
	anim.animation = newstate
	anim.flip_h = !is_facing_left
	
	state = newstate
	

func receive_damage(dmg):
	hp -= dmg
	if hp < 0:
		velocity = Vector2(0,0)
		setAnimState("Die")
		state = "Die"
		is_dying = true
	

func receive_exp(x):
	experience += x
	if experience > levelup[level - 1] && level <= 8:
		setLevel(level + 1)
	

func setLevel(lvl):
	level = lvl
	lvlanim.restart()
	lvlsnd.play()
	
	if level > 2:
		cooldown.wait_time = 0.5
	

func _on_atk_cooldown_timeout():
	attack()
	

func _on_sprite_animation_looped():
	if is_attacking:
		stop_attack()
	is_dying = false
	
