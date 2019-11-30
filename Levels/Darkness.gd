extends Light2D

#### There is still an issue where lighting occasionally does not render over the darkness mask ###
#### The exact cause is unknown, I assumed it was something to do with load order.
#### It currently only happens after reloading the main level a couple times.
#### It will be a bigger problem when there are more levels to deal with. 

func _ready():
	self.call_deferred("my_debug")

func my_debug():
	self.enabled = true
	