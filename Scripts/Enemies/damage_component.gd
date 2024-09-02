extends Area2D


@export var damageInHalfHearts = 1
@export var knockPlayerAwayFromCenter : bool = false
@export var knockPlayerInCustomVector : Vector2 = Vector2(0, 0)

var playerInArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (playerInArea):
		var knockVector = knockPlayerInCustomVector
		if (knockPlayerAwayFromCenter):
			knockVector += (playerInArea.position-position).normalized()*2
		if (playerInArea.get_hit(damageInHalfHearts, knockVector)):
			# only returns true when dies
			# set to null so dont keep trying to kill already dead player
			playerInArea = null


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerInArea = body


func _on_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		playerInArea = null
