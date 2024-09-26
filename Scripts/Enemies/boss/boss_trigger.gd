extends Area2D

@export var animator : AnimationPlayer
@export var musicPlayer : AudioStreamPlayer
var activated = false

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		if (animator && !activated):
			animator.play("start_up")
			activated = true
			musicPlayer.set_stream(preload("res://Sounds/Music/boss_music.ogg"))
			musicPlayer.play()
