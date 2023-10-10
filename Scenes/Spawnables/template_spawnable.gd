class_name TemplateSpawnable
extends CharacterBody2D

@export var maxHp : int = 0
@export var attackSpeed : float = 0
@export var speed : float = 0
@export var damage : int = 0
@export var priority : int = 0

@onready var ai : Node = $AI
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D

var isAlive : bool = true
var direction : Vector2 = Vector2.ZERO
var enemy : CharacterBody2D = null

var currentHp : int = 0
var cooldown : float = 0

func _ready():
	enemy = get_node("../Enemy")
	currentHp = maxHp

func _process(delta):
	if !isAlive:
		return
		
	if enemy != null:
		direction = ai.getDirection(position, enemy.position)
	else:
		direction = Vector2.ZERO
	
	velocity = direction * speed * delta
	move_and_slide()

func attack(target):
	animatedSprite.play("attack")
	animatedSprite.connect("animation_finished", endAttack(target))

func endAttack(target):
	target.receive_damage(damage)
	animatedSprite.play("default")

func receive_damage(dmg):
	if !isAlive:
		return
	
	if currentHp - dmg <= 0:
		currentHp = 0
		die()
	else :
		currentHp -= dmg

func die():
	isAlive = false
	animatedSprite.play("death")
	animatedSprite.connect("animation_finished", self.fadeOut())
	
func fadeOut():
	var tween = Tween.new()
	add_child(tween)
	tween.tween_property(animatedSprite, "modulate", Color(0,0,0,0), 1)
	tween.tween_callback(clean())

func clean():
	queue_free()
