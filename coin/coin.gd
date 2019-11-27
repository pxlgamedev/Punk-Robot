extends RigidBody2D

class_name Coin

var taken = false
export var value = "Score" # Score, Health, FireRate, AmmoBounce
export var points = 10
export var effect = preload("res://Effects/POINT10.tscn")
export var isEasyOnly = false # it will only be availible on easy mode

func _ready():
	if isEasyOnly and User_Data.curVars.difficulty > 1:
		$Sprite/Light2D.enabled = false
		self.queue_free()

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
			if points == 10:
				User_Data.curVars.gemY += 1
			if points == 20:
				User_Data.curVars.gemB += 1
			if points == 30:
				User_Data.curVars.gemG += 1
			if points == 50:
				User_Data.curVars.gemR += 1
		if value == "Health":
			body.contact(points)
			if points == 1:
				User_Data.curVars.hearts += 1
		if value == "FireRate":
			User_Data.store.rate -= 0.01
		if value == "AmmoBounce":
			User_Data.store.ammo1 += points
	if not taken:
		gravity_scale = 1
		mass = 1

func _on_VisibilityEnabler2D_screen_entered():
	$Sprite/Light2D.enabled = true

func _on_VisibilityEnabler2D_screen_exited():
	$Sprite/Light2D.enabled = false
