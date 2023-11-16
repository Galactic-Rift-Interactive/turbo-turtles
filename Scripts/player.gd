extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURBO_SPEED_FACTOR = 3.0
const TURBO_DECREASE_AMOUNT = 20.0
const TURBO_INCREASE_AMOUNT = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var last_position := position
@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera3D

var turbo_fuel := 100.0
var prevent_turbo := false

func _unhandled_input(event):
	# Switch mouse capture on and off based on user input
	handle_mouse_capture(event)
	
	# process camera rotation if mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		process_mouse_motion(event)

# changes the mouse mode depending on input
func handle_mouse_capture(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# uses mouse movement to rotate the camera
func process_mouse_motion(event):
	if event is InputEventMouseMotion:
		pivot.rotate_y(-event.relative.x * 0.001)
		
		var new_x_rotation = camera.rotation.x - event.relative.y * 0.001
		
		# clamp used to limit how far camera can look up and down
		camera.rotation.x = clamp(new_x_rotation, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	var speed_factor = 1
	if Input.is_action_pressed("turbo") and turbo_fuel > 0 and not prevent_turbo:
		speed_factor = TURBO_SPEED_FACTOR
		turbo_fuel = clamp(turbo_fuel - TURBO_DECREASE_AMOUNT * delta, 0, 100)
	if turbo_fuel == 0:
		speed_factor = 1
		prevent_turbo = true
	if turbo_fuel == 100:
		prevent_turbo = false
	if prevent_turbo:
		turbo_fuel = clamp(turbo_fuel + TURBO_INCREASE_AMOUNT * delta, 0, 100)		
		
	$Pivot/Label3D.text = "TURBO: " + str(int(turbo_fuel))
	
	if is_on_floor():
		last_position = position
	else: # add gravity
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * speed_factor
		velocity.z = direction.z * SPEED * speed_factor
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * speed_factor)
		velocity.z = move_toward(velocity.z, 0, SPEED * speed_factor)

	move_and_slide()
