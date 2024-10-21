
extends Node3D

@onready var glider = $Glider
@onready var cam = $CameraRig/Camera3D

var path : Path3D
var pfollow : PathFollow3D
var n : int
var t : float
var pts : PackedVector3Array
var curr : Vector3
var next : Vector3
var forward : Vector3
var skip : int

# New speed parameter
var speed : float = 0.5  # Adjust this value to control the speed of the glider

func _ready():
	skip = 0
	_setup_path()
	pass
	

#func _setup_path():
	#path = Path3D.new()
	#path.transform = Transform3D.IDENTITY
	#var curve := Curve3D.new()
	#var N = 8  # Number of points in the path
	#var r = 50  # Radius for scaling the path
	#var origin = Vector3(110, 12, 100)
#
	## Generate irregular path points
	#for k in range(N + 1):
		## Use Perlin noise or a sine wave to create an irregular path
		#var x = k * (float(r) / float(N))  # Convert both to float
		#var z = sin(k * 0.5) * 10 + cos(k * 0.8) * 10  # Irregularity in z using sine and cosine
		#var y = sin(k * 0.3) * 5  # Add some vertical movement
		#var pt = Vector3(x, y, z) + origin
		#curve.add_point(pt)
#
	## Rotate control points for tangent handles
	#for k in range(N):
		#var pt_out = Vector3(1, 0, 0) * (2.0 / N)  # Tangent handle outwards
		#curve.set_point_out(k, pt_out)
		#var pt_in = Vector3(1, 0, 0) * (2.0 / N)  # Tangent handle inwards
		#curve.set_point_in(k + 1, pt_in)
#
	#pts = curve.get_baked_points()
	#n = len(pts) - 1
#
	#path.curve = curve
	#pfollow = PathFollow3D.new()
	#glider.transform = Transform3D.IDENTITY
	#cam.transform = Transform3D.IDENTITY
	#cam.position = Vector3(0, 1, 2)
	#cam.look_at(glider.position)
	#cam.reparent(glider)
	#glider.rotate_y(PI)  # Initial rotation to face opposite direction
	#glider.reparent(pfollow)
	#path.add_child(pfollow)
	#pfollow.transform = Transform3D.IDENTITY
	#add_child(path)
	#pass



func _setup_path():
	path = Path3D.new()
	path.transform = Transform3D.IDENTITY
	var curve := Curve3D.new()
	var N = 10
	var r = 50
	var origin = Vector3(110, 12, 100)
	
	for k in range(N + 1):
		var x = cos(k * 2 * PI / float(N))
		var z = sin(k * 2 * PI / float(N))
		var pt = r * Vector3(x, 0, z) + origin
		curve.add_point(pt)
	
	# Rotate control points for tangent handles
	for k in range(N):
		var x = cos(k * 2 * PI / float(N))
		var z = sin(k * 2 * PI / float(N))
		var pt_out = r * (2.0 / N) * Vector3(x, 0, z).rotated(Vector3.UP, -PI / 2)
		curve.set_point_out(k, pt_out)
		x = cos((k + 1) * 2 * PI / float(N))
		z = sin((k + 1) * 2 * PI / float(N))
		var pt_in = r * (2.0 / N) * Vector3(x, 0, z).rotated(Vector3.UP, PI / 2)
		curve.set_point_in(k + 1, pt_in)
	
	pts = curve.get_baked_points()
	n = len(pts) - 1
	
	path.curve = curve
	pfollow = PathFollow3D.new()
	glider.transform = Transform3D.IDENTITY
	cam.transform = Transform3D.IDENTITY
	cam.position = Vector3(0, 1, 2)
	cam.look_at(glider.position)
	cam.reparent(glider)
	glider.rotate_y(PI)  
	glider.reparent(pfollow)
	path.add_child(pfollow)
	pfollow.transform = Transform3D.IDENTITY
	add_child(path)

func _process(delta):
	# Updating time based on speed
	t = (t + delta * speed) if (t < 10) else 0
	pfollow.progress_ratio = t / 10.0
	
	skip += 1
	if (skip % 10 == 0):
		var k = floor(n * t / 10.0)
		curr = pts[len(pts) - 1] if k > len(pts) - 2 else pts[k]
		next = pts[0] if k > len(pts) - 2 else pts[k + 1] 
		forward = (next - curr).normalized()

	if forward.length() > 0:  # Checking if forward vector is not zero
		# Update glider's rotation to face proper direction based on landscape and camera position
		glider.transform.basis = Basis(Vector3(0, 1, 0), PI * 0.5) * Transform3D.IDENTITY.basis  # Adjusted angle
		glider.transform.basis = Basis(Vector3(0, 0, 1), sin(t * 2 * PI / 5) * -PI / 4.0) * glider.transform.basis  # Adjusted angle
		
		# Make the glider face the direction of movement (opposite)
		glider.look_at(pfollow.position + forward * 10)  
		
		## Rise and fall along the path using a sine wave
		#var rise_fall_amount = sin(t * 2 * PI / 5) * 2.0  # Adjust the amplitude of rise and fall
		#glider.position.z = curr.z + rise_fall_amount  # Update glider's vertical position
		#
		## Adjust camera angle to follow the glider's movement
		#cam.look_at(glider.position)
