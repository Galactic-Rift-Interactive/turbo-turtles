extends Path3D

var speed = 0.5
signal start_timer

func _ready():
	$PathFollow3D/CinematicCam.make_current()
	get_tree().paused = true

func _process(delta):
	$PathFollow3D.progress_ratio += speed * delta
	if $PathFollow3D.progress_ratio >= 1-speed*delta:
		$PathFollow3D/CinematicCam.clear_current()
		emit_signal("start_timer")
