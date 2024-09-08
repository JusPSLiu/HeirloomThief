extends CharacterBody2D

@export var audioPlayer : AudioStreamPlayer2D
@export var GUI : Control
@export var deathAnimator : AnimationPlayer

const SPEED = 500.0 # player movement speed
const BOOST_SPEED = 2400.0 # player dash speed
const BOOST_COOLDOWN = 0.5 # player dash cooldown rate (in seconds)
const JUMP_VELOCITY = -1000.0 # player jump velocity
const COYOTE_MAX = 0.1 # player jump coyote time cooldown
const LERP_DECAY_RATE = 12 # player acceleration/deceleration rate
const jumpsound = preload("res://Sounds/player/jump.wav")
const hitsound = preload("res://Sounds/player/beenhit.wav")
const slashsound = preload("res://Sounds/player/slice.wav")
const shoot = preload("res://Sounds/player/shoot.wav")
const projectile = preload("res://Scenes/Enemies/projectile.tscn")
const deathparticle = preload("res://Scenes/Player/death.tscn")
const healedsound = preload("res://Sounds/player/get_healed.wav")
const collectsound = preload("res://Sounds/player/collect.wav")

var coyoteTime = 0.14
var boostimer = 0.3
var currentDirection = false # false == left, true == right, used for dash
var doublejumped = false
var soundEffects : AudioStreamPlaybackPolyphonic
var respawnPoint : Vector2 = Vector2(0,0)
var DO_NOT_MOVE = false

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
	audioPlayer.stream = AudioStreamPolyphonic.new()
	audioPlayer.play()
	soundEffects = audioPlayer.get_stream_playback()
	respawnPoint = position


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
	
	if (velocity.x > 50 || velocity.x < -50):
		#$camera_carrot_on_stick.position.x = 250 if currentDirection else -250
		$camera_carrot_on_stick.position.x = velocity.x * 0.6
	else:
		$camera_carrot_on_stick.position.x = expDecay($camera_carrot_on_stick.position.x, 0, 2, delta)

# i saw a yt video by freya holmer abt this being a better exponential lerp
func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)

# using an interrupt for controls other than run because polling is dumb
func _input(event: InputEvent) -> void:
	# if mouse event
	if (!DO_NOT_MOVE):
		if (event is InputEventMouse):
			# basic meelee attack
			if (event.is_action_pressed("Attack") and !$playerattacks.is_playing()):
				#MAKE SURE NOT JUST PAUSING
				if (event.position.x > 1152 && event.position.x < 1248):
					if (event.position.y > 32 && event.position.y < 128):
						return
				$playerattacks.play("swing")
				$attackbox.look_at(get_global_mouse_position())
				soundEffects.play_stream(slashsound) #slashsound
				
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			
			elif (event.is_action_pressed("Shoot") and !$playerattacks.is_playing()):
				if (currentAbilities[ability.ring]):
					soundEffects.play_stream(shoot) #shootsound
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
				soundEffects.play_stream(slashsound) #slashsound
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			if (event.is_action_pressed("keyboardslice") and !$playerattacks.is_playing()):
				$playerattacks.play("swing")
				$attackbox.rotation = 0 if currentDirection else PI
				soundEffects.play_stream(slashsound) #slashsound
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true


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


# INJURY CONTROL
func get_hit(dmg : int, vec : Vector2) -> bool:
	if $player_fx.is_playing():
		return false
	elif (!deathAnimator.is_playing()):
		$player_fx.play("player_injured")
		soundEffects.play_stream(hitsound) #hitsound
		velocity = vec*200 # get knocked away
		coyoteTime = 0 # no jump 4 u
		SaveManager.current_health -= dmg
		if (GUI):
			GUI.show_curr_hp()
		if (SaveManager.current_health <= 0):
			if (deathAnimator != null):
				deathAnimator.play("die")
				$camera_carrot_on_stick.position.x = 0
				set_physics_process(false)
				hide()
				var deathy = deathparticle.instantiate()
				deathy.position = position
				add_sibling(deathy)
				velocity = Vector2(0, 0)
				DO_NOT_MOVE = true
			else:
				respawn()
			return true
	return false

func respawn():
	position = respawnPoint
	self.set_physics_process(true)
	SaveManager.current_health = 4
	velocity = Vector2(0, 0)
	show()
	if (GUI):
		GUI.show_curr_hp()
	DO_NOT_MOVE = false

## collectibles and health section :D
func get_healed(hlth : int):
	SaveManager.current_health += hlth
	soundEffects.play_stream(healedsound)
	if (GUI):
		GUI.show_curr_hp()

func get_health_upgrade(id:int):
	if (!SaveManager.already_collected(SaveManager.Item.health, id)):
		SaveManager.max_health += 2
		SaveManager.current_health = SaveManager.max_health
		SaveManager.collect_item(SaveManager.Item.health, id)
		soundEffects.play_stream(collectsound)
		if (GUI):
			GUI.make_enough_hearts()
			GUI.show_curr_hp()

func get_gem_upgrade(id:int):
	if (!SaveManager.already_collected(SaveManager.Item.gem, id)):
		SaveManager.current_gems += 1
		SaveManager.collect_item(SaveManager.Item.gem, id)
		soundEffects.play_stream(collectsound)

func _on_room_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Room"):
		var camera = $camera_carrot_on_stick/Camera2D
		camera.limit_top = area.global_position.y
		camera.limit_left = area.global_position.x
		camera.limit_bottom = area.global_position.y + area.scale.y
		camera.limit_right = area.global_position.x + area.scale.x

func get_checkpoint(positron):
	respawnPoint = positron
	SaveManager.save_game()
