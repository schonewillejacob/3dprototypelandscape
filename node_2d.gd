extends Node3D

var land: MeshInstance3D
var noise = FastNoiseLite.new()


func created_texture(wid: int, height: int) -> ImageTexture:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
	noise.fractal_gain = 0.5
	noise.fractal_ping_pong_strength = 10
	noise.fractal_weighted_strength = 1.5
	noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	noise.domain_warp_fractal_octaves = 16
	
	noise.frequency = 0.0019
	noise.fractal_lacunarity = 1.5
	noise.fractal_octaves = 5.0
	noise.seed = 14  

	var image = noise.get_seamless_image(wid, height)
	for i in range(wid):
		for j in range(height):
			var noise_val = (image.get_pixel(i, j).r + 1) / 2  # add an offset to the noise value
			var brown_color = Color(0.2, 0.05, 0.1)  # Brown color
			var colored_pixel = Color(
				brown_color.r * noise_val,
				brown_color.g * noise_val,
				brown_color.b * noise_val,
				1.0
			)
			image.set_pixel(i, j, colored_pixel)
	return ImageTexture.create_from_image(image)

func _ready() -> void:
	land = MeshInstance3D.new()
	var st  = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count : Array[int] = [0]
	var texture = created_texture(500, 400)
	var mesh_material = StandardMaterial3D.new()
	mesh_material.albedo_texture = texture
	mesh_material.vertex_color_use_as_albedo = true

	for x in range(256):
		for y in range(256):
			var v1 = noise.get_noise_2d(x, y) * 10
			var v2 = noise.get_noise_2d(x+1, y) * 10
			var v3 = noise.get_noise_2d(x+1, y+1) * 10
			var v4 = noise.get_noise_2d(x, y+1) * 10
			create_quad(st, Vector3(x,0,y), count, v1, v2, v3, v4)

	st.generate_normals()
	land.mesh = st.commit()
	land.material_override = mesh_material
	add_child(land)

func create_quad(
st:SurfaceTool,
pt : Vector3,
count: Array[int],
h1,
h2,
h3,
h4
):
	var brown_color = Color(0.55,0.1,0.1)
	
	st.set_uv(Vector2(0,0))
	st.set_color(brown_color * ((h1 + 1) / 2))
	st.add_vertex(pt+ Vector3(0,h1,0))
	count[0] += 1
	st.set_uv(Vector2(1,0))
	st.set_color(brown_color * ((h2 + 1) / 2))
	st.add_vertex(pt+ Vector3(1,h2,0))
	count[0] += 1
	st.set_uv(Vector2(1,1))
	st.set_color(brown_color * ((h3 + 1) / 2))
	st.add_vertex(pt+ Vector3(1,h3,1))
	count[0] += 1
	st.set_uv(Vector2(0,1))
	st.set_color(brown_color * ((h4 + 1) / 2))
	st.add_vertex(pt+ Vector3(0,h4,1))
	count[0] += 1

	st.add_index(count[0]-4)
	st.add_index(count[0]-3)
	st.add_index(count[0]-2)

	st.add_index(count[0]-4)
	st.add_index(count[0]-2)
	st.add_index(count[0]-1)

	
