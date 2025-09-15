extends Node3D

@onready var avatar_placeholder = $AvatarPlaceholder

func _ready():
	if GameManager.generated_avatar_path != "":
		# A new avatar has been generated, so load it
		var new_avatar_scene = load(GameManager.generated_avatar_path)
		if new_avatar_scene:
			var new_avatar_instance = new_avatar_scene.instantiate()
			# Replace the placeholder with the new avatar
			avatar_placeholder.replace_by(new_avatar_instance)
			# The old placeholder is freed, so we don't need to remove it

			# We can also reset the path so it doesn't load again on scene reload
			GameManager.generated_avatar_path = ""
		else:
			var error_message = "Error: Could not load the generated avatar scene from path: " + GameManager.generated_avatar_path
			print(error_message)
			GameManager.show_error(error_message)
