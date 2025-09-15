extends Node3D

func _ready():
	AvatarGenerator.register_skeleton(get_node("Skeleton3D"))
