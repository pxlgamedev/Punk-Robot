extends Sprite

var state = 5 # state machine
var anim = "" # string for tracking the animation state
var heartnum = 0 # used to identify which heart symbol this sprite is

func update_health(num): # the number sent from the player object, identifies which heart we are
	heartnum = num # ubdate what number we are

func _physics_process(delta):
	var new_anim = "Glowing" # for setting our new animation state, start with the default animation
	
	if heartnum > User_Data.store.health: #if the current heart number is higher than player health
		if self.visible == true: # if this heart is still visible
			self.visible = false # turn the sprite off
	if heartnum <= User_Data.store.health: #if the current heart number is lower than player health
		if self.visible == false: # if this heart is not currently visible
			self.visible = true # become visible
		state = 5 # default our state to healthy
		if heartnum <= 3 and User_Data.store.health == 3: # if this is heart 1, 2, or 3 and health is 3
			state = 3 # set state to damaged
		if heartnum <= 2 and User_Data.store.health == 2: # if this is heart 1, or 2 and health is 2
			state = 2 # set state to low health
		if heartnum <= 1 and User_Data.store.health == 1: # if this is heart 1 and health is 1
			state = 1 # set state to near death
	
	if state == 5: # if healthy
		new_anim = "Glowing" # default animation
	if state == 3: # if damaged
		new_anim = "Damaged" # damaged animation
	if state == 2: # if low health
		new_anim = "LowHealth" # low health animation
	if state == 1: # if state is near death
		new_anim = "NearDeath" # near death animation
	
	if anim != new_anim: # check if our animation state has changed since the last run
		$AnimationPlayer.play(new_anim) # set the new animation
		anim = new_anim # set our current animation state
