extends Node2D

@export var soundPlayer : AudioStreamPlayer2D
@export var fallingDistance : int = 2

@export var startPos : Vector2

var enabled : bool = false
var falling : bool = false
var FALL_NOW : bool = false
var currFallSpeed : float = 0

func _ready() -> void:
	startPos = position
	fallingDistance *= 8

func _process(delta: float) -> void:
	if (falling):
		currFallSpeed += delta*10
		position.y += currFallSpeed
		if (position.y > startPos.y+fallingDistance):
			position.y = startPos.y+fallingDistance
			falling = false
		
		# if skip (yes godot is too glitchy for me to put it in skipToActivated)
		if (FALL_NOW):
			position.y = startPos.y+fallingDistance
			FALL_NOW = false
			falling = false

func activate():
	if (!enabled):
		enabled = true
		falling = true

func skipToActivated():
	if (!enabled):
		enabled = true
		falling = true
		FALL_NOW = true


func reset():
	position = startPos
