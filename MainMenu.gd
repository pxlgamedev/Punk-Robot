extends Node2D

class_name Menu

var openscene = ""
onready var tween = get_node("BgLayer/Tween")
onready var frame = get_node("Page")
onready var bg1 = get_node("BgLayer/Panel1/PurpleBg")
onready var bg2 = get_node("BgLayer/Panel2/IcyBg")
var Page = {
	intro1 = Vector2(1920,540),
	intro2 = Vector2(960, 540),
	intro3 = Vector2(1920,0),
	intro4 = Vector2(960,0),
	startLevel = Vector2(-960,0),
	p0 = Vector2(960,0),
	p1 = Vector2(0,0),
	p2 = Vector2(0,-540),
	p3 = Vector2(0, -1080)
	}

var intro = 0
var world1 = preload("res://Stage00.tscn")
var world1_2 = preload("res://Stage00.tscn")

func _ready():
	_intro()

func _intro():
	tween.interpolate_property(frame, "position", Page.intro1, Page.intro2, 4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func change_panel(panel):
	tween.stop_all()
	tween.interpolate_property(frame, "position", null, panel, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	if Input.is_mouse_button_pressed(1):
		($CanvasLayer/AnimationPlayer as AnimationPlayer).play("MouseClick")
		var fx = $CanvasLayer/Effect
		fx.position = get_viewport().get_mouse_position()
	tween.start()

func _world_one_start():
	var newLevel
	newLevel = world1.instance()
	if $Stage.get_child_count() > 0:
		#var n
		for n in $Stage.get_children():
			$Stage.remove_child(n)
			n.queue_free()
	$Stage.call_deferred("add_child", newLevel)
	change_panel(Page.startLevel)
	User_Data.new_game()
	get_tree().paused = false
	$Music.stream_paused = true
	disable_gui(true)

func _next_level(next):
	if get_tree().get_root().get_node("Menu/Stage/Stage"):
		var newLevel = (world1_2).instance()
		if $Stage.get_child_count() > 0:
			var n
			for n in $Stage.get_children():
				$Stage.remove_child(n)
				n.queue_free()
		$Stage.call_deferred("add_child", newLevel)
		change_panel(Page.startLevel)

func _physics_process(delta):
	bg1.scroll_offset.x -= 10
	bg2.scroll_offset.x -= 10
	
	### Intro control here, press space or click mouse to move to the next frame ###
	if intro < 10:
		if Input.is_action_just_pressed("quitgame"):
			intro = 10
			tween.stop_all()
			tween.interpolate_property(frame, "position", null, Page.p1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("Mouse 1"):
			if intro == 0:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.intro3, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			if intro == 1:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.intro4, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			if intro == 2:
				tween.stop_all()
				tween.interpolate_property(frame, "position", null, Page.p1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			intro += 1
		tween.start()
	if Input.is_action_just_pressed("quitgame"): # TODO add ingame menu
		#Global.goto_scene("res://MainMenu.tscn")
		if get_tree().paused == true:
			get_tree().paused = false
			change_panel(Page.startLevel)
			disable_gui(true)
			return
		if get_tree().paused == false:
			if get_tree().get_root().get_node("Menu/Stage/").get_child_count() > 0:
				get_tree().paused = true
				change_panel(Page.p1)
				disable_gui(false)
				return

func disable_gui(inp):
	$Page/TitleCard/ButtonExit.disabled = inp
	$Page/Panel1/ButtonNewGame.disabled = inp
	$Page/Panel1/ButtonBack.disabled = inp
	$Page/Panel1/ButtonOptions.disabled = inp
	$Page/Panel3/ButtonReturn.disabled = inp

func return_to_main():
	change_panel(Page.p1)

func options():
	change_panel(Page.p2)

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
	var newscene = "quit"
	if newscene != openscene:
		openscene ="quit"
		$CanvasLayer/Timer.start()
		($CanvasLayer/AnimationPlayer as AnimationPlayer).play("MouseClick")
		$CanvasLayer/Effect.position = get_viewport().get_mouse_position()

func _on_Timer_timeout():
	if openscene == "quit":
		get_tree().quit()
		return

func back_to_title_button():
	change_panel(Page.intro1)
	intro = 0
	_intro()
