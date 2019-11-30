extends RigidBody2D

#####################################
#### The Collectable item script ####
#####################################

class_name Coin

var taken = false
export var value = "Score" # Score, Health, FireRate, AmmoBounce, AmmoFire
export var points = 10 # how much to incriment the value by
export var effect = preload("res://Effects/POINT10.tscn") # What effect to trigger
export var isEasyOnly = false # if true, it will only be availible on easy mode

func _ready():
	$Sprite/Light2D.enabled = false # For improved performance, all lights are dissabled unless onscreen
	if isEasyOnly and User_Data.curVars.difficulty > 1: # If higher difficulty, and isEasyOnly is true
		self.queue_free() # delete self
		### This allows extra hearts, ammo, fire reate, etc on easy ###

func _on_coin_body_enter(body): # Triggered by the area2d
	if not taken and body is Player:
		($Anim as AnimationPlayer).play("taken") # play animation
		var fx
		fx = effect.instance() # instantiate the effect
		fx.position = ($Sprite/FXLocation as Position2D).global_position # use node for effect position
		get_parent().add_child(fx) # keep the effect from being deleted with the coin
		taken = true # set singleton
		## now we'll check against our expossed variables ##
		if value == "Score":
			User_Data.store.score += points # add the points to the score
			## we are going to update seperate variables for the collectable counters ##
			if points == 10: # based on point value
				User_Data.curVars.gemY += 1 # update the appropriate collectable counter
			if points == 20:
				User_Data.curVars.gemB += 1
			if points == 30:
				User_Data.curVars.gemG += 1
			if points == 50:
				User_Data.curVars.gemR += 1
		if value == "Health":
			body.contact(points) # send the point value to the player, a positive number will be added to health
			User_Data.curVars.hearts += 1 # Update the collectable counter
		if value == "FireRate":
			User_Data.store.rate -= 0.04 # increase the rate of fire
			## not currently a counted collectable
		if value == "AmmoBounce":
			User_Data.store.ammo1 += points # increase the current ammo count
			## not currently a counted collectable
		if value == "AmmoFire":
			User_Data.store.ammo2 += points # increase the current ammo count
			## not currently a counted collectable
	if not taken: # if contact was not the player
		gravity_scale = 1 # enable gravity
		mass = 1 # add weight

func _on_VisibilityEnabler2D_screen_entered():
	$Sprite/Light2D.enabled = true # turn the light on

func _on_VisibilityEnabler2D_screen_exited():
	$Sprite/Light2D.enabled = false # turn the light off to preserve performance

func _clear(): # activated by the animation player
	self.queue_free()
