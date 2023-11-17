# Jordan's GLORIOUS turtle car script
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_SPEED = 100.0
const ACCELERATION = 5.0
const ROTATION_SPEED = 2.0
var current_speed = 0.0
var animation_tree : AnimationTree

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
# Assuming you have an AnimationTree node as a child of this node
	animation_tree = $AnimationTree

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
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
		current_speed = min(current_speed + ACCELERATION * delta, MAX_SPEED)
	elif input_dir.y > 0:
		current_speed = max(current_speed - ACCELERATION * delta * 10, 0)
	else:
		current_speed = max(current_speed - ACCELERATION * delta, 0)
		
	# Calculate rotation
	var rotation = Vector3(0, -input_dir.x * 2/(1+current_speed/5), 0)

	# Move the character
	velocity = -forward_vector * current_speed

	# Rotate the character
	rotate_y(rotation.y * delta)
	
	var playback_speed = 1.0 + current_speed
	animation_tree.set("parameters/Run/TimeScale/scale", playback_speed)
	
	$AnimationTree.set("parameters/conditions/idle", current_speed == 0)
	$AnimationTree.set("parameters/conditions/run", current_speed != 0)
	move_and_slide()
