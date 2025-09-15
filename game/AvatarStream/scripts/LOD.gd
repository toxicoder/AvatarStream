extends Node3D

@export var lods: Array[NodePath] = []
@export var lod_distances: Array[float] = []

var camera: Camera3D
var current_lod_index = -1

func _ready():
	camera = get_viewport().get_camera_3d()
	# Hide all LODs except the first one
	for i in range(1, lods.size()):
		get_node(lods[i]).hide()


func _process(delta):
	if not camera:
		return

	var dist = global_transform.origin.distance_to(camera.global_transform.origin)

	var lod_index = 0
	for i in range(lods.size()):
		if dist > lod_distances[i]:
			lod_index = i
		else:
			break

	if lod_index != current_lod_index:
		for i in range(lods.size()):
			if i == lod_index:
				get_node(lods[i]).show()
			else:
				get_node(lods[i]).hide()
		current_lod_index = lod_index
