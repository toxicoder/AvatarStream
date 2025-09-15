extends Node

var udp = PacketPeerUDP.new()
var pose_landmarks = []
var python_pid = -1

func _ready():
	# The port should match the one in the Python script
	var port = 5005
	if udp.listen(port) != OK:
		print("Error listening on port: ", port)
		return

	print("Listening on port: ", port)

	var python_script_path = ProjectSettings.globalize_path("res://scripts/python/holistic_tracker.py")
	var args = ["-u", python_script_path]

	# For Windows, it's often 'python.exe', but 'python' should work if it's in PATH.
	# For macOS and Linux, it could be 'python' or 'python3'.
	var python_executable = "python"

	python_pid = OS.execute(python_executable, args, false) # non-blocking

	if python_pid == 0 or python_pid == -1: # 0 or -1 indicates failure
		print("Error starting python script with 'python'. Trying 'python3'.")
		python_executable = "python3"
		python_pid = OS.execute(python_executable, args, false) # non-blocking
		if python_pid == 0 or python_pid == -1:
			 print("Error starting python script with 'python3' as well. Please check your python installation and PATH.")
		else:
			print("Python script started with PID: ", python_pid)
	else:
		print("Python script started with PID: ", python_pid)


func _process(_delta):
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var data_string = packet.get_string_from_utf8()

		var json = JSON.new()
		var error = json.parse(data_string)
		if error == OK:
			var data = json.get_data()
			if data.has("pose_landmarks"):
				pose_landmarks = data["pose_landmarks"]
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", data_string)

func get_pose_landmarks():
	return pose_landmarks

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_CLOSE_REQUEST:
		if python_pid > 0 and OS.is_process_running(python_pid):
			OS.kill(python_pid)
			print("Killed python process with PID: ", python_pid)
		udp.close()
