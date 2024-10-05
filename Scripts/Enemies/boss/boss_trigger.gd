extends Area2D

@export var animator : AnimationPlayer
@export var musicPlayer : AudioStreamPlayer
var activated = false

var preloadedBossLoop = preload("res://Sounds/Music/boss_loopy.ogg")

func _ready():
	musicPlayer.set_stream(load("res://Sounds/Music/boss_starter.wav"))

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		if (animator && !activated):
			animator.play("start_up")
			activated = true
			musicPlayer.play()
