extends CharacterBody2D

# exported variables
@export var GUI : Control
@export var deathAnimator : AnimationPlayer
@export var jumpsound : AudioStreamPlayer2D
@export var hitsound : AudioStreamPlayer2D
@export var slashsound : AudioStreamPlayer2D
@export var shootsound : AudioStreamPlayer2D
@export var healedsound : AudioStreamPlayer2D
@export var collectsound : AudioStreamPlayer2D

# constant variables
const SPEED = 500.0 # player movement speed
const BOOST_SPEED = 2400.0 # player dash speed
const BOOST_COOLDOWN = 0.5 # player dash cooldown rate (in seconds)
const JUMP_VELOCITY = -1000.0 # player jump velocity
const COYOTE_MAX = 0.1 # player jump coyote time cooldown
const LERP_DECAY_RATE = 12 # player acceleration/deceleration rate

# automatically initialized variables
@onready var camera : Camera2D = get_node("camera_carrot_on_stick/Camera2D")
@onready var projectile = preload("res://Scenes/Player/items/projectile1.tscn")
@onready var deathparticle = preload("res://Scenes/Player/death.tscn")

# regular variables
var coyoteTime = 0.14
var boostimer = 0.3 # cooldown for boost
var currentDirection = false # false == left, true == right, used for dash
var doublejumped = false # has double jumped, do full jump height
var DO_NOT_MOVE = false # not actually a const, just really important
var currentlyFloating = false # for animation; floating means air animation
var doorLocation = null # location of other door; null if not there
# Abilities
var currentAbilities : Array = [-1, 0, 0, 0, 0]
var stick : Node2D
# specifically camera variables
var just_respawned = false # just respawned; camera just snapped, turn back on smoothing plz
var transitioning = false # camera is moving
var camera_target_top = 0.0
var camera_target_bottom = 0.0
var camera_target_left = 0.0
var camera_target_right = 0.0

enum ability {
	stick = 0,
	ring = 1,
	cape = 2,
	crown = 3,
	hook = 4
}

# when spawn in, activate proper abilities
func _ready() -> void:
	#SaveManager.powerstatus[ability.ring] = 1
	set_powerstatus()
	
	if (SaveManager.respawn_point == Vector2.ZERO):
		SaveManager.respawn_point = position
	else:
		position = SaveManager.respawn_point
		camera.position_smoothing_enabled = false
		just_respawned = true
	
	#camera.limit_bottom = 0
	#camera.limit_top = 0
	#camera.limit_left = 0
	#camera.limit_right = 0


func _physics_process(delta: float) -> void:
	if (just_respawned):
		camera.position_smoothing_enabled = true
		just_respawned = false
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
	
	camera_transitions(delta)


## Inputs
# using an interrupt for controls other than run because polling is dumb
func _input(event: InputEvent) -> void:
	# if mouse event
	if (!DO_NOT_MOVE):
		if (event is InputEventMouse):
			# basic meelee attack
			if (event.is_action_pressed("Attack") and !stick.get_child(0).is_playing()):
				#MAKE SURE NOT JUST PAUSING
				if (event.position.x > 1152 && event.position.x < 1248):
					if (event.position.y > 32 && event.position.y < 128):
						return
				
				#play the swing animation
				stick.get_child(0).play("swing")
				stick.get_child(1).look_at(get_global_mouse_position())
				if (get_global_mouse_position().x > position.x):
					stick.get_child(1).look_at(get_global_mouse_position())
					var sticksprite = stick.get_child(1).get_child(0)
					sticksprite.set_flip_h(false)
					sticksprite.rotation = 0
				else:
					var sticksprite = stick.get_child(1).get_child(0)
					sticksprite.set_flip_h(true)
					sticksprite.rotation = PI
				
				# and the sound
				if (slashsound): slashsound.play()
				
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			
			elif (event.is_action_pressed("Shoot") and !stick.get_child(0).is_playing()):
				if (currentAbilities[ability.ring]):
					if (shootsound): shootsound.play()
					stick.get_child(0).play("shoot")
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
			if (event.is_action_pressed("Attack") and !stick.get_child(0).is_playing()):
				stick.get_child(0).play("swing")
				stick.get_child(1).rotation = getSwingAngle()
				if (slashsound): slashsound.play()
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true
			if (event.is_action_pressed("keyboardslice") and !stick.get_child(0).is_playing()):
				stick.get_child(0).play("swing")
				stick.get_child(1).rotation = 0 if currentDirection else PI
				if (slashsound): slashsound.play()
				# slight double jump for bat attack
				if (!is_on_floor() and velocity.y > JUMP_VELOCITY*0.2):
					velocity.y = JUMP_VELOCITY*0.2
					doublejumped = true

# get input angle
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


## INJURY CONTROL
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
				set_physics_process(false)
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
	camera.position_smoothing_enabled = false
	
	self.set_physics_process(true)
	set_collision_layer_value(1, true)
	SaveManager.current_health = 4
	velocity = Vector2(0, 0)
	show()
	if (GUI):
		GUI.show_curr_hp()
	DO_NOT_MOVE = false
	
	just_respawned = true


## Upgrades and Health section :D
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

## Powerups
func update_powerstatus(currMode):
	currMode = clamp(int(currMode), 0, ability.hook)
	print(currentAbilities)
	currentAbilities[currMode] += 1
	print(currentAbilities)
	SaveManager.powerstatus[currMode] += 1
	
	if (currMode == ability.ring):
		projectile = load("res://Scenes/Player/items/projectile"+str(clamp(currentAbilities[ability.ring], 1, 2))+".tscn")
	elif (currMode == ability.stick):
		if (stick):
			stick.queue_free()
		var newstick = load("res://Scenes/Player/items/stick_attack"+str(clamp(currentAbilities[ability.stick], 1, 2))+".tscn")
		stick = newstick.instantiate()
		add_child(stick)
		stick.position = Vector2.ZERO

func set_powerstatus():
	# update ring if must
	if (currentAbilities[ability.ring] != SaveManager.powerstatus[ability.ring]):
		if (SaveManager.powerstatus[ability.ring] == 1):
			projectile = preload("res://Scenes/Player/items/projectile1.tscn")
		else:
			projectile = preload("res://Scenes/Player/items/projectile2.tscn")
	
	# update stick if must
	if (currentAbilities[ability.stick] != SaveManager.powerstatus[ability.stick]):
		if (stick):
			stick.queue_free()
		var newstick = load("res://Scenes/Player/items/stick_attack"+str(clamp(SaveManager.powerstatus[ability.stick], 1, 2))+".tscn")
		stick = newstick.instantiate()
		add_child(stick)
		stick.position = Vector2.ZERO
	
	currentAbilities = SaveManager.powerstatus

## Rooms
func _on_room_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Room"):
		# set the camera limits
		#camera.limit_top = area.global_position.y
		#camera.limit_left = area.global_position.x
		#camera.limit_bottom = area.global_position.y + area.scale.y
		#camera.limit_right = area.global_position.x + area.scale.x
		camera_target_top = area.global_position.y
		camera_target_left = area.global_position.x
		camera_target_bottom = area.global_position.y + area.scale.y
		camera_target_right = area.global_position.x + area.scale.x
		
		# fancy camera transition stuff
		transitioning = true
		if (camera.global_position.y-360 < camera_target_top and camera.limit_top != camera_target_top):
			camera.limit_top = camera.global_position.y-360
		if (camera.global_position.x-640 < camera_target_left and camera.limit_left != camera_target_left):
			camera.limit_left = camera.global_position.x-(640*1.5)
		if (camera.global_position.y+360 > camera_target_bottom and camera.limit_bottom != camera_target_bottom):
			camera.limit_bottom = camera.global_position.y+360
		if (camera.global_position.x+640 > camera_target_right and camera.limit_right != camera_target_right):
			camera.limit_right = camera.global_position.x+(640*1.5)
		
		# set the current room, and tell the manager youve visited it
		SaveManager.current_room = area.room_number
		if (SaveManager.visited_rooms.size() <= area.room_number):
			var sizeToGet = area.room_number - SaveManager.visited_rooms.size()
			var newArr : PackedByteArray = [0]
			while (newArr.size() <= sizeToGet):
				newArr.append_array([0, 0, 0, 0, 0])
			SaveManager.visited_rooms.append_array(newArr)
		SaveManager.visited_rooms[area.room_number] = true

func camera_transitions(delta):
	if (transitioning):
		# for some reason lerping and exp decay both are having trouble with this
		# and the workaround looks a bit messy, but it works
		#var trans_speed = 5.0 # im using lerp decay rate, no need for this thing
		var transing = false
		
		var prev_val = camera.limit_top
		camera.limit_top = ceil(expDecay(camera.limit_top, camera_target_top, LERP_DECAY_RATE, delta))
		if (camera.limit_top == prev_val): camera.limit_top = camera_target_top
		else: transing = true
		
		prev_val = camera.limit_left
		camera.limit_left = ceil(expDecay(camera.limit_left, camera_target_left, LERP_DECAY_RATE, delta))
		if (camera.limit_left == prev_val): camera.limit_left = camera_target_left
		else: transing = true
		
		prev_val = camera.limit_bottom
		camera.limit_bottom = floor(expDecay(camera.limit_bottom, camera_target_bottom, LERP_DECAY_RATE, delta))
		if (camera.limit_bottom == prev_val): camera.limit_bottom = camera_target_bottom
		else: transing = true
		
		prev_val = camera.limit_right
		camera.limit_right = floor(expDecay(camera.limit_right, camera_target_right, LERP_DECAY_RATE, delta))
		if (camera.limit_right == prev_val): camera.limit_right = camera_target_right
		else: transing = true
		
		if (!transing):
			transitioning = false


## Checkpoints and Doors
func get_checkpoint(positron):
	SaveManager.respawn_point = positron
	SaveManager.save_game()

func allow_doory(gotopos):
	doorLocation = gotopos

func exit_doory(gotopos):
	if (doorLocation == gotopos):
		doorLocation = null


# i saw a yt video by freya holmer abt this being a better exponential lerp
func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)
