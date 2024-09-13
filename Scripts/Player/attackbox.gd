extends Area2D

@export var damage_value : int = 1

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy")):
		body.damage(damage_value)
