extends Node

var skeleton: Skeleton3D
var pose_timer: Timer

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
