extends Node3D

@export var MAX_LAPS = 3
@export var RACE_NAME = ""

@onready var timer := $Timer
@onready var player := $Player
@onready var initial_player_position: Vector3 = player.position
var elapsed_time := 0.0
var current_lap := -1
var laps := []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.position.y < -10:
		player.reset_to_last_position()
	$Player/Label3D.text = ''
	if current_lap >= 0:
		for i in len(laps):
			if i > 0:
				$Player/Label3D.text += "\nLap " + str(i + 1) + ": " + str(snapped(laps[i] - laps[i - 1], 0.1))
			else:
				$Player/Label3D.text += "\nLap " + str(i + 1) + ": " + str(snapped(laps[i], 0.1))
	if current_lap == 0:
		$Player/Label3D.text += "\nCurrent Lap: " + str(snapped(elapsed_time , 0.1))
	elif current_lap > 0:
		$Player/Label3D.text += "\nCurrent Lap: " + str(snapped(elapsed_time - laps[current_lap - 1], 0.1))

func _on_timer_timeout():
	elapsed_time += timer.wait_time

func _on_banner_entrance_body_entered(body):
	if body == player:
		if timer.is_stopped():
			timer.start()
		if current_lap < 0:
			current_lap += 1
			return
		laps.push_back(elapsed_time)
		if len(laps) >= MAX_LAPS:
			# TODO: gracefully end race
			GameManager.save_race(RACE_NAME, laps)
			get_tree().change_scene_to_file("res://Scenes/hub_world.tscn")
		current_lap += 1
