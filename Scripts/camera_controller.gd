extends Node3D

var player
@export var sensitivity := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = player.global_position
	$SpringArm3D/Camera3D.look_at(player.get_node("LookAt").global_position)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000 * sensitivity


func _on_area_3d_body_entered(body):
	if body.name == "Turtle":
		get_tree().change_scene_to_file("res://Scenes/beach_race.tscn")


func _on_area_3d_body_entered1(body):
	if body.name == "Turtle":
		get_tree().change_scene_to_file("res://Scenes/road_race.tscn")
