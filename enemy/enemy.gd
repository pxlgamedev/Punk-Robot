extends KinematicBody2D

class_name Enemy

export var staticStart = true # if true the enemy won't be active until they enter the camera
export var attack = false # does it attack player? NOT IMPLIMENTED
export var attackDelay = 1 # NOT IMPLIMENTED
export var isHardOnly = false # if true it will queue_free on easy

export var flying = false # if false, walking logic is used, if true flight logic is used
export var flightRange = Vector2(-300,0) # the distance from origin for the enemy to patrol
export var fSpeed = 4 # Time it takes to patrol
export var wSpeed = 40 # Land speed of a coconut layden swallow

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const STATE_WALKING = 0
const STATE_KILLED = 1
const STATE_FLYING = 2
const STATE_RETURNING = 3

# state machine
var state = STATE_WALKING
var respawn = false # if true the enemy will 'respawn' when entering the camera
var spawnPoint = Vector2(0,0) # for storing this enemy's starting position

var linear_velocity = Vector2()
var direction = -1
var anim = ""

var fxboom = preload("res://Effects/FXBoom.tscn")
var fxpoint = preload("res://Effects/POINT30.tscn")

var givePoints = true # disabled when the enemy respawns on hard mode

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
	if isHardOnly and User_Data.curVars.difficulty == 1: # On easy mode, if isHardOnly is true
		self.call_deferred("queue_free") # delete
	if User_Data.curVars.difficulty == 3: # on hard mode
		respawn = true # Ememies will respawn as soon as they reenter the camera
		staticStart = false # enemies will spawn at game start and begin their patrols

func patrol(target):
	if state != STATE_KILLED:
		tween.stop_all() # stop any current flight
		# start movement from current position to target position
		tween.interpolate_property(self, "position", null, target, fSpeed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()

func _physics_process(delta):
	var new_anim = "idle" # Animation singleton
	if state == STATE_KILLED:
		$CollisionShape2D.disabled = true # prevent interactions with player or bullets
		$DamageRange.monitoring = false # prevent further damage to the player
		new_anim = "explode" # death animation
	var target = spawnPoint # prepare the vector2 for patrol target 
	target += flightRange # update the distance for the patrol
	if state == STATE_WALKING:
		if !flying: # activate walk logic
			linear_velocity += GRAVITY_VEC * delta # add gravity
			linear_velocity.x = direction * wSpeed # add movement velocity
			linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL) # apply movement
		if flying: # activate flight logic
			patrol(target) # activate patrol
			state = STATE_FLYING # change state
		new_anim = "walk" # we use the same animation whether flying or walking, just with different sprites
	if state == STATE_WALKING: # if the walking state hasn't been changed
		if not DetectFloorLeft.is_colliding() or DetectWallLeft.is_colliding(): # check for walls/edges
			direction = 1.0 
		if not DetectFloorRight.is_colliding() or DetectWallRight.is_colliding():
			direction = -1.0
	if state == STATE_FLYING: # if we contact anything in the flight path 
		if DetectFloorLeft.is_colliding() or DetectWallLeft.is_colliding():
			patrol(spawnPoint) # change direction back to spawn
			state = STATE_RETURNING
	if state == STATE_RETURNING: # if we contact anything on the return path
		if DetectFloorRight.is_colliding() or DetectWallRight.is_colliding():
			patrol(target) # change direction back to target
			state = STATE_FLYING

	if state == STATE_FLYING: # if we're still flying
		new_anim = "walk" 
		direction = -1.0 # set direction
		if self.position == spawnPoint + flightRange: # check if we've reached the target
			patrol(spawnPoint) # start a new patrol back to the spawn point
			state = STATE_RETURNING
	if state == STATE_RETURNING: # If we are returning
		new_anim = "walk"
		direction = 1.0 # set direction
		if self.position.x == spawnPoint.x: # if we've reached the spawn point
			state = STATE_WALKING # back to flying
	sprite.scale = Vector2(direction, 1.0) # change the sprite scale according to direction

	if anim != new_anim: # if the animation var has changed
		anim = new_anim # update animation
		($Anim as AnimationPlayer).play(anim) # play animation

func hit_by_bullet(): # triggered by the bullet
	if state != STATE_KILLED: # if still alive
		var fx
		fx = fxboom.instance() # create the death effect
		fx.position = ($Sprite/Explosion as Position2D).global_position # use node for explosion position
		get_parent().add_child(fx) # reparent it so it doesn't follow the enemy
		if respawn == false: # if enemy has not been killed before
			var fxP
			fxP = fxpoint.instance() # create a point effect
			fxP.position = ($Sprite/Explosion as Position2D).global_position # use node for explosion position
			get_parent().add_child(fxP) # reparent it so it doesn't follow the enemy
		state = STATE_KILLED

func _on_Enemy_body_entered(body):
	if body is Player:
		if body.has_method("contact"):
			body.contact(-1) # damage the player
			### can be updated to use a var and deal more damage ###

func _on_Spawner_screen_entered():
	if respawn and state == STATE_KILLED: # only if we are respawning an already dead enemy
		$CollisionShape2D.disabled = false # re-enable collision
		$DamageRange.monitoring = true # re-enable damage monitoring
		self.position = spawnPoint # reset to spawn point
		### TODO this causes the enemy to apear sudenly in cases where the spawn point is center screen
		state = STATE_WALKING

	if staticStart and state == STATE_KILLED:
		# if static start is enabled, the movement logic will only now activate
		state = STATE_WALKING

func _on_Spawner_screen_exited():
	pass # Unused at this time

func _dead(): # triggered by the animation player
	if givePoints:
		User_Data.store.score += 30 # can be replaced by an export var
		givePoints = false # in case respawn is active, this prevents an infinite score exploit
	if !respawn: # if not respawning
		state = STATE_KILLED
		if tween != null: # if there is a tween object
			tween.stop_all() # end all movement
		call_deferred("queue_free") # delete at end of process
	if respawn: # if we are going to respawn
		state = STATE_KILLED
		self.position = spawnPoint # return to the spawn point
