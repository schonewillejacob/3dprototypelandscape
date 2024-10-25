extends Node3D

@onready var glider = $Glider
@onready var cam = $CameraRig/Camera3D
@onready var path_mesh = $MeshInstance3D


var path : Path3D
var pfollow : PathFollow3D
var n : int
var t : float
var pts : PackedVector3Array
var curr : Vector3
var next : Vector3
var forward : Vector3
var skip : int


var speed : float = 0.12  # speed of the glider

func _ready():
	skip = 0
	_setup_path()
	pass

func _generate_hilbert_curve(order: int, size: float, position: Vector3, points: PackedVector3Array) -> void:
	if order == 0:
		points.append(position)
	else:
		size /= 2.0
		_generate_hilbert_curve(order - 1, size, position + Vector3(-size, 0, -size), points)
		_generate_hilbert_curve(order - 1, size, position + Vector3(-size, 0, size), points)
		_generate_hilbert_curve(order - 1, size, position + Vector3(size, 0, size), points)
		_generate_hilbert_curve(order - 1, size, position + Vector3(size, 0, -size), points)


func _create_catmull_rom_spline(points: PackedVector3Array) -> Curve3D:
	var curve = Curve3D.new()
	n = points.size()
	

	for i in range(n):
		var p0 = points[(i - 1 + n) % n]  # Prev point 
		var p1 = points[i]                # Curr point
		var p2 = points[(i + 1) % n]      # Next point
		var p3 = points[(i + 2) % n]      # point after next

		# Catmull-Rom spline points
		for t in range(0, 460):  # increased the no. of segments between each control point for smoother movement
			var t_normalized = t / 460.0
			var t2 = t_normalized * t_normalized
			var t3 = t2 * t_normalized
		
			var x = 0.5 * ((2.0 * p1.x) + 
						   (-p0.x + p2.x) * t_normalized + 
						   (2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 + 
						   (-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3)
			var y = 0.5 * ((2.0 * p1.y) + 
						   (-p0.y + p2.y) * t_normalized + 
						   (2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 + 
						   (-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3)
			var z = 0.5 * ((2.0 * p1.z) + 
						   (-p0.z + p2.z) * t_normalized + 
						   (2.0 * p0.z - 5.0 * p1.z + 4.0 * p2.z - p3.z) * t2 + 
						   (-p0.z + 3.0 * p1.z - 3.0 * p2.z + p3.z) * t3)

			curve.add_point(Vector3(x, y, z))
	
	return curve

func _setup_path():
	path = Path3D.new()
	path.transform = Transform3D.IDENTITY
	pts = PackedVector3Array()

	var origin = Vector3(110, 22, 100)  # above the landscape
	var order = 2  # level of recursion for Hilbert curve
	var size = 100.0
	_generate_hilbert_curve(order, size, origin, pts)

	# Creating Catmull-Rom spline from the generated points through hilbert curve
	var curve = _create_catmull_rom_spline(pts)
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

	_update_path_mesh()

	
func _update_path_mesh():
	var curve = _create_catmull_rom_spline(pts)
	var points = curve.get_baked_points()
	
	var mesh = ArrayMesh.new()
	var surface_arrays = []  
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	for i in range(points.size() - 1):
		vertices.append(points[i])
		vertices.append(points[i + 1])
		var index_start = i * 2
		indices.append(index_start)
		indices.append(index_start + 1)

	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	surface_arrays[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_arrays)
	path_mesh.mesh = mesh  
		
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

	# Ensure forward vector is not zero
	if forward.length() > 0:  
		var baked_points = path.curve.get_baked_points()
		
		# Calculate the current index based on progress
		var current_index = floor(pfollow.progress_ratio * (baked_points.size() - 1))
		var next_index = min(current_index + 1, baked_points.size() - 1)

		# Get the tangent vector
		var tangent = (baked_points[next_index] - baked_points[current_index]).normalized()

		# Create a rotation basis using the tangent vector
		var rotation_basis = Basis(Vector3(0, 1, 0), atan2(tangent.x, tangent.z))
		
		glider.transform.basis = rotation_basis
		
		# glider face
		glider.look_at(pfollow.position + tangent * 10)
		
