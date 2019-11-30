extends Node2D

########################################################
### Now sure how much explaination this really needs ###
########################################################

func self_destruct(): # Called from the animation player
	self.queue_free()
