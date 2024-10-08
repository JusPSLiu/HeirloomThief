extends StaticBody2D


@export var healthBar : TextureRect
@export var healthBar2 : ColorRect
@export var soundGetHit : AudioStreamPlayer2D
@export var bossAnimator : AnimationPlayer
@export var bossAnimatorController : AnimationPlayer
@export var musicPlayer : AudioStreamPlayer

@export var head : AnimatedSprite2D
@export var mask : AnimatedSprite2D
@export var motley_bossbar_cover : TextureRect
@export var motley_bossbar_outline : ColorRect

@onready var rootNode = get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var firebreath_spawner = $firebreath_spawner
@onready var flashy_animator = $flashy_animator

const MAX_HEALTH = 128
const fireball = preload("res://Scenes/Enemies/projectile.tscn")
const lavawave = preload("res://Scenes/Enemies/boss_attacks/lavawave.tscn")
const lavawave2 = preload("res://Scenes/Enemies/boss_attacks/lavawave_right.tscn")


var current_health = MAX_HEALTH
var home_area = -1
var vulnerable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = MAX_HEALTH
	head.material.set_shader_parameter("outline_visible", false)
	soundGetHit.set_stream(load("res://Sounds/enemy/bossfight/bossdamage.wav"))

# runs when player first enters, or when dies
func enable():
	respawn()

func disable():
	pass

func respawn():
	current_health = MAX_HEALTH
	healthBar2.scale.y = MAX_HEALTH-1
	healthBar.scale.y = MAX_HEALTH
	update_sprites()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func realign_animator():
	var currPos = (musicPlayer.get_playback_position()-1.385)
	if (currPos < 0): currPos += 92.3075
	bossAnimator.seek(currPos)

func damage(damage_val):
	if (vulnerable):
		current_health -= damage_val
		healthBar.scale.y = max(0, current_health)
		healthBar2.scale.y = healthBar.scale.y
		if (current_health <= 0):
			die()
		elif (soundGetHit):
			soundGetHit.play()
		# i wish i couldve called this elsewhere...
		update_sprites()
		flashy_animator.stop()
		flashy_animator.play("hit")

func look_vulnerable(able=true):
	vulnerable = able
	head.material.set_shader_parameter("outline_visible", vulnerable)
	motley_bossbar_cover.set_visible(!able)
	motley_bossbar_outline.color = Color(able, able, able, 1)

func shoot_fireball():
	var fiery = fireball.instantiate()
	fiery.global_position = firebreath_spawner.global_position
	fiery.movement_direction = Vector2(cos(global_rotation+PI), sin(global_rotation)*-1)
	fiery.speed = 200*4
	fiery.scale = Vector2(4, 4)
	fiery.z_index = 1
	rootNode.add_child.call_deferred(fiery)

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
	else:
		head.play("returned")
		mask.play("returned")


func flashy_boss(whitening_value : float = 0):
	head.material.set_shader_parameter("whiten", whitening_value)

func die():
	if (bossAnimatorController.is_playing()):
		bossAnimatorController.stop()
		bossAnimator.play("die")
		SaveManager.save_when_beat_game()
