extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 0.0
const WALK_SPEED = 400 # pixels/sec
const JUMP_SPEED = 400
const JUMP_SECOND_SPEED = 220
const SIDING_CHANGE_SPEED = 10
var BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

export (int, 0, 200) var push = 100

var linear_vel = Vector2()
var shoot_time = 99999 # time since last shot
var hittimer = 0 # time since last hit taken
var gethit = false # track if we've been hit

var JUMP_SECOND = false # double jump trigger
var crouch = false # crouch toggle

var anim = "" # stores the current animation

# cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite

## Adding multiple ammo types for different guns ##

# first we need to track which gun is selected
var BulletType = 0 
# then load in our different bullet classes
var Bullet_Plasma = preload("res://player/BulletPlasma.tscn")
var Bullet_Bounce = preload("res://player/BulletBounce.tscn")
var Bullet_Fire = preload("res://player/BulletFire.tscn")
# and our different effects for when the gun fires
var fxboing = preload("res://Effects/FXBoing.tscn")
var fxzap = preload("res://Effects/FXZap.tscn")
var fxpow = preload("res://Effects/FXPow.tscn")
var fxsplat = preload("res://Effects/FXSplat.tscn")
# effect for the jetpack
var fxJetPack = preload("res://Effects/FXJetpack.tscn")

var checkhealth = false

var ammo0 = true # first gun will have infinite ammo, but needs a cooldown
# other ammo types are storred in User_Data.store

func _ready():
	checkhealth = true
	$Camera.current = true

func contact(dam): # when an enemy comes in contact
	if hittimer > 0.5: # set an invulnerable time here
		User_Data.store.health += dam
		if dam > 0:
			checkhealth = true
		if dam < 0:
			gethit = true # track the hit

func _physics_process(delta):
	# Increment counters
	shoot_time += delta
	hittimer += delta
	if shoot_time > User_Data.store.rate: # check against our firerate
		ammo0 = true # set the main gun fireable

	## AMMO DISPLAY ##
	
	if BulletType == 0: # Our first gun is different, as it doesn't use ammo
	# We'll need to check the bool and update if the gun is ready or not
		if ammo0:
			get_node("UI/Current_Gun").set_text(str("Plasma:"))
			get_node("UI/Ammo").set_text(str("Ready!"))
			# TODO change sprite for gun, instead of a label
		if not ammo0:
			get_node("UI/Current_Gun").set_text(str("Plasma:"))
			get_node("UI/Ammo").set_text(str("Overloaded!"))
			# TODO change sprite for gun, instead of a label
	if BulletType == 1:
		if User_Data.store.ammo1 > 0:
			get_node("UI/Current_Gun").set_text(str("Bounce:"))
			get_node("UI/Ammo").set_text(str(User_Data.store.ammo1))
			# TODO change sprite for gun, instead of a label
		if User_Data.store.ammo1 < 1: #if the ammo is empty
			BulletType += 1 # auto change to the next gun
	if BulletType == 2:
		if User_Data.store.ammo2 > 0:
			get_node("UI/Current_Gun").set_text(str("Flame:"))
			get_node("UI/Ammo").set_text(str(User_Data.store.ammo2))
			# TODO change sprite for gun, instead of a label
		if User_Data.store.ammo2 < 1: #if the ammo is empty
			BulletType += 1 # auto change to the next gun
	if BulletType >= 3: # check if we've gone too far
		BulletType = 0 # reset to the main gun

	## Taking Damage ##
	
	if gethit or checkhealth:
		if gethit:
			var ouch
			ouch = fxpow.instance()
			ouch.position = self.position # use node for shoot position
			get_parent().add_child(ouch) # same for the fx
			($SecondAnim as AnimationPlayer).play("hurt")
			hittimer = 0 # reset the timer until we can be damaged again
			gethit = false # end our hit state
			print("Ouch!")
		$"UI/Heart 05".update_health(5) # Let each heart Sprite know what number it is in the UI
		$"UI/Heart 04".update_health(4) 
		$"UI/Heart 03".update_health(3) 
		$"UI/Heart 02".update_health(2) 
		$"UI/Heart 01".update_health(1)
		checkhealth = false
		if User_Data.store.health < 1:
			if User_Data.curVars.difficulty == 0:
				User_Data.store.health = 1
				print("Dev is a cheater") 
			if User_Data.curVars.difficulty > 0:
				Game_Over() # end the game when we are out of health
		if User_Data.store.health > User_Data.store.maxHealth:
			User_Data.store.health = User_Data.store.maxHealth
			print("too much health")
			#User_Data.store.score += 100

	### MOVEMENT ###

	# Apply gravity
	var platformSpeed = get_floor_velocity()
	linear_vel += delta * GRAVITY_VEC
	# Move and slide, disable infinite inertia
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP, 4, PI/4, false)
	# Detect if we are on floor - only works if called *after* move_and_slide
	var on_floor = is_on_floor()
	
	# after calling move_and_slide()
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)

	### CONTROL ###

	# Horizontal movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		if not crouch:
			target_speed -= 1
		#if crouch:
		#	target_speed -= 0.2
	if Input.is_action_pressed("move_right"):
		if not crouch:
			target_speed += 1
		#if crouch:
		#	target_speed += 0.2
	if Input.is_action_just_released("move_down"):
		crouch = false

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor:
		JUMP_SECOND = true
	if on_floor and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED 
	# Double Jump
	if !on_floor and JUMP_SECOND and Input.is_action_just_pressed("jump"):
		var fx = fxJetPack.instance() # calling this a second time instead of creating a function so it could be changed to a different effect later
		fx.position = ($Sprite/Jetpack as Position2D).global_position # use node for effect position
		get_parent().add_child(fx) # reparent jetpack fx so it doesn't follow (may change depending on the effect)
		linear_vel.y = -JUMP_SPEED
		JUMP_SECOND = false
	
	# Crouching
	if on_floor and Input.is_action_pressed("move_down"):
		crouch = true

	# Shooting
	if Input.is_action_just_pressed("change_weapon"):
		BulletType += 1

	if Input.is_action_just_pressed("shoot"):
		if shoot_time > User_Data.store.rate:
			var bullet
			var fx
			# we need to identify which gun is currently selected and load the appropriate 'bullet' object
			if BulletType == 0:
				bullet = Bullet_Plasma.instance()
				ammo0 = false
				fx = fxsplat.instance()
				BULLET_VELOCITY = 900
			if BulletType == 1:
				bullet = Bullet_Bounce.instance()
				User_Data.store.ammo1 -= 1 # reduce ammo count by 1
				fx = fxboing.instance()
				BULLET_VELOCITY = 1000
			if BulletType == 2:
				bullet = Bullet_Fire.instance()
				User_Data.store.ammo2 -= 1 # reduce ammo count by 1
				fx = fxzap.instance()
				BULLET_VELOCITY = 300
			fx.position = ($Sprite/BulletShoot as Position2D).global_position # use node for shoot position
			bullet.position = ($Sprite/BulletShoot as Position2D).global_position # use node for shoot position
			bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
			bullet.add_collision_exception_with(self) # don't want player to collide with bullet
			get_parent().add_child(bullet) # don't want bullet to move with us, so add it as child of parent
			get_parent().add_child(fx) # same for the fx
			shoot_time = 0

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"

		if Input.is_action_pressed("move_down"):
			new_anim = "crouch"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < -100:
			new_anim = "jumping"
		if linear_vel.y > 100:
			new_anim = "falling"

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)
	$UI/Score.set_text(str(User_Data.store.score)) # update score display

func on_player_body_enter(body):
	print("Player touched a thing")
	if body.has_method("touched_by_player"):
		body.call("touched_by_player")
		print("thing was touched")

func Game_Over():
	print("Game Over")
	User_Data.new_game()
	Global.goto_scene("res://MainMenu.tscn")
