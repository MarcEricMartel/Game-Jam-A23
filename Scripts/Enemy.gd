extends CharacterBody2D

@onready var levelup = [300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000]

@onready var is_facing_left: bool = false
@onready var is_attacking: bool = false
@onready var is_dying: bool = false

@export var level: int = 7
@export var hp: int = 100
@export var maxhp: int = 100
@export var maxvel: float = 2
@export var experience: int = 0
@export var state: String = "Idle"
@export var damage: int = 5
@export var maxAtks: int = 1

@onready var currAtks: int = 0
@onready var anim: Node = get_node("Sprite")
@onready var cooldown: Node = get_node("Atk_cooldown")
@onready var lvlanim: Node = get_node("LvlUp")
@onready var lvlsnd: Node = get_node("LvlUpSnd")
@onready var hitanim: Node = get_node("Hit")
@onready var atk1l: Node = get_node("AttackArea/Attack1CollisionL")
@onready var atk1r: Node = get_node("AttackArea/Attack1CollisionR")
@onready var atk2l: Node = get_node("AttackArea/Attack2CollisionL")
@onready var atk2r: Node = get_node("AttackArea/Attack2CollisionR")

@onready var list: Array = []

func add_foe(foe):
	list.append(foe)

func remove_foe(foe):
	list.erase(foe)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(velocity.x) < 0.1 && abs(velocity.y) < 0.1 && !is_attacking:
		setAnimState("Idle")
	elif !is_attacking:
		setAnimState("Run")
	
	if state != "Attack" && state != "Attack2":
		is_facing_left = velocity.x >= 0

	# AI STUFF
	#velocity += processAI(list,delta)
	
	velocity.x += delta
	velocity.y += delta
	
	if !hitanim.is_emitting():
		anim.modulate.a = 1
	
	move_and_slide()
	

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
			atk2r.set_disabled(false)
		else:
			atk2l.set_disabled(false)
	else:
		setAnimState("Attack")
		if is_facing_left:
			atk1r.set_disabled(false)
		else:
			atk1l.set_disabled(false)
	

func stop_attack():
	is_attacking = false
	atk1l.set_disabled(true)
	atk1r.set_disabled(true)
	atk2l.set_disabled(true)
	atk2r.set_disabled(true)
	

func setAnimState(newstate):
	anim.animation = newstate
	anim.flip_h = !is_facing_left
	
	state = newstate
	

func receive_damage(dmg):
	if hitanim.is_emitting():
		pass
	hp -= dmg
	hitanim.restart()
	anim.modulate.a = 0.5
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
		cooldown.wait_time = 1
		
	if level > 5:
		damage = 12
		
	if level > 7:
		maxAtks = 2
	
	maxhp += 5
	hp = maxhp
	

func _on_atk_cooldown_timeout():
	currAtks = maxAtks
	attack()
	

func _on_sprite_animation_looped():
	if is_attacking:
		currAtks -= 1
		stop_attack()
		if currAtks > 0:
			is_facing_left = !is_facing_left
			attack()
	is_dying = false
	

func _on_attack_area_body_entered(body):
	if typeof(body) == typeof(TemplateSpawnable):
		body.receive_damage(damage)
