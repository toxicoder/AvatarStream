extends Control

signal calibrate_t_pose

func _on_CalibrateButton_pressed():
	emit_signal("calibrate_t_pose")
