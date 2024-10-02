extends Node3D



# MEMBERS ######################################################################
@export var camera_rig : Node3D
@export var target_path_follower : PathFollow3D
@onready var node_GliderMesh = $GliderMesh

var SPEED = 0.01



# VIRTUALS #####################################################################
func _process(delta: float) -> void:
	push_partial_transform_to_camera()
	target_path_follower.progress_ratio += delta * SPEED



# METHODS ######################################################################
func push_partial_transform_to_camera() -> void:
	if camera_rig: 
		camera_rig.transform.basis = transform.basis
		camera_rig.global_position = global_position
