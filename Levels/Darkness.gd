extends Light2D

func _ready():
	self.call_deferred("my_debug")

func my_debug():
	self.enabled = true
