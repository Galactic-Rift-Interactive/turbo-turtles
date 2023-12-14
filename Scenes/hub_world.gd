extends Node3D

func _on_road_race_load_area_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://Scenes/road_race.tscn")
