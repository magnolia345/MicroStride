extends Area3D
@onready var flag = $CSGMesh3D

func _ready():
	flag.material_override.albedo_color = Color("b61f3b")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.has_method("checkpoint"):
			body.checkpoint()
		else:
			get_tree().reload_current_scene()
		flag.material_override.albedo_color = Color("7ac93c")
