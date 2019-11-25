extends Area2D

class_name LevelGoal

var taken = false
var fxzap = preload("res://Effects/FXZap.tscn")

export var nextLevel = "" # if blank game will return to menu

func _on_coin_body_enter(body):
	if not taken and body is Player:
		($Anim as AnimationPlayer).play("taken")
		var fx
		fx = fxzap.instance()
		fx.position = ($Sprite/FXLocation as Position2D).global_position # use node for shoot position
		get_parent().add_child(fx) # 
		taken = true
		get_tree().get_root().get_node("Menu").end_level(nextLevel)
