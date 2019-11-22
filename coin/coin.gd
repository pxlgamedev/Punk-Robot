extends RigidBody2D

class_name Coin

var taken = false
export var value = "Score" # Score, Health, FireRate, AmmoBounce
export var points = 10
export var effect = preload("res://Effects/POINT10.tscn")

func _ready():
	$Sprite/Light2D.enabled = false
	$Sprite/Light2D.enabled = true

func _on_coin_body_enter(body):
	if not taken and body is Player:
		($Anim as AnimationPlayer).play("taken")
		var fx
		fx = effect.instance()
		fx.position = ($Sprite/FXLocation as Position2D).global_position # use node for shoot position
		get_parent().add_child(fx) # 
		taken = true
		if value == "Score":
			User_Data.store.score += points
		if value == "Health":
			body.contact(points)
		if value == "FireRate":
			User_Data.store.rate -= 0.01
		if value == "AmmoBounce":
			User_Data.store.ammo1 += points
	if not taken:
		gravity_scale = 1
		mass = 1
