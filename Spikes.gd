extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.has_method("reset"):
			body.reset()
		else:
			get_tree().reload_current_scene()
