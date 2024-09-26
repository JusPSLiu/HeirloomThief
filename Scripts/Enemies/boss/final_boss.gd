extends StaticBody2D


@export var healthBar : TextureRect
@export var healthBar2 : ColorRect
@export var soundGetHit : AudioStreamPlayer2D
@export var bossAnimator : AnimationPlayer

@export var head : AnimatedSprite2D
@export var mask : AnimatedSprite2D

const fireball = preload("res://Scenes/Enemies/projectile.tscn")

var current_health = 64
var home_area = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = 64

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
	current_health -= damage_val
	healthBar.scale.y = max(0, current_health)
	healthBar2.scale.y = healthBar.scale.y
	if (current_health <= 0):
		die()
	elif (soundGetHit):
		soundGetHit.play()

func shoot_fireball():
	var fiery = fireball.instantiate()
	fiery.position = position + Vector2(0, 12)
	fiery.movement_direction = Vector2(cos(rotation+PI), sin(rotation))
	fiery.speed = 200
	add_sibling(fiery)

func update_sprites():
	if (current_health > 32):
		pass

func die():
	pass
	# bossAnimator.play("die")
