extends Node3D

@onready var timer := $Timer
@onready var elapsed_time := 0
@onready var player := $Player
@onready var initial_player_position: Vector3 = player.position

func _ready():
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.position.y < -10:
		player.position = player.last_position
		player.position.y += 1 # let them fall a little


func _on_timer_timeout():
	elapsed_time += timer.wait_time 
