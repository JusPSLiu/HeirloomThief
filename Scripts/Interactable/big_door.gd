extends Area2D

@export var nextLevel : int = 1

var playerBody = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Arrow.hide()

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerBody = body
		body.allow_doory(Vector2.ZERO)
		SaveManager.nextScene = nextLevel
		$Arrow.show()

func _on_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerBody = null
		body.exit_doory(Vector2.ZERO)
		$Arrow.hide()
