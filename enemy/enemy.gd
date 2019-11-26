extends KinematicBody2D

class_name Enemy

export var staticStart = true # if true the enemy won't be active until they enter the camera
export var attack = false
export var attackDelay = 1
export var isHardOnly = false

export var flying = false
export var flightRange = Vector2(-300,0)
export var fSpeed = 4
export var wSpeed = 40

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const STATE_WALKING = 0
const STATE_KILLED = 1
const STATE_FLYING = 2
const STATE_RETURNING = 3

# state machine
var state = STATE_WALKING
var respawn = false # if true the enemy will respawn when entering the camera
var spawnPoint = Vector2(0,0) # for storing this enemy's starting position

var linear_velocity = Vector2()
var direction = -1
var anim = ""

var fxboom = preload("res://Effects/FXBoom.tscn")
var fxpoint = preload("res://Effects/POINT30.tscn")

var givePoints = true

onready var tween = $Tween

onready var DetectFloorLeft = $DetectFloorLeft
onready var DetectWallLeft = $DetectWallLeft
onready var DetectFloorRight = $DetectFloorRight
onready var DetectWallRight = $DetectWallRight
onready var sprite = $Sprite

func _ready():
	respawn = false
	spawnPoint = self.position # store the initial position
	if staticStart == true: # if we want enemy positions to be dynamic, set false
		state = STATE_KILLED
	if isHardOnly and User_Data.curVars.difficulty == 1: # On easy mode
		self.call_deferred("queue_free") # delete
	if User_Data.curVars.difficulty == 3: #on impossible mode
		respawn = true # Ememies will respawn as soon as they reenter the camera
		staticStart = false # enemies will spawn at game start and begin their patrols

func patrol(target):
	if state != STATE_KILLED:
		tween.stop_all()
		tween.interpolate_property(self, "position", null, target, fSpeed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()

func _physics_process(delta):
	var new_anim = "idle"
	if state == STATE_KILLED:
		$CollisionShape2D.disabled = true
		$DamageRange.monitoring = false
		new_anim = "explode"
	var target = spawnPoint
	target += flightRange
	if state == STATE_WALKING:
		if !flying:
			linear_velocity += GRAVITY_VEC * delta
			linear_velocity.x = direction * wSpeed
			linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		if flying:
			patrol(target)
			state = STATE_FLYING
		new_anim = "walk"
	if state == STATE_WALKING:
		if not DetectFloorLeft.is_colliding() or DetectWallLeft.is_colliding():
			direction = 1.0
		if not DetectFloorRight.is_colliding() or DetectWallRight.is_colliding():
			direction = -1.0
	if state == STATE_FLYING: 
		if DetectFloorLeft.is_colliding() or DetectWallLeft.is_colliding():
			patrol(spawnPoint)
			state = STATE_RETURNING
	if state == STATE_RETURNING:
		if DetectFloorRight.is_colliding() or DetectWallRight.is_colliding():
			patrol(target)
			state = STATE_FLYING

	if state == STATE_FLYING:
		new_anim = "walk"
		direction = -1.0
		if self.position == spawnPoint + flightRange:
			patrol(spawnPoint)
			state = STATE_RETURNING
	if state == STATE_RETURNING:
		new_anim = "walk"
		direction = 1.0
		if self.position.x == spawnPoint.x:
			state = STATE_WALKING
	sprite.scale = Vector2(direction, 1.0)

	if anim != new_anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)

func hit_by_bullet():
	if state != STATE_KILLED:
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

func _on_Spawner_screen_entered():
	if respawn and state == STATE_KILLED:
		$CollisionShape2D.disabled = false
		$DamageRange.monitoring = true
		self.position = spawnPoint
		state = STATE_WALKING

	if staticStart and state == STATE_KILLED:
		state = STATE_WALKING

func _on_Spawner_screen_exited():
	pass # Replace with function body.
	
func dead():
	if givePoints:
		User_Data.store.score += 30
		givePoints = false
	if !respawn:
		state = STATE_KILLED
		tween.stop_all()
		call_deferred("queue_free")
	if respawn:
		state = STATE_KILLED
		self.position = spawnPoint
