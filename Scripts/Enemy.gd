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

@onready var atkL: Node = atk1l
@onready var atkR: Node = atk1r
@onready var atk: String = "Attack"

@onready var list: Array = []

func add_foe(foe):
	list.append(foe)

func remove_foe(foe):
	list.erase(foe)

# Called when the node enters the scene tree for the first time.
func _ready():
	atk1l.set_disabled(true)
	atk1r.set_disabled(true)
	atk2l.set_disabled(true)
	atk2r.set_disabled(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(velocity.x) < 0.2 && abs(velocity.y) < 0.2 && !is_attacking:
		setAnimState("Idle")
	elif !is_attacking:
		setAnimState("Run")
	
	if state != "Attack" && state != "Attack2":
		is_facing_left = velocity.x > 0 && !(velocity.x < 0)

	# AI STUFF
	velocity += processAI(list) * delta
	#var x = 0
	#var y = 0
	
	#if Input.is_action_pressed("ui_left"):
	#	# Move as long as the key/button is pressed.
	#	x -= delta * 50
	#elif Input.is_action_pressed("ui_right"):
	#	# Move as long as the key/button is pressed.
	#	x += delta * 50
	#else:
	#	velocity.x *= 0.8
	#if Input.is_action_pressed("ui_up"):
		# Move as long as the key/button is pressed.
	#	y -= delta * 50
	#elif Input.is_action_pressed("ui_down"):
		# Move as long as the key/button is pressed.
	#	y += delta * 50
	#else:
	#	velocity.y *= 0.8
	while velocity.length() > 100:
		velocity.x *= 0.99
		velocity.y *= 0.99
	velocity.x *= 0.99
	velocity.y *= 0.99
	#velocity.x += x
	#velocity.y += y
	
	if !hitanim.is_emitting():
		anim.modulate.a = 1
	
	move_and_slide()
	

func processAI(objs):
	var vec: Vector2 = Vector2(0,0)
	var weight: int = 0
	for obj in objs:
		if !obj || !obj.isAlive:
			continue
		if position.distance_to(obj.position) > 10:
			weight = abs(obj.priority) * position.distance_to(obj.position)
			vec += weight * position.direction_to(obj.position)
		else:
			weight = obj.priority * position.distance_to(obj.position) * ((maxhp + 1) / hp)
			vec += weight * -position.direction_to(obj.position)
	
	if vec.length() < 5 && objs.size() > 1:
		vec.y *= 3
	
	if velocity.length() < 95 && objs.size() > 1:
		vec.y += 10
		vec.x -= vec.x * .2
		
	return vec.normalized() * 100
	

func attack():
	is_attacking = true
	
	setAnimState(atk)
	if is_facing_left:
		atkL.set_disabled(false)
	else:
		atkR.set_disabled(false)
	

func stop_attack():
	is_attacking = false
	atkL.set_disabled(true)
	atkR.set_disabled(true)
	

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
	
	if level > 3:
		atk = "Attack2"
		atkL = atk2l
		atkR = atk2r
		damage = 7
		
	if level > 4:
		cooldown.wait_time = 1
	
	if level > 5:
		damage = 12
		
	if level > 7:
		maxAtks = 2
	
	maxhp += 5
	hp += maxhp / 2
	
	if hp > maxhp:
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
		else:
			currAtks = maxAtks
	if (is_dying):
		queue_free()
	else:
		is_dying = false
	

func _on_attack_area_body_entered(body):
	if typeof(body) == typeof(TemplateSpawnable):
		body.receive_damage(damage)
