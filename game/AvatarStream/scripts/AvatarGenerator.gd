extends Node

# Signals for generation progress
signal generation_started
signal generation_progress(value)
signal generation_finished(path)

var skeleton: Skeleton3D
var pose_timer: Timer

# Variables for async process
var generation_pid = 0
var progress_file_path = "user://progress.txt"
var output_gltf_path = ""

func generate_avatar(image_path: String):
	emit_signal("generation_started")

	# Define paths
	var python_script_path = "res://scripts/python/generate_avatar.py"
	# Create a unique filename for the output gltf
	var timestamp = Time.get_unix_time_from_system()
	output_gltf_path = "res://assets/avatars/avatar_" + str(timestamp) + ".gltf"

	# Prepare arguments for the script
	var args = [
		ProjectSettings.globalize_path(image_path),
		ProjectSettings.globalize_path(output_gltf_path),
		ProjectSettings.globalize_path(progress_file_path)
	]

	# Execute the python script
	# Note: This assumes 'python' is in the system's PATH.
	# For better portability, one might specify the full path to the python executable.
	generation_pid = OS.create_process("python", [ProjectSettings.globalize_path(python_script_path)] + args)

	if generation_pid == -1:
		print("Error: Failed to start the generation process.")
		emit_signal("generation_finished", "")


func _process(delta):
	if generation_pid != 0:
		if OS.is_process_running(generation_pid):
			# Process is running, check for progress
			if FileAccess.file_exists(progress_file_path):
				var file = FileAccess.open(progress_file_path, FileAccess.READ)
				var progress_text = file.get_as_text()
				file.close()
				if progress_text.is_valid_float():
					emit_signal("generation_progress", float(progress_text))
		else:
			# Process finished
			var exit_code = OS.get_process_exit_code(generation_pid)
			generation_pid = 0

			if exit_code == 0 and FileAccess.file_exists(output_gltf_path):
				emit_signal("generation_finished", output_gltf_path)
			else:
				print("Error: Generation script failed with exit code: " + str(exit_code))
				emit_signal("generation_finished", "")

			# Clean up progress file
			if FileAccess.file_exists(progress_file_path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(progress_file_path))


func register_skeleton(target_skeleton: Skeleton3D):
	skeleton = target_skeleton

	if pose_timer:
		pose_timer.queue_free()

	pose_timer = Timer.new()
	add_child(pose_timer)
	pose_timer.wait_time = 2.0
	pose_timer.timeout.connect(_on_pose_timer_timeout)
	pose_timer.start()

	_change_pose()

func _on_pose_timer_timeout():
	_change_pose()

func _change_pose():
	if not skeleton:
		return

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var rng = RandomNumberGenerator.new()

	for i in range(skeleton.get_bone_count()):
		var bone_name = skeleton.get_bone_name(i)
		# Don't rotate leaf bones for a more natural look
		if not "Toes" in bone_name and not "Distal" in bone_name and not "Eye" in bone_name and not "Jaw" in bone_name:
			var random_rotation = Quat.from_euler(Vector3(
				rng.randf_range(-PI / 8, PI / 8),
				rng.randf_range(-PI / 8, PI / 8),
				rng.randf_range(-PI / 8, PI / 8)
			))
			tween.tween_property(skeleton, "bones/" + str(i) + "/rotation", random_rotation, 1.8)

func _ready():
	pass
