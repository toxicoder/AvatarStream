extends Node

func generate_avatar():
	var command = "python3.12"
	var args = ["-c", "import torch; import cv2; print('hello from python')"] # a simple python script
	var output = []
	var exit_code = OS.execute(command, args, output)
	if exit_code == 0:
		print("Python script executed successfully")
		print("Output: ", output[0])
	else:
		print("Error executing python script")

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_avatar()
