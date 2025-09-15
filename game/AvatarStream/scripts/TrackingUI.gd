extends Control

signal calibrate_t_pose

var godot_cmio: Node
var is_virtual_cam_running = false

@onready var virtual_cam_button = $VirtualCamButton
@onready var resolution_option_button = $ResolutionOptionButton
@onready var virtual_cam_label = $VirtualCamLabel

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
	emit_signal("calibrate_t_pose")
