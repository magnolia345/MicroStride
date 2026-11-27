extends MeshInstance3D

@export var flow_speed := Vector2(0.05, 0.03)

func _process(delta: float) -> void:
	var mat := get_active_material(0) as StandardMaterial3D
	if mat:
		mat.uv1_offset += Vector3(flow_speed.x, flow_speed.y, 0.0) * delta
