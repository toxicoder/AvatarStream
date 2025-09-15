extends Node

enum AppState {
	MAIN_MENU,
	AVATAR_GENERATION,
	TRACKING,
	MAIN_SCENE
}

enum ThemeType {
	DARK,
	LIGHT,
	HIGH_CONTRAST
}

var current_state: AppState = AppState.MAIN_MENU
var generated_avatar_path: String = ""
var error_popup_scene = preload("res://scenes/ErrorPopup.tscn")
var themes = {
	ThemeType.DARK: null,
	ThemeType.LIGHT: preload("res://themes/light_theme.tres"),
	ThemeType.HIGH_CONTRAST: preload("res://themes/high_contrast_theme.tres")
}
var current_theme = ThemeType.DARK

signal calibrate_t_pose

func _ready():
	# Ensure we start in the main menu
	change_state(AppState.MAIN_MENU)

func change_state(new_state: AppState):
	if new_state == current_state:
		return

	current_state = new_state

	match current_state:
		AppState.MAIN_MENU:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		AppState.AVATAR_GENERATION:
			get_tree().change_scene_to_file("res://scenes/AvatarGen.tscn")
		AppState.TRACKING:
			get_tree().change_scene_to_file("res://scenes/Tracking.tscn")
		AppState.MAIN_SCENE:
			get_tree().change_scene_to_file("res://scenes/MainScene.tscn")

func _on_LoadAvatar_pressed():
	# This function is connected in MainMenu.tscn
	# For now, it will just load the main scene with the default avatar
	generated_avatar_path = ""
	change_state(AppState.MAIN_SCENE)

func _on_GenerateAvatar_pressed():
	# This function is connected in MainMenu.tscn
	change_state(AppState.AVATAR_GENERATION)

func on_avatar_generated(avatar_path: String):
	generated_avatar_path = avatar_path
	change_state(AppState.TRACKING)

func show_error(message: String):
	var error_popup = error_popup_scene.instantiate()
	error_popup.set_message(message)
	get_tree().root.add_child(error_popup)

func _on_ThemeButton_pressed():
	current_theme = ThemeType.values()[(current_theme.to_int() + 1) % ThemeType.values().size()]
	get_tree().root.theme = themes[current_theme]
