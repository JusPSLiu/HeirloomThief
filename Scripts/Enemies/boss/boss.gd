extends Enemy

var movement_direction : int
var player : CharacterBody2D
var starting_height : float

@export var fire_rate := 0.4

# State machine variables and references
@onready var states = $StateManager
@onready var idle = $StateManager/Idle
@onready var proj_attack = $StateManager/ProjAttack
@onready var jump = $StateManager/Jump

# Scene references
@onready var animator = $Animator
@onready var projectile_scene = preload("res://Scenes/Enemies/projectile.tscn")

func _ready() -> void:
	# Run ready function from inhereted script
	super._ready()
	
	# Initialize state manager, passing in self as parent entity
	states.init(self)
	
	# Face left by default
	movement_direction = -1
	
	starting_height = global_position.y

func _physics_process(delta: float) -> void:
	# Run physics process from inhereted script
	super._physics_process(delta)
	
	# Run state machine physics update
	states.physics_update(delta)

func shoot(number_of_projectiles: int) -> void:
	if current_health > 0:
		for proj in number_of_projectiles:
			# wait
			await get_tree().create_timer(fire_rate).timeout
			
			for i in 5: #number of projectile spawn positions
				# create instance of projectile
				var projectile = projectile_scene.instantiate()
				
				# set projectile properties
				projectile.speed = 500
				projectile.rotation = $ProjectileSpawns.get_child(i).rotation
				projectile.movement_direction = Vector2(0, 1).rotated(projectile.rotation)
				projectile.scale = Vector2(6, 6) # scaled to size of enemy [temporary]
				projectile.global_position = $ProjectileSpawns.get_child(i).global_position
				
				# add to scene
				get_parent().add_child(projectile)

func telegraph_shoot():
	pass
