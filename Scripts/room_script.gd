extends Area2D

@export var room_number : int = 0

var my_enemies : Array[CharacterBody2D]


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy") and body not in my_enemies):
		if (body.home_area < 0):
			body.home_area = room_number
			my_enemies.append(body)
			if (SaveManager.current_room != room_number):
				body.disable()
		elif (body.home_area != room_number):
			body.disable()
	elif (body.is_in_group("Player")):
		for enemy in my_enemies:
			enemy.enable()
