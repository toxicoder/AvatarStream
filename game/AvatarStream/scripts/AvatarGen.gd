extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var status_label = $VBoxContainer/StatusLabel
@onready var file_dialog = $FileDialog
@onready var select_image_button = $VBoxContainer/SelectImageButton
@onready var webcam_button = $VBoxContainer/WebcamButton
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	# Connect to the AvatarGenerator singleton
	AvatarGenerator.generation_started.connect(_on_generation_started)
	AvatarGenerator.generation_progress.connect(_on_generation_progress)
	AvatarGenerator.generation_finished.connect(_on_generation_finished)

func _on_select_image_button_pressed():
	file_dialog.popup_centered()

func _on_webcam_button_pressed():
	status_label.text = "Webcam not implemented yet."
	# Placeholder for webcam logic

func _on_back_button_pressed():
	GameManager.change_state(GameManager.AppState.MAIN_MENU)

func _on_file_dialog_file_selected(path: String):
	status_label.text = "Starting generation..."
	AvatarGenerator.generate_avatar(path)

func _on_generation_started():
	progress_bar.value = 0
	progress_bar.visible = true
	status_label.text = "Generation in progress..."
	select_image_button.disabled = true
	webcam_button.disabled = true
	back_button.disabled = true

func _on_generation_progress(value: float):
	progress_bar.value = value
	status_label.text = "Generation in progress... " + str(value) + "%"

func _on_generation_finished(path: String):
	status_label.text = "Generation complete!"
	select_image_button.disabled = false
	webcam_button.disabled = false
	back_button.disabled = false

	if path.is_empty():
		# Handle generation failure
		status_label.text = "Generation failed. Please try again."
	else:
		# Let the GameManager handle the state transition
		GameManager.on_avatar_generated(path)
