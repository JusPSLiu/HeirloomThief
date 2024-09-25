extends Area2D

@export var animator : AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		if (animator):
			animator.play("start_up")
