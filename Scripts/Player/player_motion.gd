extends CharacterBody2D

@export var audioPlayer : AudioStreamPlayer2D


const SPEED = 500.0 # player movement speed
const BOOST_SPEED = 2400.0 # player dash speed
const BOOST_COOLDOWN = 0.5 # player dash cooldown rate (in seconds)
const JUMP_VELOCITY = -1000.0 # player jump velocity
const COYOTE_MAX = 0.14 # player jump coyote time cooldown
const LERP_DECAY_RATE = 12 # player acceleration/deceleration rate
const jumpsound = preload("res://Sounds/player/jump.wav")
const slashsound = preload("res://Sounds/player/slice.wav")
const shoot = preload("res://Sounds/player/shoot.wav")
const projectile = preload("res://Scenes/Enemies/projectile.tscn")

var coyoteTime = 0.14
var boostimer = 0.3
var currentDirection = false # false == left, true == right, used for dash
var doublejumped = false
var soundEffects : AudioStreamPlaybackPolyphonic

# Abilities
var currentAbilities : Array[bool] = [false, false, false]
enum ability {
	ring = 0,
	cape = 1,
	boot = 2
}

# when spawn in, activate proper abilities
func _ready() -> void:
	currentAbilities[ability.ring] = true
	#currentAbilities[ability.cape] = true
	#currentAbilities[ability.boot] = true
	audioPlayer.stream = AudioStreamPolyphonic.new()
	audioPlayer.play()
	soundEffects = audioPlayer.get_stream_playback()


func _physics_process(delta: float) -> void:
	move_and_slide()
	# Add the gravity.
	if is_on_floor():
		if (coyoteTime <= 0):
			Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
			doublejumped = false
		coyoteTime = COYOTE_MAX
	else:
		if (velocity.y < 0):
			if Input.is_action_pressed("Jump") or doublejumped:
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
		if (direction > 0):
			currentDirection = true
			if (is_on_floor()):
				$playerSprite.play('runR')
			else:
				$playerSprite.play('jumpR')
		else:
			currentDirection = false
			if (is_on_floor()):
				$playerSprite.play('runL')
			else:
				$playerSprite.play('jumpL')
			
	else:
		velocity.x = expDecay(velocity.x, 0, LERP_DECAY_RATE, delta)
		if (is_on_floor()):
			if (currentDirection): $playerSprite.play('defaultR')
			else: $playerSprite.play("defaultL")
	
	# the dash cooldown
	if (boostimer >= 0):
		boostimer -= delta
	
	$camera_carrot_on_stick.position.x = velocity.x*.6

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
			soundEffects.play_stream(slashsound) #slashsound
			
			# slight double jump for bat attack
			if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
				velocity.y = JUMP_VELOCITY*0.2
				doublejumped = true
		
		elif (event.is_action_pressed("Shoot") and !$playerattacks.is_playing()):
			if (currentAbilities[ability.ring]):
				soundEffects.play_stream(shoot) #slashsound
				$playerattacks.play("shoot")
				#make the projectile; possibly replace with special player projectile later
				var newprojectile = projectile.instantiate()
				newprojectile.position = position
				newprojectile.apply_scale(Vector2(4, 4))
				newprojectile.movement_direction = (get_global_mouse_position()-position).normalized()
				newprojectile.speed = 1000
				add_sibling(newprojectile)
				
				# the double jump for laser
				if ((get_global_mouse_position()-position).dot(Vector2(0, 1)) > 0):
					velocity.y = JUMP_VELOCITY
					doublejumped = true
	# if keyboard / button event
	else:
		# Handle jump.
		if event.is_action_pressed("Jump") and coyoteTime > 0:
			velocity.y = JUMP_VELOCITY
			coyoteTime = 0
			if (currentDirection): $playerSprite.play('jumpR')
			else: $playerSprite.play('jumpL')
			soundEffects.play_stream(jumpsound) #jumpsound
			doublejumped = false
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
