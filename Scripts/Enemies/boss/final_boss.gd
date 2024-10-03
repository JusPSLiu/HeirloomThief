extends StaticBody2D


@export var healthBar : TextureRect
@export var healthBar2 : ColorRect
@export var soundGetHit : AudioStreamPlayer2D
@export var bossAnimator : AnimationPlayer

@export var head : AnimatedSprite2D
@export var mask : AnimatedSprite2D

@onready var rootNode = get_parent().get_parent().get_parent().get_parent().get_parent()

const fireball = preload("res://Scenes/Enemies/projectile.tscn")
const lavawave = preload("res://Scenes/Enemies/boss_attacks/lavawave.tscn")
const lavawave2 = preload("res://Scenes/Enemies/boss_attacks/lavawave_right.tscn")

var current_health = 64
var home_area = -1
var vulnerable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = 64
	head.material.set_shader_parameter("outline_visible", false)

# runs when player first enters, or when dies
func enable():
	respawn()

func disable():
	pass

func respawn():
	current_health = 64
	healthBar2.scale.y = 63
	healthBar.scale.y = 64

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(damage_val):
	if (vulnerable):
		current_health -= damage_val
		healthBar.scale.y = max(0, current_health)
		healthBar2.scale.y = healthBar.scale.y
		if (current_health <= 0):
			die()
		elif (soundGetHit):
			soundGetHit.play()

func look_vulnerable(able=true):
	vulnerable = able
	head.material.set_shader_parameter("outline_visible", vulnerable)

func shoot_fireball():
	var fiery = fireball.instantiate()
	fiery.position = position + Vector2(0, 12)
	fiery.movement_direction = Vector2(cos(rotation+PI), sin(rotation))
	fiery.speed = 200
	add_sibling(fiery)

func lava_wave():
	var fiery = lavawave.instantiate()
	var fiery2 = lavawave2.instantiate()
	rootNode.add_child.call_deferred(fiery)
	rootNode.add_child.call_deferred(fiery2)
	$boom.play()

func update_sprites():
	if (current_health <= 32):
		head.play("breaking")
		mask.play("breaking")


func die():
	pass
	# bossAnimator.play("die")
