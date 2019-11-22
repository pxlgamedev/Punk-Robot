extends KinematicBody2D

class_name EnemyWithWeapon


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const STATE_WALKING = 0
const STATE_KILLED = 1
const WALK_SPEED = 70 

var linear_velocity = Vector2()
var direction = -1
var anim = ""

var fxboom = preload("res://Effects/FXBoom.tscn")
var fxpoint = preload("res://Effects/POINT30.tscn")

# state machine
var state = STATE_WALKING

onready var DetectFloorLeft = $DetectFloorLeft
onready var DetectWallLeft = $DetectWallLeft
onready var DetectFloorRight = $DetectFloorRight
onready var DetectWallRight = $DetectWallRight
onready var sprite = $Sprite

func _physics_process(delta):
	var new_anim = "idle"

	
	if state == STATE_KILLED:
		$CollisionShape2D.disabled = true
		$DamageRange.monitoring = false

	if state == STATE_WALKING:
		linear_velocity += GRAVITY_VEC * delta
		linear_velocity.x = direction * WALK_SPEED
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)

		if not DetectFloorLeft.is_colliding() or DetectWallLeft.is_colliding():
			direction = 1.0

		if not DetectFloorRight.is_colliding() or DetectWallRight.is_colliding():
			direction = -1.0

		sprite.scale = Vector2(direction, 1.0)
		new_anim = "walk"
	else:
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)

func hit_by_bullet():
	if state != STATE_KILLED:
		User_Data.store.score += 30
		var fx
		var fxP
		fx = fxboom.instance()
		fxP = fxpoint.instance()
		fx.position = ($Sprite/Explosion as Position2D).global_position # use node for shoot position
		fxP.position = ($Sprite/Explosion as Position2D).global_position # use node for shoot position
		get_parent().add_child(fx) # 
		get_parent().add_child(fxP) # 
		state = STATE_KILLED

func _on_Enemy_body_entered(body):
	if body is Player:
		if body.has_method("contact"):
			body.contact(-1)
