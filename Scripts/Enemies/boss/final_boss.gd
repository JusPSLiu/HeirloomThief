extends AnimatableBody2D


@export var healthBar : TextureRect
@export var healthBar2 : ColorRect
@export var soundGetHit : AudioStreamPlayer2D

var current_health = 64
var home_area = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = 64

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

func die():
	pass
