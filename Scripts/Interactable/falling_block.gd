extends Node2D

@export var soundPlayer : AudioStreamPlayer2D
@export var fallingDistance : int = 2

@onready var startPos : Vector2 = position

var enabled : bool = false
var falling : bool = false
var currFallSpeed : float = 0

func _ready() -> void:
	fallingDistance *= 8

func _process(delta: float) -> void:
	if (falling):
		currFallSpeed += delta*10
		position.y += currFallSpeed
		if (position.y > startPos.y+fallingDistance):
			position.y = startPos.y+fallingDistance
			falling = false

func activate():
	if (!enabled):
		enabled = true
		falling = true

func skipToActivated():
	if (!enabled):
		enabled = true
		falling = false
		position.y = startPos.y + fallingDistance


func reset():
	position = startPos
