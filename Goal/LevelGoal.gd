extends Area2D

class_name LevelGoal

#############################################################
### A collectable item that triggers the end of the level ###
#############################################################

var taken = false
var fxzap = preload("res://Effects/FXZap.tscn") # Completely unnecisary, only visible in debug mode

export var nextLevel = "" # if blank game will return to menu

func _on_coin_body_enter(body):
	if not taken and body is Player:
		($Anim as AnimationPlayer).play("taken")
		var fx
		fx = fxzap.instance()
		fx.position = ($Sprite/FXLocation as Position2D).global_position # use node for shoot position
		get_parent().add_child(fx) # 
		taken = true
		######################################
		### The only function that matters ###
		######################################
		if get_tree().get_root().get_node("Menu"): # if the menu exists
			get_tree().get_root().get_node("Menu").end_level(nextLevel) # trigger the score recap page
		# if the menu doesn't exist, the game remains in debug mode and the level won't end
