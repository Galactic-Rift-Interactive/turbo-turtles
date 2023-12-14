extends Control

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/hub_world.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_about_pressed():
	get_tree().change_scene_to_file("res://Scenes/about.tscn")
