extends CharacterBody3D

var delay = 0.0
var speed = 5.0
@onready var animation = $Sketchfab_Scene/AnimationPlayer
@onready var mesh = $Sketchfab_Scene



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	velocity.z = speed
	
	delay += delta
	if delay > 2.0:
		delay = 0.0
		speed = -speed
		mesh.rotate_y(PI) # Rotates 180 degrees cleanly without inverting scale

	move_and_slide()
	animation.play("GltfAnimation 0")
