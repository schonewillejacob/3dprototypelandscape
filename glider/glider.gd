extends Node3D
#
#
#
## MEMBERS ######################################################################
#@export var camera_rig : Node3D
#@export var target_path_follower : PathFollow3D
#@onready var node_GliderMesh = $GliderMesh
#
#var SPEED = 0.01
#var log_progess_timer = Timer.new()
#@export var debug_timer = false
#
#
#
## VIRTUALS #####################################################################
#func _ready() -> void:
	#if debug_timer:
		#log_progess_timer.timeout.connect(_on_progress_timeout)
		#add_child(log_progess_timer)
		#log_progess_timer.start(1)
#
#func _process(delta: float) -> void:
	#push_partial_transform_to_camera()
	#target_path_follower.progress_ratio += delta * SPEED
#
#
#
## METHODS ######################################################################
#func push_partial_transform_to_camera() -> void:
	#if camera_rig: 
		#camera_rig.rotation.y = rotation.y
		#camera_rig.global_position = global_position
#
#
#
## SIGNALS ######################################################################
#func _on_progress_timeout() -> void:
	#print(target_path_follower.progress_ratio)
	#log_progess_timer.start(1)
