extends Label

var time = 4
var timer_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(timer_on):
			time -= delta
			text = "%2d" % [time]
			if(time < 1):
				text = "GO!"
				get_tree().paused = false
			if(time < 0):
				timer_on = false
				visible = false


func _on_path_3d_start_timer():
	timer_on = true
