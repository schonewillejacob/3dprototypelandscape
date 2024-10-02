extends Node3D



# MEMBERS ######################################################################
var Y_SCALE : float = 20.0
var UV_BRIGHTNESS_SCALE = 1.0
var NOISE_TEXTURE_DIMENSIONS = Vector2i(512, 512)
var GRID_DIMENSIONS = Vector2i(64, 64)



# VIRTUALS #####################################################################
func _ready() -> void:
	var land = MeshInstance3D.new()
	
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	
	var noise = FastNoiseLite.new()
	var image = noise.get_image(NOISE_TEXTURE_DIMENSIONS.x, NOISE_TEXTURE_DIMENSIONS.y)
	var texture = ImageTexture.create_from_image(image)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var count : Array[int] = [0]
	for i in range(GRID_DIMENSIONS.x):
		for j in range(GRID_DIMENSIONS.y):
			var _noise_1 = noise.get_noise_2d(i, j) 	# bottom-left
			var _noise_2 = noise.get_noise_2d(i+1, j)	# bottom-right
			var _noise_3 = noise.get_noise_2d(i+1, j+1)# top-right
			var _noise_4 = noise.get_noise_2d(i, j+1)	# top-left
			
			create_quad(st, Vector3(i,0,j), count, _noise_1, _noise_2, _noise_3, _noise_4)
	
	st.generate_normals() # normals point perpendicular up from each face
	var mesh = st.commit() # arranges mesh data structures into arrays for us
	land.mesh = mesh
	land.material_override = material
	add_child(land)
	pass 



# METHODS ######################################################################
func create_quad(
	st : SurfaceTool,
	pt: Vector3,
	count: Array[int],
	noiseVal1,
	noiseVal2,
	noiseVal3,
	noiseVal4,
	):
	
	var dark_val1 : float = noiseVal1 * UV_BRIGHTNESS_SCALE
	var dark_val2 : float = noiseVal2 * UV_BRIGHTNESS_SCALE
	var dark_val3 : float = noiseVal3 * UV_BRIGHTNESS_SCALE
	var dark_val4 : float = noiseVal4 * UV_BRIGHTNESS_SCALE
	
	st.set_color(Color(dark_val1, dark_val1, dark_val1, 1))
	st.set_uv( Vector2(0, 0) )
	st.add_vertex(pt + Vector3(0, noiseVal1 * Y_SCALE, 0) ) # vertex 0
	count[0] += 1
	st.set_color(Color(dark_val2, dark_val2, dark_val2, 1))
	st.set_uv( Vector2(1, 0) )
	st.add_vertex(pt +  Vector3(1, noiseVal2 * Y_SCALE, 0) ) # vertex 1
	count[0] += 1
	st.set_color(Color(dark_val3, dark_val3, dark_val3, 1))
	st.set_uv( Vector2(1, 1) )
	st.add_vertex(pt +  Vector3(1, noiseVal3 * Y_SCALE, 1) ) # vertex 2
	count[0] += 1
	st.set_color(Color(dark_val4, dark_val4, dark_val4, 1))
	st.set_uv( Vector2(0, 1) )
	st.add_vertex(pt +  Vector3(0, noiseVal4 * Y_SCALE, 1) ) # vertex 3
	count[0] += 1
	
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
