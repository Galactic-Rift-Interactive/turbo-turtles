extends Node3D

func _on_play_pressed():
	get_tree().change_scene_to_file("res://hub_world.tscn")


func _on_exit_pressed():
	get_tree().quit()
