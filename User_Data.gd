extends Node

### An uber basic game data controller ###
### Built for keeping a handful of variables between levels ###
### Set this script to AutoLoad in Project Settings ###

# all variables we want to keep between levels can be stored in a dicitonary
# access them from anywhere with User_Data.store.[YourVariable]
# we can also back up the entire dictionary in one go

var store = {
	# you can add as many variables as you want here, they will all be saved
	level = 1,
	score = 0,
	health = 5,
	maxHealth = 5,
	lives = 3,
	rate = 0.55,
	ammo1 = 1,
	ammo2 = 20
	}

# here we're going to store prefferences seperately into an ini file, things like volume or control settings
var prefs = {
	# changes here need to be manually saved to prevent them from being overwritten at game start
	playername = "",
	volume = -1000,
	fxvolume = 1, # TODO need to setup a seperate bus for effect sounds
	HStotal = 0,
	HSlevel0 = 0
	}

func _ready():
	# load the ini file
	load_settings()
	# apply the user prefferences
	apply_settings()
	# check at the start if a Saves directory exists in the user folder
	#TODO for testing purposed we are using res://saves
	var dir = Directory.new()
	if !dir.dir_exists("user://Saves"):
		# if not we'll create it.
		dir.open("user://")
		dir.make_dir("user://Saves")

# we'll setup quicksave and quickload buttons here:
func _physics_process(delta):
	if Input.is_action_just_pressed("qsave"):
		# Trigger the save function with the filename we want for our save
		save_game_state("QuickSave")
	if Input.is_action_just_pressed("qload"):
		# trigger the load function with the correct filename 
		load_game_state("QuickSave")

# this is our save function, it creates a json file with our data
func save_game_state(var saveName):
	# create a file object
	var saveGame = File.new()
	# create our save location
	saveGame.open("res://Saves/"+saveName+".sve", File.WRITE)
	# write the data to disk
	saveGame.store_line(to_json(store))
	# close the file
	saveGame.close()
	# done

# this function loads the previously saved variables as text
# converts the text, and replaces all variables in our data store
func load_game_state(var saveName):
	# create a file object
	var loadGame = File.new()
	# check that the file exists before trying to open it
	if !loadGame.file_exists("res://Saves/"+saveName+".sve"):
		print ("Abort! Abort! No file found...")
		return
	# time to read the data in our file
	loadGame.open("res://Saves/"+saveName+".sve", File.READ)
	# now simply overwrite store by parsing the loaded data
	store = parse_json(loadGame.get_line())
	loadGame.close()
	#Done!

func save_settings():
	# here we're doing exactly the same thing again, but saving the prefs to an ini file
	var savePrefs = File.new()
	# create our save location
	savePrefs.open("res://prefs.ini", File.WRITE)
	# write the data to disk
	savePrefs.store_line(to_json(prefs))
	# close the file
	savePrefs.close()
	# done

func load_settings():
	# create a file object
	var loadPrefs = File.new()
	# check that the file exists before trying to open it
	if !loadPrefs.file_exists("res://prefs.ini"):
		print ("Abort! Abort! No file found...")
		return
	# time to read the data in our file
	loadPrefs.open("res://prefs.ini", File.READ)
	# now simply overwrite store by parsing the loaded data
	prefs = parse_json(loadPrefs.get_line())
	loadPrefs.close()
	#Done!
	# DEBUG stuff:
	print("Loaded data: ", prefs)

func apply_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), prefs.volume)

# this function is for resetting your variables for a new game
func new_game():
	# use the same load functions to restore our variables from a premade file
	# file can be created as a save and renamed
	# create a file object
	var loadInit = File.new()
	# check that the file exists before trying to open it
	if !loadInit.file_exists("res://player/ng.data"):
		print ("Abort! Abort! No file found...")
		return
	# time to read the data in our file
	loadInit.open("res://player/ng.data", File.READ)
	# now simply overwrite store by parsing the loaded data
	store = parse_json(loadInit.get_line())
	loadInit.close()
	# DEBUG stuff:
	print("Loaded data: ", store)
	print("New Game")
