extends RigidBody2D

func _bullet_end():
	queue_free()