extends Node

var generated_avatar_path: String = ""

func _on_LoadAvatar_pressed():
	# Ensure we load the default avatar if no new one has been generated
	generated_avatar_path = ""
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")

func _on_GenerateAvatar_pressed():
	get_tree().change_scene_to_file("res://scenes/AvatarGen.tscn")

func _ready():
	pass

func _process(delta):
	pass
