extends Area2D

onready var bg1 = preload("res://background/PurpleMountainBg.tscn")
onready var bg2 = preload("res://background/CaveBg.tscn")

var aboveGround = true

func _ready():
	var newBg
	newBg = bg1.instance()
	self.call_deferred("add_child", newBg)

func _on_Area2D_body_entered(body):
	if body is Player and aboveGround:
		if self.get_child_count() > 0: # we need to check if a background already exists
			for n in self.get_children(): # check each child
				if n.name != "CaveZone": # not the collision shape
					self.remove_child(n) 
					n.queue_free() # we need to remove anything else to prevent conflicts
		var newBg
		newBg = bg2.instance()
		self.call_deferred("add_child", newBg)
		aboveGround = false

func _on_Area2D_body_exited(body):
	if body is Player and !aboveGround:
		if self.get_child_count() > 0:  # same for loop as before
			for n in self.get_children():
				if n.name != "CaveZone":
					self.remove_child(n)
					n.queue_free() 
		var newBg
		newBg = bg1.instance()
		self.call_deferred("add_child", newBg)
		aboveGround = true
		print("not above ground")
