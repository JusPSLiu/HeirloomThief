extends CharacterBody2D

@export var audioPlayer : AudioStreamPlayer2D
@export var GUI : Control
@export var deathAnimator : AnimationPlayer

@onready var camera : Camera2D = get_node("camera_carrot_on_stick/Camera2D")
@onready var projectile = preload("res://Scenes/Player/projectile.tscn")
@onready var deathparticle = preload("res://Scenes/Player/death.tscn")

const SPEED = 500.0 # player movement speed
const BOOST_SPEED = 2400.0 # player dash speed
const BOOST_COOLDOWN = 0.5 # player dash cooldown rate (in seconds)
const JUMP_VELOCITY = -1000.0 # player jump velocity
const COYOTE_MAX = 0.1 # player jump coyote time cooldown
const LERP_DECAY_RATE = 12 # player acceleration/deceleration rate


@export var jumpsound : AudioStreamPlayer2D
@export var hitsound : AudioStreamPlayer2D
@export var slashsound : AudioStreamPlayer2D
@export var shootsound : AudioStreamPlayer2D
@export var healedsound : AudioStreamPlayer2D
@export var collectsound : AudioStreamPlayer2D
#@onready var jumpsound = preload("res://Sounds/player/jump.wav")
#@onready var hitsound = preload("res://Sounds/player/beenhit.wav")
#@onready var slashsound = preload("res://Sounds/player/slice.wav")
#@onready var shoot = preload("res://Sounds/player/shoot.wav")
#@onready var healedsound = preload("res://Sounds/player/get_healed.wav")
#@onready var collectsound = preload("res://Sounds/player/collect.wav")

var coyoteTime = 0.14
var boostimer = 0.3
var currentDirection = false # false == left, true == right, used for dash
var doublejumped = false
var DO_NOT_MOVE = false
var currentlyFloating = false
var doorLocation = null

var camera_target_top = 0>0
var camera_target_bottom = 0.0
var camera_target_left = 0.0
var camera_target_right = 0.0

# Abilities
var currentAbilities : Array = [false, false, false]
var currentUpgrades : Array = [false, false, false]
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
	#currentAbilities = SaveManager.powerstatus
	#currentUpgrades = SaveManager.powerupgradestatus
	
	if (SaveManager.respawn_point == Vector2.ZERO):
		SaveManager.respawn_point = position
	else: position = SaveManager.respawn_point
	
	#camera.limit_bottom = 0
	#camera.limit_top = 0
	#camera.limit_left = 0
	#camera.limit_right = 0


func _physics_process(delta: float) -> void:
	move_and_slide()
	# Add the gravity.
	if is_on_floor():
		$camera_carrot_on_stick.position.y = 0
		if (coyoteTime <= 0):
			currentlyFloating = false
			doublejumped = false
		coyoteTime = COYOTE_MAX
	else:
		if (velocity.y < 0):
			if Input.is_action_pressed("Jump") or doublejumped:
				velocity += get_gravity() * delta * 2.5
			else:
				velocity += get_gravity() * delta * 6
			$camera_carrot_on_stick.position.y = 0
		else:
			# if cape ability, and up pressed, slow down
			if currentAbilities[ability.cape] and Input.is_action_pressed("Jump") and boostimer <= 0:
				velocity.y = expDecay(velocity.y, get_gravity().y * 0.3, LERP_DECAY_RATE, delta)
				currentlyFloating = true
			else:
				velocity += get_gravity() * delta * 3.2
			if (velocity.y > 1300):
				$camera_carrot_on_stick.position.y = (velocity.y-1300)*2
			else:
				$camera_carrot_on_stick.position.y = 0
		if (coyoteTime > 0):
			coyoteTime -= delta

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and !DO_NOT_MOVE:
		velocity.x = expDecay(velocity.x, direction * SPEED, LERP_DECAY_RATE, delta)
		if (direction > 0):
			currentDirection = true
			if (is_on_floor()):
				$playerSprite.play('runR')
			else:
				if (currentlyFloating): $playerSprite.play('floatR')
				else: $playerSprite.play('jumpR')
		else:
			currentDirection = false
			if (is_on_floor()):
				$playerSprite.play('runL')
			else:
				if (currentlyFloating): $playerSprite.play('floatL')
				else: $playerSprite.play('jumpL')
			
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
	
	#camera_transitions(delta)

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
				if (slashsound): slashsound.play()
				
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			
			elif (event.is_action_pressed("Shoot") and !$playerattacks.is_playing()):
				if (currentAbilities[ability.ring]):
					if (shootsound): shootsound.play()
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
			if event.is_action_pressed("Jump"):
				if (doorLocation != null):
					#if in doorway, the jump button opens the door
					position = doorLocation
				elif coyoteTime > 0:
					velocity.y = JUMP_VELOCITY
					coyoteTime = 0
					if (currentDirection): $playerSprite.play('jumpR')
					else: $playerSprite.play('jumpL')
					if (jumpsound): jumpsound.play()
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
				if (slashsound): slashsound.play()
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			if (event.is_action_pressed("keyboardslice") and !$playerattacks.is_playing()):
				$playerattacks.play("swing")
				$attackbox.rotation = 0 if currentDirection else PI
				if (slashsound): slashsound.play()
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
		if (hitsound): hitsound.play()
		velocity = vec*200 # get knocked away
		coyoteTime = 0 # no jump 4 u
		SaveManager.current_health -= dmg
		if (GUI):
			GUI.show_curr_hp()
		if (SaveManager.current_health <= 0):
			if (deathAnimator != null):
				deathAnimator.play("die")
				$camera_carrot_on_stick.position.x = 0
				#set_physics_process(false)
				set_collision_layer_value(1, false)
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
	position = SaveManager.respawn_point
	#self.set_physics_process(true)
	set_collision_layer_value(1, true)
	SaveManager.current_health = 4
	velocity = Vector2(0, 0)
	show()
	if (GUI):
		GUI.show_curr_hp()
	DO_NOT_MOVE = false

## collectibles and health section :D
func get_healed(hlth : int):
	SaveManager.current_health += hlth
	if (healedsound): healedsound.play()
	if (GUI):
		GUI.show_curr_hp()

func get_health_upgrade(id:int):
	if (!SaveManager.already_collected(SaveManager.Item.health, id)):
		SaveManager.max_health += 2
		SaveManager.current_health = SaveManager.max_health
		SaveManager.collect_item(SaveManager.Item.health, id)
		if (collectsound): collectsound.play()
		if (GUI):
			GUI.make_enough_hearts()
			GUI.show_curr_hp()

func get_gem_upgrade(id:int):
	if (!SaveManager.already_collected(SaveManager.Item.gem, id)):
		SaveManager.current_gems += 1
		SaveManager.collect_item(SaveManager.Item.gem, id)
		if (collectsound): collectsound.play()

func _on_room_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Room"):
		
		camera.limit_top = area.global_position.y
		camera.limit_left = area.global_position.x
		camera.limit_bottom = area.global_position.y + area.scale.y
		camera.limit_right = area.global_position.x + area.scale.x
		
		#camera_target_top = area.global_position.y
		#camera_target_left = area.global_position.x
		#camera_target_bottom = area.global_position.y + area.scale.y
		#camera_target_right = area.global_position.x + area.scale.x
		
		SaveManager.current_room = area.room_number
		if (SaveManager.visited_rooms.size() <= area.room_number):
			var sizeToGet = SaveManager.visited_rooms.size()-area.room_number
			var newArr : PackedByteArray = [0]
			while (newArr.size() < sizeToGet):
				newArr.append_array([0,0,0,0,0])
			SaveManager.visited_rooms.append_array(newArr)
		SaveManager.visited_rooms[area.room_number] = true

func get_checkpoint(positron):
	SaveManager.respawn_point = positron
	SaveManager.save_game()

func allow_doory(gotopos):
	doorLocation = gotopos

func exit_doory(gotopos):
	if (doorLocation == gotopos):
		doorLocation = null

func camera_transitions(delta):
	var trans_speed = 5.0
	camera.limit_top = lerpf(camera.limit_top, camera_target_top, trans_speed * delta)
	camera.limit_left = lerpf(camera.limit_left, camera_target_left, trans_speed * delta)
	camera.limit_bottom = lerpf(camera.limit_bottom, camera_target_bottom, trans_speed * delta)
	camera.limit_right = lerpf(camera.limit_right, camera_target_right, trans_speed * delta)
	
	print(camera.limit_bottom, " ", camera.limit_left, " ", camera.limit_bottom, " ", camera.limit_right)
