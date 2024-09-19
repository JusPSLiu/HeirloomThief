extends Sprite2D

const offsetCenter = Vector2(385,366)

@export var maxPos : Vector2 = Vector2(0, 0)
@export var minPos : Vector2 = Vector2(0, 0)
@export var healthLocations : Array[ColorRect]
@export var gemLocations : Array[ColorRect]
var mapIsShown = false

var textureSize = Vector2(64,16)
var currCenter : Vector2 = Vector2(0.5, 0.5)
var clicking = false
var clickingStartPos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_center_here()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (clicking):
		position = clickingStartPos+get_global_mouse_position()
		set_center_here()
		make_sure_not_past_edge()
	else:
		var joystickInput = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		)
		if (abs(joystickInput) > Vector2(0.1,0.1)):
			position -= joystickInput*10
			set_center_here()
			make_sure_not_past_edge()
	if Input.is_action_pressed("controller_zoom_in"):
		scale *= Vector2(1.02, 1.02)
		if (scale.x > 64):
			scale = Vector2(64, 64)
		reset_position_to_center()
	if Input.is_action_pressed("controller_zoom_out"):
		scale /= Vector2(1.02, 1.02)
		if (scale.x < 8):
			scale = Vector2(8, 8)
		reset_position_to_center()

func make_sure_not_past_edge():
	var pastEdge = false
	if (currCenter.x < maxPos.x):
		pastEdge = true
		currCenter.x = maxPos.x
	elif (currCenter.x > minPos.x):
		pastEdge = true
		currCenter.x = minPos.x
	if (currCenter.y > maxPos.y):
		pastEdge = true
		currCenter.y = maxPos.y
	elif (currCenter.y < minPos.y):
		pastEdge = true
		currCenter.y = minPos.y
	if (pastEdge):
		reset_position_to_center()

func _input(event: InputEvent) -> void:
	if (get_tree().paused and mapIsShown):
		if (event is InputEventMouse and !event.is_echo()):
			if (event.position.x < 814 and event.position.y > 104):
				if event.is_action_pressed("zoom_in"):
					scale *= Vector2(1.1, 1.1)
					if (scale.x > 64):
						scale = Vector2(64, 64)
					reset_position_to_center()
				if event.is_action_pressed("zoom_out"):
					scale /= Vector2(1.1, 1.1)
					if (scale.x < 8):
						scale = Vector2(8, 8)
					reset_position_to_center()
				if (event.is_action_pressed("Attack")):
					clicking = true
					clickingStartPos = position-get_global_mouse_position()
			if (event.is_action_released("Attack")):
				clicking = false

func reset_position_to_center():
	position = scale*textureSize*currCenter + offsetCenter

func set_center_here():
	currCenter = (position-offsetCenter)/(textureSize*scale);

func set_up():
	var currNum = 0
	scale = Vector2(32, 32)
	for room in get_children():
		if (currNum == SaveManager.current_room):
			# make the current room blue and center everything around it
			position = offsetCenter - ((room.position)*scale) + Vector2(-16, -16)
			room.set_color(Color(0, 0.85, 0.91, 1))
			for child in room.get_children():
				child.show()
		elif (SaveManager.visited_rooms.size() > currNum and SaveManager.visited_rooms[currNum]):
			# make the visited rooms white and show their kids
			room.set_color(Color(1, 1, 1))
			for child in room.get_children():
				child.show()
		else:
			# make the unvisited rooms gray and hide their kids
			room.set_color(Color(0.2, 0.2, 0.2))
			for child in room.get_children():
				child.hide()
		currNum+=1
	
	currNum = 0
	for gem in gemLocations:
		if (SaveManager.already_collected(SaveManager.Item.gem, currNum)):
			gem.hide()
		currNum+=1
	
	currNum = 0
	for heart in healthLocations:
		if (SaveManager.already_collected(SaveManager.Item.health, currNum)):
			heart.hide()
		currNum+=1
	set_center_here()
	
