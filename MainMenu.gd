extends Node2D

class_name Menu

## export some variables that can be accessed by a Tween object ##
## we'll use these to "count" our score and collectables at the end of the level ##
export var scoreCount = 0
export var gemY = 0
export var gemB = 0
export var gemG = 0
export var gemR = 0
export var hearts = 0

var quitgame = 0 # singleton for closing the game

## store some nodes for frequent use ##
onready var tween = get_node("BgLayer/Tween") # The brute force worker for smoothly animating positions
onready var frame = get_node("Page") # The main node for our Comic style menu
##  We will need to manually update the scroll on each parallax backgrounds  ##
onready var bg0 = get_node("BgLayer/Title/GalaxyBG")
onready var bg1 = get_node("BgLayer/Panel1/PurpleBg")
onready var bg2 = get_node("BgLayer/Panel2/CaveBg")

## Here we'll keep a list of vectors for the positions of each Comic panel in the main scene ##
## Moving the scene, and it's contained sprites, instead of moving the camera ##
## To avoid issues with the parallax backgrounds and a moving camera ##
var Page = {
	intro1 = Vector2(1920,540),
	intro2 = Vector2(960, 540),
	intro3 = Vector2(1920,0),
	intro4 = Vector2(960,0),
	startLevel = Vector2(-960,0),
	p0 = Vector2(0,540), # Controls page
	p1 = Vector2(0,0), # Main difficulty select screen
	p2 = Vector2(0,-540), # Options screen
	p3 = Vector2(0, -1080), ### not currently used ###
	p4 = Vector2(-960, -540) # Score page
	}

var intro = 0 # Singleton for the intro screen
var recap = 0 # Singleton for the points recap screen
var recapTimer = 0 # Timer for blocking input on the recap screen
var world1 = preload("res://Stage00.tscn") ## Preload the main level ##
var world1_2 = preload("res://Stage00.tscn") ## To be expanded for future levels
var nextLevel = "" # String for updating the level to load, if empty main menu will be reloaded

func _ready():
	frame.position = Page.intro1 # Start at the first page of the intro

func change_panel(panel): # for changing the current comic panel, recieves Vector2 coords
	tween.stop_all() # make sure nothing else is still moving the scene
	## here we'll use a Tween node to smoothly move the comic from it's current position, to the 'panel' position
	tween.interpolate_property(frame, "position", null, panel, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	if Input.is_mouse_button_pressed(1):
		# we'll move an animated sprite around where the mouse was clicked
		($CanvasLayer/AnimationPlayer as AnimationPlayer).play("MouseClick")
		var fx = $CanvasLayer/Effect
		fx.position = get_viewport().get_mouse_position()
	tween.start() # activate the Tween node

func _world_one_start(diff): # starting the game, recieves an INT, 1 easy, 2 medium, 3 hard
	User_Data.curVars.difficulty = diff # set the difficulty 
	recap = 0 # reset the score counter page
	var newLevel
	newLevel = world1.instance()
	if $Stage.get_child_count() > 0: # we need to check if a level already exists
		for n in $Stage.get_children(): # names won't work, just access all children of the Stage viewport
			$Stage.remove_child(n)
			n.queue_free() # we need to close the level to prevent conflicts
	$Stage.call_deferred("add_child", newLevel) # we need to defer reparenting, to prevent conflicts 
	
	change_panel(Page.startLevel) # move the comic page to the startLevel
	User_Data.new_game() # reset variables for a new game
	get_tree().paused = false # make sure the game is unpaused
	$Music.stream_paused = true # pause the main menu music, the level music will now play when paused
	disable_gui(true) # disable the menu buttons so keyboard input doesn't conflict
	# reset our collectable counters
	User_Data.curVars.gemY = 0
	User_Data.curVars.gemB = 0
	User_Data.curVars.gemG = 0
	User_Data.curVars.gemR = 0
	User_Data.curVars.hearts = 0
	if diff == 3: # if hardmode
		User_Data.store.maxHealth = 1 # set max health to 1 heart

func _next_level(next): # load the next level, recieves a string
	var newLevel = (world1_2).instance() ## TODO update how this functions once there are more levels
	if $Stage.get_child_count() > 0: # we need to check if a level already exists
		for n in $Stage.get_children():
			$Stage.remove_child(n)
			n.queue_free()  # we need to close it to prevent conflicts
	$Stage.call_deferred("add_child", newLevel) # we need to defer reparenting to prevent the new level from getting re-named

func _physics_process(delta):
	bg1.scroll_offset.x -= 10 # infinite scroll the parallax backgrounds
	bg2.scroll_offset.x -= 10
	bg0.scroll_offset.x = $Page.position.x # move the title background with the camera
	recapTimer += 1 # start counting
	
	### Intro control here, press space, controller A/X, or click mouse to move to the next frame ###
	if intro < 10: 
		if Input.is_action_just_pressed("quitgame"):
			intro = 10 # end the intro
			tween.stop_all() # stop all other movement of the comic
			## skip everything and move to the difficulty select page ##
			tween.interpolate_property(frame, "position", null, Page.p1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("Mouse 1"):
			## here we'll set our movement information for each panel of the intro comic ##
			if intro == 0:
				tween.stop_all() # stop all other movement of the comic
				tween.interpolate_property(frame, "position", Page.intro1, Page.intro2, 4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			if intro == 1:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.intro3, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			if intro == 2:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.intro4, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			if intro == 3:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.p1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			intro += 1 # update the current intro page
		tween.start() # activate the Tween node
	if Input.is_action_just_pressed("quitgame"): # for accessing the menu from in game
		print(recap)
		if get_tree().paused == true and recap == 0:  # check if already paused, and not on the score page
			if get_tree().get_root().get_node("Menu/Stage/").get_child_count() > 0:
				get_tree().paused = false # unpause
				change_panel(Page.startLevel) # move the comic back to the level panel
				disable_gui(true) # disable the menu buttons to prevent keyboard conflicts
				$Music.stream_paused = true # pause the menu music
				return # don't run anything past this point
		if get_tree().paused == false and recap == 0: # if we are not paused
			if get_tree().get_root().get_node("Menu/Stage/").get_child_count() > 0: # check if a level even exists
				get_tree().paused = true # pause the game
				change_panel(Page.p1) # move the comic to the difficulty select page
				disable_gui(false) # enable the menu buttons
				$Music.stream_paused = true # keep the menu paused ( could change to pause the level music)
				return # don't run anything past this point
		if recap > 0 and recapTimer > 300: # if we are on the score page
			if recap == 2:
				change_panel(Page.startLevel) # move the comic page to the startLevel
				# $Music.stream_paused = true
				get_tree().paused = false # make sure the game is unpaused
				$Music.stream_paused = true # pause the main menu music, the level music will now play when paused
				disable_gui(true) # disable the menu buttons so keyboard input doesn't conflict
				# reset our collectable counters
				User_Data.curVars.gemY = 0
				User_Data.curVars.gemB = 0
				User_Data.curVars.gemG = 0
				User_Data.curVars.gemR = 0
				User_Data.curVars.hearts = 0
			if recap == 1:
				User_Data.new_game() # new game data
				Global.goto_scene("res://MainMenu.tscn") # reload the whole game  
			recap = 0 # reset the score page                                                                                                                                                                                                                                                nnujjbjnjjjjjjjjn        
	## update the score counter page ##
	if recap > 0:
		# set the text value of each object with it's corrisponding local int, local ints are updated via end_level()
		$Page/Panel4/TotalScore.set_text(str(int(scoreCount)))
		$Page/Panel4/GemY.set_text(str(int(gemY)))
		$Page/Panel4/GemB.set_text(str(int(gemB)))
		$Page/Panel4/GemG.set_text(str(int(gemG)))
		$Page/Panel4/GemR.set_text(str(int(gemR)))
		$Page/Panel4/Hearts.set_text(str(int(hearts)))
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("Mouse 1"):
			if recapTimer > 300: # Prevent accidental skipping by locking the controls with a timer
				if recap == 2: # if 2 we are going to load a new level after the recap
					change_panel(Page.startLevel) # move the comic page to the startLevel
					# $Music.stream_paused = true
					get_tree().paused = false # make sure the game is unpaused
					disable_gui(true) # disable the menu buttons so keyboard input doesn't conflict
					# reset our collectable counters
					User_Data.curVars.gemY = 0
					User_Data.curVars.gemB = 0
					User_Data.curVars.gemG = 0
					User_Data.curVars.gemR = 0
					User_Data.curVars.hearts = 0
				if recap == 1: # if 1 we are going to reset the whole game
					User_Data.new_game() # redundant, but just to be sure score is properly reset
					intro = 1
					Global.goto_scene("res://MainMenu.tscn")
				recap = 0 # reset the score page

func disable_gui(inp):
	# disable keyboard input for menu buttons while the game is running, recieves bool
	$Page/TitleCard/ButtonExit.disabled = inp
	$Page/Panel1/ButtonEasy.disabled = inp
	$Page/Panel1/ButtonMedium.disabled = inp
	$Page/Panel1/ButtonHard.disabled = inp
	$Page/Panel1/ButtonOptions.disabled = inp
	$Page/Panel1/ButtonControls.disabled = inp
	$Page/Panel1/ButtonBack.disabled = inp
	$Page/Panel3/ButtonReturn.disabled = inp
	$Page/Panel0/ButtonReturn.disabled = inp

func end_level(level):
	recapTimer = 0
	change_panel(Page.p4)
	get_tree().paused = true
	disable_gui(false)
	## Here we'll use a Tween object to "count" our score and collectables ##
	tween.interpolate_property(self, "gemY", 0, User_Data.curVars.gemY, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "gemB", 0, User_Data.curVars.gemB, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "gemG", 0, User_Data.curVars.gemG, 2.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "gemR", 0, User_Data.curVars.gemR, 3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "hearts", 0, User_Data.curVars.hearts, 3.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "scoreCount", 0, User_Data.store.score, 5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	recap = 1
	if level != "":
		recap = 2
		_next_level(level)
	tween.start()

#############################
### Main Menu Gui Buttons ###
#############################

func return_to_main():
	change_panel(Page.p1)

func _open_menu():
	if get_tree().paused == false:
		get_tree().paused = true
		change_panel(Page.p1)
		disable_gui(false)

func _close_menu():
	if get_tree().paused == true:
		get_tree().paused = false
		change_panel(Page.startLevel)
		disable_gui(true)

func exit_button():
	var exit = 1
	if exit != quitgame:
		quitgame = 1
		$CanvasLayer/Timer.start() # Use a timer so the mouse animation has time to play
		($CanvasLayer/AnimationPlayer as AnimationPlayer).play("MouseClick")
		$CanvasLayer/Effect.position = get_viewport().get_mouse_position()

func _on_Timer_timeout():
	if quitgame == 1:
		get_tree().quit()
		return

func back_to_title_button():
	intro = 0
	frame.position = Page.intro1

func options():
	change_panel(Page.p2)

func controls():
	change_panel(Page.p0)

func _easy_start():
	_world_one_start(1)

func _med_start():
	_world_one_start(2)

func _hard_start():
	_world_one_start(3)
