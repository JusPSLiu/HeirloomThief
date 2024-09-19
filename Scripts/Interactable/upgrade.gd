extends Area2D


@export var id : int = 0

@onready var is_health_upgrade = self.is_in_group("health_upgrade")

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		if (is_health_upgrade):
			body.get_health_upgrade(id)
		else:
			body.get_gem_upgrade(id)
		queue_free()
