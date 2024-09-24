extends Area2D

@export var pairedDoor : Area2D
@export var enabled = true

var playerBody = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (enabled and pairedDoor.enabled): skipToActivated()
	$Arrow.hide()

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerBody = body
		if (enabled and pairedDoor.enabled):
			body.allow_doory(pairedDoor.global_position - Vector2(0, 30))
			$Arrow.show()

func _on_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerBody = null
		body.exit_doory(pairedDoor.global_position - Vector2(0, 30))
		$Arrow.hide()

func activate():
	$sprite.play("opening")
	if (!enabled):
		pairedDoor.activate()
		enabled = true
	if (playerBody):
		playerBody.allow_doory(pairedDoor.global_position - Vector2(0, 30))
		$Arrow.show()

func skipToActivated():
	if (!enabled):
		enabled = true
		$sprite.play("open")
		$sprite.set_autoplay("open")
		pairedDoor.skipToActivated()
