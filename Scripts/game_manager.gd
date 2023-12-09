extends Node

const DATA_FILE = "user://gamedata.dat"

var is_game_paused = false
var data = {
	"races": {
		"road": [],
	}
}

func _ready():
	load_data()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	pass

func save_data():
	var file = FileAccess.open(DATA_FILE, FileAccess.WRITE)
	file.store_var(data, true)
	file.close()

func load_data():
	if !FileAccess.file_exists(DATA_FILE):
		save_data()
		return
	var file = FileAccess.open(DATA_FILE, FileAccess.READ)
	data = file.get_var(true)
	file.close()

func save_race(race_name, laps):
	data[race_name] = laps
	save_data()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		toggle_pause()

func toggle_pause():
	is_game_paused = not is_game_paused
	if is_game_paused:
		get_tree().paused = true
		print("Game Paused")
	else:
		get_tree().paused = false
		print("Game Resumed")
