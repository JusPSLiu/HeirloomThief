extends Area2D


@export var health_to_heal = 1


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.get_healed(health_to_heal)
		queue_free()
