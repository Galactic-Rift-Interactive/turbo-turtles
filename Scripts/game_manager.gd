extends Node

const DATA_FILE = "user://gamedata.dat"

var data = {
	"races": {
		"road": [],
	}
}

func _ready():
	load_data()

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
