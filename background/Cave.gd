extends Area2D

##############################################################################
### Controller for changing the parallax background when entering an area. ###
### Use this to instantiate main background rather than load in the scene. ###
### Use with a collision shape masking out the second area for enabling BG.###
##############################################################################

onready var bg1 = preload("res://background/PurpleMountainBg.tscn")
onready var bg2 = preload("res://background/CaveBg.tscn")

var aboveGround = true

func _ready():
	var newBg
	newBg = bg1.instance() # instantiate our main background
	self.call_deferred("add_child", newBg) # add as child of current node

func _on_Area2D_body_entered(body): # Sent from the Area2d
	if body is Player and aboveGround: # if it's the player and we are still aboveGround
		if self.get_child_count() > 0: # we need to check if a background already exists
			for n in self.get_children(): # check each child
				if n.name != "CaveZone": # ignore the collision shape
					self.remove_child(n) 
					n.queue_free() # we need to remove to prevent conflicts
		var newBg
		newBg = bg2.instance() # instance the second background
		self.call_deferred("add_child", newBg) # add as child after all process
		aboveGround = false # no longer aboveGround

func _on_Area2D_body_exited(body): # sent from the area2D
	if body is Player and !aboveGround: # not already above ground
		if self.get_child_count() > 0:  # same for loop as before
			for n in self.get_children():
				if n.name != "CaveZone":
					self.remove_child(n)
					n.queue_free() 
		var newBg
		newBg = bg1.instance() # reinstantiate the first background
		self.call_deferred("add_child", newBg) # add as child after all process
		aboveGround = true # Now above ground
