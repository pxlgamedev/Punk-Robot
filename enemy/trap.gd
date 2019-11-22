extends KinematicBody2D

class_name Trap

func _on_Enemy_body_entered(body):
	if body is Player:
		if body.has_method("contact"):
			body.contact(-1)
