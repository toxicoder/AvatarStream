extends Node

# Signals for generation progress
signal generation_started
signal generation_progress(value)
signal generation_finished(path)

var skeleton: Skeleton3D
var pose_timer: Timer

func _ready():
	WorkerThreadPool.max_threads = 1 # We only need one thread for this

func generate_avatar(image_path: String):
	emit_signal("generation_started")
	var task = func():
		_generate_avatar_thread(image_path)
	WorkerThreadPool.add_task(task)

func _generate_avatar_thread(image_path: String):
	# Define paths
	var python_script_path = "res://scripts/python/generate_avatar.py"
	# Create a unique filename for the output gltf
	var timestamp = Time.get_unix_time_from_system()
	var output_gltf_path = "res://assets/avatars/avatar_" + str(timestamp) + ".gltf"

	# Prepare arguments for the script
	var args = [
		ProjectSettings.globalize_path(image_path),
		ProjectSettings.globalize_path(output_gltf_path)
	]

	# Execute the python script
	var output = []
	var exit_code = OS.execute("python", [ProjectSettings.globalize_path(python_script_path)] + args, output, true, true)

	if exit_code != 0:
		print("Error: Generation script failed with exit code: " + str(exit_code))
		call_deferred("emit_signal", "generation_finished", "")
		GameManager.call_deferred("show_error", "Avatar generation script failed. See console for details.")
		return

	# The python script will print progress to stdout
	# For this example, we assume the last line of output is the path
	var result_path = ""
	for line in output:
		if line.begins_with("PROGRESS:"):
			var progress = float(line.replace("PROGRESS:", "").strip())
			call_deferred("emit_signal", "generation_progress", progress)
		elif line.begins_with("SUCCESS:"):
			result_path = line.replace("SUCCESS:", "").strip()

	if FileAccess.file_exists(result_path):
		call_deferred("emit_signal", "generation_finished", result_path)
	else:
		print("Error: Generation script finished but output file not found.")
		call_deferred("emit_signal", "generation_finished", "")
		GameManager.call_deferred("show_error", "Avatar generation finished, but the output file was not found.")


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
