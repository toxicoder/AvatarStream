extends Node3D

# Kalman Filter implementation
class KalmanFilter:
	var q # process noise covariance
	var r # measurement noise covariance
	var x # value
	var p # estimation error covariance
	var k # kalman gain

	func _init(q_val, r_val):
		q = q_val
		r = r_val
		x = 0
		p = 1
		k = 1

	func update(measurement):
		p = p + q
		k = p / (p + r)
		x = x + k * (measurement - x)
		p = (1 - k) * p
		return x

var kalman_filters = {}
var initial_ik_target_positions = {}

@onready var ik_targets = {
	"left_arm": $IKTargets/LeftArmIKTarget,
	"right_arm": $IKTargets/RightArmIKTarget,
	"left_leg": $IKTargets/LeftLegIKTarget,
	"right_leg": $IKTargets/RightLegIKTarget
}

@onready var ik_solvers = {
	"left_arm": $Skeleton3D/LeftArmIK,
	"right_arm": $Skeleton3D/RightArmIK,
	"left_leg": $Skeleton3D/LeftLegIK,
	"right_leg": $Skeleton3D/RightLegIK
}

var t_pose_data = {}
var is_calibrated = false
var pose_scale = Vector3(2, 2, 1) # Adjust this to scale the movement

func _ready():
	AvatarGenerator.register_skeleton(get_node("Skeleton3D"))
	# It's better to find the UI node in the scene tree
	var ui_node = get_tree().root.find_child("TrackingUI", true, false)
	if ui_node:
		ui_node.connect("calibrate_t_pose", Callable(self, "_on_calibrate_t_pose"))
	else:
		print("TrackingUI node not found. Calibration will not work.")

	stop_ik()

func stop_ik():
	for solver in ik_solvers.values():
		solver.stop()

func start_ik():
	for solver in ik_solvers.values():
		solver.start()

func _on_calibrate_t_pose():
	print("Calibrating T-Pose...")
	var landmarks = MediaPipeBridge.get_pose_landmarks()
	if landmarks and landmarks.size() > 0:
		t_pose_data = {
			"left_arm": landmarks[15], # Left wrist
			"right_arm": landmarks[16], # Right wrist
			"left_leg": landmarks[27], # Left ankle
			"right_leg": landmarks[28]  # Right ankle
		}
		for target_name in ik_targets.keys():
			initial_ik_target_positions[target_name] = ik_targets[target_name].global_position

		is_calibrated = true
		start_ik()
		print("T-Pose calibrated.")
	else:
		print("Calibration failed: No landmark data available.")

func _process(_delta):
	if not is_calibrated:
		return

	var landmarks = MediaPipeBridge.get_pose_landmarks()
	if landmarks and landmarks.size() > 0:
		update_ik_target("left_arm", landmarks[15])
		update_ik_target("right_arm", landmarks[16])
		update_ik_target("left_leg", landmarks[27])
		update_ik_target("right_leg", landmarks[28])

func update_ik_target(target_name, landmark_data):
	if not t_pose_data.has(target_name):
		return

	var t_pose_landmark = t_pose_data[target_name]

	var target_offset = Vector3(
		(landmark_data.x - t_pose_landmark.x) * pose_scale.x,
		-(landmark_data.y - t_pose_landmark.y) * pose_scale.y, # Y is inverted
		(landmark_data.z - t_pose_landmark.z) * pose_scale.z
	)

	# Apply Kalman filter for smoothing
	if not kalman_filters.has(target_name):
		kalman_filters[target_name] = {
			"x": KalmanFilter.new(0.1, 0.1),
			"y": KalmanFilter.new(0.1, 0.1),
			"z": KalmanFilter.new(0.1, 0.1)
		}

	var filtered_offset = Vector3(
		kalman_filters[target_name].x.update(target_offset.x),
		kalman_filters[target_name].y.update(target_offset.y),
		kalman_filters[target_name].z.update(target_offset.z)
	)

	var initial_pos = initial_ik_target_positions[target_name]
	ik_targets[target_name].global_position = initial_pos + filtered_offset
