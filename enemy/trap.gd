extends KinematicBody2D

class_name Trap

export var isHardOnly = false

func _ready():
	if isHardOnly and User_Data.curVars.difficulty == 1:
		self.queue_free()

func _on_Enemy_body_entered(body):
	if body is Player:
		if body.has_method("contact"):
			body.contact(-1)
