extends CharacterBody3D

const JUMP_VELOCITY = 3.5
const sensitivity = 0.003
const BOB_FREQ: float = 3.0
const BOB_AMP: float = 0.08

var SPEED = 5.0
var crouch = 0
var t_bob: float = 0.0
var resistance = 1.0
var cam_height = 1.5
var current_bob = Vector3.ZERO
var is_third_person = false
var third_person_distance = 1.2
var turn_timer: float = 0.0

@onready var head: Node3D = $Head
@onready var spring_arm: SpringArm3D = $Head/SpringArm3D
@onready var camera: Camera3D = $Head/SpringArm3D/Camera3D
@onready var mesh = $Node3D/Sketchfab_Scene
@onready var model_pivot: Node3D = $Node3D
@onready var animation: AnimationPlayer = $Node3D/Sketchfab_Scene/AnimationPlayer

func _ready() -> void:
	spring_arm.add_excluded_object(get_rid())
	spring_arm.margin = 0.3
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_camera_mode()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		model_pivot.rotation.y = head.rotation.y
		
		spring_arm.rotate_x(-event.relative.y * sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-40), deg_to_rad(20))
		
		if abs(event.relative.x) > 3.0 and abs(event.relative.x) > abs(event.relative.y):
			turn_timer = 0.15
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_V:
		is_third_person = not is_third_person
		update_camera_mode()

func update_camera_mode() -> void:
	if is_third_person:
		spring_arm.spring_length = third_person_distance
		mesh.show()
	else:
		spring_arm.spring_length = 0.0
		mesh.hide()

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_key_pressed(KEY_TAB):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and crouch == 0:
		velocity.y = JUMP_VELOCITY

	crouching(delta)

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * resistance
		velocity.z = direction.z * SPEED * resistance
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if turn_timer > 0.0:
		turn_timer -= delta

	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0.1 or turn_timer > 0.0:
		if animation.current_animation != "HamsterALL_Run" or not animation.is_playing():
			animation.play("HamsterALL_Run", 0.15)
	else:
		if animation.has_animation("HamsterALL_Idle"):
			if animation.current_animation != "HamsterALL_Idle":
				animation.play("HamsterALL_Idle", 0.2)
		elif animation.has_animation("RESET"):
			if animation.current_animation != "RESET":
				animation.play("RESET", 0.2)
		else:
			animation.pause()

	var bob = Vector3.ZERO
	if is_on_floor() and horizontal_speed > 0.1 and crouch == 0 and not is_third_person:
		t_bob += delta * horizontal_speed
		bob.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		bob.x = cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP
	else:
		t_bob = 0.0
	
	current_bob = current_bob.lerp(bob, delta * 10.0)
	head.position = Vector3(0, cam_height, 0) + current_bob

func crouching(delta: float) -> void:
	var target_height = 1.5
	if Input.is_key_pressed(KEY_C) and is_on_floor():
		crouch = 1
		resistance = 0.5
		target_height = 0.8
	else:
		crouch = 0
		resistance = 1.0
	cam_height = lerp(cam_height, target_height, delta * 10.0)

func reset() -> void:
	position = Vector3(50, 2, 4)
