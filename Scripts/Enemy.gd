class_name Fabio
extends CharacterBody2D

const FREE_EXP_RATE = 12
var freeXpStack = 0

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
@export var maxcooldown: float = 0.75

@onready var currentcooldown: float = 0
@onready var killcount: int = 0
@onready var currAtks: int = 0
@onready var anim: Node = get_node("Sprite")
@onready var cooldown: Node = get_node("Atk_cooldown")
@onready var lvlanim: Node = get_node("LvlUp")
@onready var lvlsnd: Node = get_node("LvlUpSnd")
@onready var hitanim: Node = get_node("Hit")
@onready var atk1l: Node = get_node("AttackArea/Attack1CollisionR")
@onready var atk1r: Node = get_node("AttackArea/Attack1CollisionL")
@onready var atk2l: Node = get_node("AttackArea/Attack2CollisionR")
@onready var atk2r: Node = get_node("AttackArea/Attack2CollisionL")

@onready var atkL: Node = atk1l
@onready var atkR: Node = atk1r
@onready var atk: String = "Attack"
@onready var is_dead: bool = false

@onready var list: Array = []

signal exp_gained(current, min, max, level)
signal hp_changed(current, max)

func add_foe(foe):
	list.append(foe)

func remove_foe(foe):
	receive_exp(foe.expReward)
	list.erase(foe)
	killcount += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#setLevel(2)
	atk1l.set_disabled(true)
	atk1r.set_disabled(true)
	atk2l.set_disabled(true)
	atk2r.set_disabled(true)
	hp_changed.emit(hp, maxhp)
	exp_gained.emit(experience, 0 if level == 1 else levelup[level - 2] ,levelup[level - 1], level)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		pass
	
	if hp <= 0 && !is_dying:
		$Death.start()
		$Atk_cooldown.stop()
		setAnimState("Die")
		is_attacking = false
		is_dying = true
		$DeathSnd.play()
	
	if is_dying:
		is_dead = true
	if abs(velocity.x) < 1 && abs(velocity.y) < 1 && !is_attacking:
		setAnimState("Idle")
	elif !is_attacking:
		setAnimState("Run")
	
	if state != "Attack" && state != "Attack2":
		is_facing_left = velocity.x > 0 && !(velocity.x < 0)
	
	if currentcooldown > 0.:
		currentcooldown -= delta
	# AI STUFF
	velocity += processAI(list) * delta
	
	while velocity.length() > 100:
		velocity.x *= 0.99
		velocity.y *= 0.99
	velocity.x *= 0.97
	velocity.y *= 0.97
	
	if !hitanim.is_emitting():
		anim.modulate.a = 1
	
	if freeXpStack >= 1:
		receive_exp(floor(freeXpStack))
		freeXpStack -= floor(freeXpStack)
	freeXpStack += FREE_EXP_RATE * level * delta
	move_and_slide()
	

func processAI(objs):
	var vec: Vector2 = Vector2(0,0)
	var skel = false
	var weight: int = 0
	if hp <= 0:
		return vec
	for obj in objs:
		if !obj || !obj.isAlive:
			continue
		if position.distance_to(obj.position) < 25:
			if obj.priority == 10:
				vec += position.direction_to(obj.position) * 30
				if currentcooldown <= 0:
					attack()
					currentcooldown = maxcooldown
			weight = obj.priority * position.distance_to(obj.position) * ((maxhp + 1) / hp) * 1.25
			vec = weight * -position.direction_to(obj.position)
			if currentcooldown <= 0:
				attack()
				currentcooldown = maxcooldown
		else:
			if obj.priority == 10:
				skel = true
				vec = position.direction_to(obj.position) * 10
				if currentcooldown <= 0:
					attack()
					currentcooldown = maxcooldown
				break
			weight = abs(obj.priority) * position.distance_to(obj.position)
			vec += weight * position.direction_to(obj.position)
			
	
	if vec.length() < 5 && objs.size() > 1 && !skel:
		vec.y *= 3
	
	if velocity.length() < 95 && objs.size() > 1 && !skel:
		vec.y += 10
		vec.x += 5
		
	return vec.normalized() * 2000
	

func attack():
	is_attacking = true
	$AtkSnd.play()
	
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
	$HitSnd.play()
	if hitanim.is_emitting():
		pass
	hp -= dmg
	hitanim.restart()
	anim.modulate.a = 0.5
	
	hp_changed.emit(hp, maxhp)
	

func receive_exp(x):
	experience += x
	while experience > levelup[level - 1] && level <= 8:
		setLevel(level + 1)
	
	exp_gained.emit(experience, 0 if level == 1 else levelup[level - 2] ,levelup[level - 1], level)
	

func setLevel(lvl):
	level = lvl
	lvlanim.restart()
	lvlsnd.play()
	stop_attack()
	
	if level > 2:
		damage = 7
	
	if level > 3:
		atk = "Attack2"
		atkL = atk2l
		atkR = atk2r
		damage = 14
		
	if level > 4:
		cooldown.wait_time = 1
	
	if level > 5:
		damage = 21
		
	if level > 7:
		maxAtks = 2
	
	maxhp += 10
	hp += 10 * level + 5
	
	if hp > maxhp:
		hp = maxhp
	
	hp_changed.emit(hp, maxhp)
	

func _on_atk_cooldown_timeout():
	currAtks = maxAtks
	if !list.is_empty():
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
	is_dying = false
	

func _on_attack_area_body_entered(body):
	if typeof(body) == typeof(TemplateSpawnable):
		body.receive_damage(damage)
	

func _on_death_timeout():
	$"..".win_screen()
	queue_free()
	
func _on_sprite_animation_finished():
	pass



func _on_death_snd_finished():
	$DeathSnd.stop()
