extends Control

const fullheart = preload("res://Art/UI/hearts/full.png")
const halfheart = preload("res://Art/UI/hearts/half.png")
const noheart = preload("res://Art/UI/hearts/empty.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_enough_hearts()
	show_curr_hp()


func show_curr_hp():
	var health = SaveManager.current_health
	for heart in $healthbox.get_children():
		if (health > 1):
			heart.texture = fullheart
		elif (health > 0):
			heart.texture = halfheart
		else:
			heart.texture = noheart
		health-=2

func make_enough_hearts():
	while ($healthbox.get_children().size() < SaveManager.max_health>>1):
		var newheart = TextureRect.new()
		$healthbox.add_child(newheart)
