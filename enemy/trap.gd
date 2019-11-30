extends KinematicBody2D

class_name Trap

## For static enemy types, should be changed from unnessisary KinematicBody2D in the future ##

export var isHardOnly = false # if true, will delete self on easy mode

func _ready():
	if isHardOnly and User_Data.curVars.difficulty == 1: # check the current difficulty
		self.queue_free() # self delete

func _on_Enemy_body_entered(body): # on signal
	if body is Player:
		if body.has_method("contact"): 
			body.contact(-1) # damage the player
			### Can easily be updated to a variable to deal more damage ###
