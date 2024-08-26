extends CharacterBody2D

@export var audioPlayer : AudioStreamPlayer


const SPEED = 600.0 # player movement speed
const BOOST_SPEED = 2400.0 # player dash speed
const BOOST_COOLDOWN = 0.5 # player dash cooldown rate (in seconds)
const JUMP_VELOCITY = -1000.0 # player jump velocity
const COYOTE_MAX = 0.14 # player jump coyote time cooldown
const LERP_DECAY_RATE = 12 # player acceleration/deceleration rate


var coyoteTime = 0.14
var boostimer = 0.3
var currentDirection = false # false == left, true == right, used for dash

# Abilities
var currentAbilities : Array[bool] = [false, false, false]
enum ability {
	ring = 0,
	cape = 1,
	boot = 2
}

# when spawn in, activate proper abilities
func _ready() -> void:
	#currentAbilities[ability.ring] = true
	#currentAbilities[ability.cape] = true
	#currentAbilities[ability.boot] = true
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	# Add the gravity.
	if is_on_floor():
		if (coyoteTime <= 0):
			Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
		coyoteTime = COYOTE_MAX
	else:
		if (velocity.y < 0):
			if Input.is_action_pressed("Jump"):
				velocity += get_gravity() * delta * 2.5
			else:
				velocity += get_gravity() * delta * 6
		else:
			# if cape ability, and up pressed, slow down
			if currentAbilities[ability.cape] and Input.is_action_pressed("Jump") and boostimer <= 0:
				velocity.y = expDecay(velocity.y, get_gravity().y * 0.3, LERP_DECAY_RATE, delta)
			else:
				velocity += get_gravity() * delta * 3.2
		if (coyoteTime > 0):
			coyoteTime -= delta

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = expDecay(velocity.x, direction * SPEED, LERP_DECAY_RATE, delta)
		currentDirection = (direction > 0)
	else:
		velocity.x = expDecay(velocity.x, 0, LERP_DECAY_RATE, delta)
	
	# the dash cooldown
	if (boostimer >= 0):
		boostimer -= delta

# i saw a yt video by freya holmer abt this being a better exponential lerp
func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)

# using an interrupt for controls other than run because polling is dumb
func _input(event: InputEvent) -> void:
	# if mouse event
	if (event is InputEventMouse):
		# basic meelee attack
		if (event.is_action_pressed("Attack") and !$playerattacks.is_playing()):
			$playerattacks.play("swing")
			$attackbox.look_at(get_global_mouse_position())
	# if keyboard / button event
	else:
		# Handle jump.
		if event.is_action_pressed("Jump") and coyoteTime > 0:
			velocity.y = JUMP_VELOCITY
			coyoteTime = 0
		# dash / boost
		if event.is_action_pressed("Dash"):
			if currentAbilities[ability.cape] and boostimer < 0:
				Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
				velocity.x += BOOST_SPEED if currentDirection else -1*BOOST_SPEED
				boostimer = BOOST_COOLDOWN
		# basic meelee attack
		if (event.is_action_pressed("Attack") and !$playerattacks.is_playing()):
			$playerattacks.play("swing")
			$attackbox.rotation = getSwingAngle()


func getSwingAngle():
	var joystickInput = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if (joystickInput.x < 0.1 and joystickInput.y < 0.1):
		joystickInput = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)
	return joystickInput.angle()
