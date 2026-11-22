extends CharacterBody3D
const JUMP_VELOCITY = 4
const sensitivity = 0.003
const BOB_FREQ: float = 3
const BOB_AMP: float = 0.3
var SPEED = 1.5
var head_bop = 0
var crouch = 0
var jump = 0
var t_bob: float = 0.0
var resistance = 1
var cam_height = 0.0
var current_bob = Vector3.ZERO
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func help(event):
	if event is InputEventKey:
		if false:
			print("key pressed: ", event.keycode)
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, 
			deg_to_rad(-70), deg_to_rad(60))
func _physics_process(delta: float) -> void:

	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_key_pressed(KEY_TAB):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not is_on_floor():
		velocity += get_gravity() * delta
		jump = 1
	else:
		jump = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and crouch == 0:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * resistance
		velocity.z = direction.z * SPEED * resistance

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	var bob = Vector3.ZERO
	if is_on_floor() and velocity.length() > 0.0 and crouch == 0:
		t_bob += delta * velocity.length() * BOB_AMP
		bob.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		bob.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	else:
		t_bob = 0
	current_bob = current_bob.lerp(bob, delta * 10.0)
	camera.position = Vector3(0, cam_height, 0) + current_bob
		
func reset():
	position = Vector3(50, 2, 4)
func crouching(delta):
	var target_height = 1.6
	if Input.is_key_pressed(KEY_C) and is_on_floor():
		crouch = 1
		resistance = 0.5
		target_height = -2
	else:
		crouch = 0
		resistance = 1
	cam_height = lerp(cam_height, float(target_height), delta * 10.0)

			
