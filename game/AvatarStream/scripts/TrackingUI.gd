extends Control

signal calibrate_t_pose

var godot_cmio: Node
var is_virtual_cam_running = false

@onready var virtual_cam_button = $VirtualCamButton
@onready var resolution_option_button = $ResolutionOptionButton
@onready var virtual_cam_label = $VirtualCamLabel
@onready var save_dialog = $SaveDialog
@onready var load_dialog = $LoadDialog

func _ready():
	# Add resolution options
	resolution_option_button.add_item("1280x720")
	resolution_option_button.add_item("1920x1080")
	resolution_option_button.add_item("640x480")

	# Instantiate the GodotCMIO node
	godot_cmio = load("res://gdextension_cmio.gdextension").new()
	add_child(godot_cmio)


func _on_VirtualCamButton_pressed():
	if is_virtual_cam_running:
		godot_cmio.stop_virtual_camera()
		virtual_cam_button.text = "Start Virtual Camera"
		virtual_cam_label.text = "Virtual Camera: Stopped"
		is_virtual_cam_running = false
	else:
		godot_cmio.start_virtual_camera()
		virtual_cam_button.text = "Stop Virtual Camera"
		virtual_cam_label.text = "Virtual Camera: Running"
		is_virtual_cam_running = true

func _on_ResolutionOptionButton_item_selected(index):
	var resolution = resolution_option_button.get_item_text(index).split("x")
	var width = int(resolution[0])
	var height = int(resolution[1])
	godot_cmio.set_resolution(width, height)

func _process(delta):
	if is_virtual_cam_running:
		var img = get_viewport().get_texture().get_image()
		godot_cmio.send_frame(img.save_jpg_to_buffer())

func _on_CalibrateButton_pressed():
	GameManager.emit_signal("calibrate_t_pose")

func _on_StartTrackingButton_pressed():
	GameManager.change_state(GameManager.AppState.MAIN_SCENE)

func _on_SaveAvatarButton_pressed():
	save_dialog.popup_centered()

func _on_LoadAvatarButton_pressed():
	load_dialog.popup_centered()

func _on_SaveDialog_file_selected(path: String):
	var source_path = GameManager.generated_avatar_path
	if source_path.is_empty():
		GameManager.show_error("No avatar has been generated yet.")
		return

	var dir_access = DirAccess.open("res://")
	dir_access.copy_absolute(source_path, path)

func _on_LoadDialog_file_selected(path: String):
	GameManager.generated_avatar_path = path
	GameManager.change_state(GameManager.AppState.MAIN_SCENE)
