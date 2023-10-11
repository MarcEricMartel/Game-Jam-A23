class_name TemplateSpawnable
extends CharacterBody2D

const ATTACK_COOLDOWN : float = 100

@export var maxHp : int = 0
@export var attackSpeed : float = 0
@export var speed : float = 0
@export var damage : int = 0
@export var priority : int = 0
@export var expReward : int = 0
@export var bloodGen : int = 0
@export var cost : int = 0
@export var minSpawnRange : float = 0
@export var canAttack : bool = true
@export var monsterName : String = ""
@export var monsterIcon : Texture2D = null

@onready var ai : Node = $AI
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var attackArea : Area2D = $AttackArea
@onready var damageCollision : CollisionShape2D = $DamageArea/DamageCollision
@onready var bodyCollision : CollisionShape2D = $BodyCollision
@onready var spawnableUI : Control = $UIContainer/SpawnableUI

var isAlive : bool = true
var isFacingLeft : bool = false
var direction : Vector2 = Vector2.ZERO
var enemy : CharacterBody2D = null

var currentHp : int = 0
var cooldown : float = 0

signal signal_death(monster : TemplateSpawnable)

func _ready():
	enemy = get_node("../Enemy")
	currentHp = maxHp
	spawnableUI.setHP(currentHp, maxHp)
	spawnableUI.visible = true
	animatedSprite.play("default")

func _process(delta):
	if !isAlive:
		return
	
	if enemy != null:
		direction = ai.getDirection(global_position, enemy.global_position)
	else:
		direction = Vector2.ZERO
	
	if !isFacingLeft && direction.x < 0:
		isFacingLeft = true
		attackArea.scale = Vector2(-1,1)
		damageCollision.scale = Vector2(-1,1)
		animatedSprite.flip_h = isFacingLeft
	elif isFacingLeft && direction.x > 0:
		isFacingLeft = false
		attackArea.scale = Vector2(1,1)
		damageCollision.scale = Vector2(1,1)
		animatedSprite.flip_h = isFacingLeft
		
	velocity = direction * speed * delta
	move_and_slide()
	
	if cooldown > 0:
		if cooldown - attackSpeed * delta <= 0:
			cooldown = 0 
		else:
			cooldown -= attackSpeed * delta
	attemptAttack()

func attemptAttack():
	if !canAttack || !isAlive || cooldown > 0:
		return
	if attackArea.overlaps_body(enemy):
		attack()

func attack():
	cooldown = ATTACK_COOLDOWN
	animatedSprite.play("attack")
	damageCollision.disabled = false
	animatedSprite.connect("animation_finished", endAttack)

func endAttack():
	damageCollision.disabled = true
	animatedSprite.disconnect("animation_finished", endAttack)
	animatedSprite.play("default")

func receive_damage(dmg):
	if !isAlive:
		return
	if currentHp - dmg <= 0:
		currentHp = 0
		call_deferred("die")
	else :
		currentHp -= dmg
	spawnableUI.setHP(currentHp, maxHp)

func die():
	enemy.remove_foe(self)
	signal_death.emit(self)
	bodyCollision.disabled = true
	damageCollision.disabled = true
	spawnableUI.visible = false
	isAlive = false
	animatedSprite.stop()
	animatedSprite.play("death")
	if animatedSprite.is_connected("animation_finished", endAttack):
		animatedSprite.disconnect("animation_finished", endAttack)
	animatedSprite.connect("animation_finished", fadeOut)
	
func fadeOut():
	var tween = get_tree().create_tween()
	tween.tween_property(animatedSprite, "modulate", Color(0,0,0,0), 1)
	tween.tween_callback(clean)
	

func clean():
	queue_free()


func _on_damage_area_body_entered(body):
	if body == enemy:
		body.receive_damage(damage)
