# Jordan's GLORIOUS turtle car script
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_SPEED = 50.0
const MAX_TURBO_SPEED = 100.0
const ACCELERATION = 5.0
const ROTATION_SPEED = 2.0
const TURBO_SPEED_FACTOR = 3.0
const TURBO_INCREASE_AMOUNT = 10.0
const TURBO_DECREASE_AMOUNT = 20.0
var current_speed = 0.0
var animation_tree : AnimationTree
var prevent_turbo := false
var turbo_fuel := 100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var last_position := position

func _ready():
# Assuming you have an AnimationTree node as a child of this node
	animation_tree = $AnimationTree
	
func reset_to_last_position():
	position = last_position
	position.y += 1
	turbo_fuel = 0.0
	prevent_turbo = true
	current_speed = 0.0
	velocity = Vector3.ZERO

func _physics_process(delta):
	# Handling turbo
	var speed_factor = 1
	var max_speed = MAX_SPEED
	if Input.is_action_pressed("turbo") and turbo_fuel > 0 and not prevent_turbo:
		speed_factor = TURBO_SPEED_FACTOR
		turbo_fuel = clamp(turbo_fuel - TURBO_DECREASE_AMOUNT * delta, 0, 100)
		max_speed = MAX_TURBO_SPEED
	if turbo_fuel == 0:
		speed_factor = 1
		prevent_turbo = true
	if turbo_fuel == 100:
		prevent_turbo = false
	if prevent_turbo:
		turbo_fuel = clamp(turbo_fuel + TURBO_INCREASE_AMOUNT * delta, 0, 100)
	
	#$Label3D.text = "TURBO: " + str(int(turbo_fuel))
	
	if is_on_floor():
		last_position = position
	else:
		velocity.y -= gravity * delta

	# Handle Jump.Al
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	# Calculate movement
	var forward_vector = transform.basis.z
	var movement = forward_vector * input_dir.y
	
	if input_dir.y < 0:
		current_speed = min(current_speed + ACCELERATION * delta, max_speed)
	elif input_dir.y > 0:
		current_speed = max(current_speed - ACCELERATION * delta * 10, 0)
	else:
		current_speed = max(current_speed - ACCELERATION * delta, 0)
		
	# Calculate rotation
	var rotation = Vector3(0, -input_dir.x * 2/(1+current_speed/5), 0)

	# Move the character
	var move_vector = -forward_vector * current_speed * speed_factor
	velocity.x = move_vector.x
	velocity.z = move_vector.z

	# Rotate the character
	rotate_y(rotation.y * delta)
	
	var playback_speed = 1.0 + current_speed
	animation_tree.set("parameters/Run/TimeScale/scale", playback_speed)
	
	$AnimationTree.set("parameters/conditions/idle", current_speed == 0)
	$AnimationTree.set("parameters/conditions/run", current_speed != 0)
	move_and_slide()
