extends RigidBody2D

class_name Bullet

export var effect = preload("res://player/BulletPlasmaSplash.tscn")
export var bulletBounce = false
export var oneShot = true
var splashDelay = 0

func _ready():
	($Anim as AnimationPlayer).play("shutdown")

func _physics_process(delta):
	splashDelay += delta

func _on_bullet_body_enter(body):
	print("hit something else")
	if body.has_method("hit_by_bullet"):
		body.call("hit_by_bullet")
		print("Hit enemy")
		if oneShot == true:
			self.queue_free()

	if splashDelay > 0.01:
		var fx = effect.instance()
		fx.position = self.position
		get_parent().add_child(fx) # don't want bullet to move with us, so add it as child of parent
		splashDelay = 0
	if bulletBounce == false:
		_bullet_end()

func _bullet_end():
	queue_free()
