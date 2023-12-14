# New Instancer -- This module is used to scatter objects around on given surface.
# Version: 1.0.3
# Author: Deja S.
# Created: 23-11-2023
# Last edit: 01-12-2023

@tool
extends Node3D

# Exports
@export var center: Node3D
@export var instance_amount : int = 10 :
	get:
		return instance_amount
	set(value):
		instance_amount = value
		#create_multimesh()
@export var instance_spacing : int = 20 :
	get:
		return instance_spacing
	set(value):
		instance_spacing = value
		#create_multimesh()
@export var instance_height : float = 1
@export var instance_width : float = 1
@export var pos_randomize : float = 5 :
	get:
		return pos_randomize
	set(value):
		pos_randomize = value
		#create_multimesh()
@export_range(0,PI) var instance_Y_rot : float = 0.0 :
	get:
		return instance_Y_rot
	set(value):
		instance_Y_rot = value
		#create_multimesh()
@export_range(0,PI) var instance_X_rot : float = 0.0 :
	get:
		return instance_X_rot
	set(value):
		instance_X_rot = value
		#create_multimesh()
@export_range(0,PI) var instance_Z_rot : float = 0.0 :
	get:
		return instance_Z_rot
	set(value):
		instance_Z_rot = value
		#create_multimesh()
@export var rot_y_randomize : float = 0.0 :
	get:
		return rot_y_randomize
	set(value):
		rot_y_randomize = value
		#create_multimesh()
@export var rot_x_randomize : float = 0.0 :
	get:
		return rot_x_randomize
	set(value):
		rot_x_randomize = value
		#create_multimesh()
@export var rot_z_randomize : float = 0.0 :
	get:
		return rot_z_randomize
	set(value):
		rot_z_randomize = value
		#create_multimesh()
@export var instance_mesh : MeshInstance3D
@export var surface_mesh : MeshInstance3D

# Onready vars
@onready var center_last_pos : Vector3
@onready var instance_row : int
@onready var multi_mesh : MultiMesh
@onready var multi_mesh_instance : MultiMeshInstance3D
@onready var offset : float
@onready var width : int
@onready var height : int

func random(x,z):
	var r = fposmod(sin(Vector2(x,z).dot(Vector2(12.9898,78.233)) * 43758.5453123),1.0)
	return r

func distribute_meshes():
	randomize()

	for i in range(instance_amount):
		var pos = global_position
		pos.z = i
		pos.x = (int(pos.z) % instance_row)
		pos.z = int((pos.z - pos.x) / instance_row)

		# center
		pos.x -= offset / 2
		pos.z -= offset / 2

		pos *= instance_spacing
		pos.x += int(global_position.x) - (int(global_position.x) % instance_spacing)
		pos.z += int(global_position.z) - (int(global_position.z) % instance_spacing)

		# Randomisation
		pos.x += random(pos.x,pos.z) * pos_randomize
		pos.z += random(pos.x,pos.z) * pos_randomize
		pos.x -= pos_randomize * random(pos.x,pos.z)
		pos.z -= pos_randomize * random(pos.x,pos.z)

		var x = pos.x
		var z = pos.z
		var y = get_y_value(x, z)* 0.009

		if y == null:
			y = 1

		var rot = Vector3(0,0,0)
		rot.x += instance_X_rot + (random(x,z) * rot_x_randomize)
		rot.y += instance_Y_rot + (random(x,z) * rot_y_randomize)
		rot.z += instance_Z_rot + (random(x,z) * rot_z_randomize)

		var ori = Vector3(x, y, z)
		var sc = Vector3(   random(x,z) + instance_width,
							random(x,z) + instance_height,
							random(x,z) + instance_width
							)

		# var sc = Vector3(1, 1, 1)

		rot.x += instance_X_rot + (random(x,z) * rot_x_randomize)
		rot.y += instance_Y_rot + (random(x,z) * rot_y_randomize)
		rot.z += instance_Z_rot + (random(x,z) * rot_z_randomize)

		var t = Transform3D()
		t.origin = ori

		t = t.rotated_local(t.basis.x.normalized(),rot.x)
		t = t.rotated_local(t.basis.y.normalized(),rot.y)
		t = t.rotated_local(t.basis.z.normalized(),rot.z)

		multi_mesh.set_instance_transform(i, t.scaled_local(sc))
	return multi_mesh

func create_multimesh():
	if multi_mesh != null:
		remove_child(multi_mesh_instance)
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.top_level = true
	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.instance_count = instance_amount

	if instance_mesh != null:
		multi_mesh.mesh = instance_mesh.mesh

		# May need to change this to get the instance actual texture.
		for x in range(instance_mesh.get_surface_override_material_count()):
			multi_mesh.mesh.surface_set_material(x, instance_mesh.get_surface_override_material(x))

	instance_row = sqrt(instance_amount)
	offset = round(instance_amount/instance_row)

	add_child(multi_mesh_instance)

	multi_mesh_instance.multimesh = distribute_meshes()

func get_y_value(target_x, target_z):
# Gets the y-value for object spawn point.

	var g_mesh

	if surface_mesh != null:
		g_mesh = surface_mesh.mesh

	if g_mesh != null:
		var mdt = MeshDataTool.new()

		mdt.create_from_surface(g_mesh, 0)

		var closest_vertex = Vector3(0, 0, 0)
		var closest_distnace = INF

		for i in range(mdt.get_vertex_count()):
			var t_vertex = mdt.get_vertex(i)
			var distance = (Vector2(target_x, target_z) - Vector2(t_vertex.x, t_vertex.z)).length_squared()

			if distance < closest_distnace:
				closest_distnace = distance
				closest_vertex = t_vertex
		mdt.clear()
		return closest_vertex.y
	else:
		print("ERROR: No surface mesh provided.")

func is_position_in_surface(t_position):
	var surface_global_trans = surface_mesh.global_transform
	var surface_inv_trans = surface_global_trans.affine_inverse()
	var local_position = surface_inv_trans.xform(position)

	var aabb = surface_mesh.get_aabb()

	return aabb.has_point(local_position)

func _process(delta):
	#if center.global_transform.origin != center_last_pos:
	#	distribute_meshes()
	#center_last_pos = center.global_transform.origin
	pass

func _update():
	#self.global_position = Vector3(center.global_position.x,0.0,center.global_position.z).snapped(Vector3(1,0,1));
	#create_multimesh()
	pass

func _ready():
	#create_multimesh()
	pass
