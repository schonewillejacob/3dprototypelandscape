extends MeshInstance3D



# MEMBERS ######################################################################
@onready var node_noise_preview_ui = $CloudNoisePreview
const NOISE_DIMENSIONS = Vector2i(256, 256)
var HEIGHT = transform.origin.y


# HELPERS ######################################################################
func generate_blended_clouds(landscape_noise : FastNoiseLite):
	# construct noise w/ parameters
	var _cloud_material = StandardMaterial3D.new()
	_cloud_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var _cloud_image = Image.create_empty(NOISE_DIMENSIONS.x, NOISE_DIMENSIONS.y, 
										  false, Image.FORMAT_RGBAF)
	
	
	# get extremes
	var _noise_limits : = Vector2(1,-1) # noise texture never generates outside (-1, 1)
	#.x = low
	#.y = high
	for _x in NOISE_DIMENSIONS.x:
		for _y in NOISE_DIMENSIONS.y:
			var _noise_sample = landscape_noise.get_noise_2d(_x, _y)
			if _noise_sample < _noise_limits.x: _noise_limits.x = _noise_sample
			if _noise_sample > _noise_limits.y: _noise_limits.y = _noise_sample
	var _noise_range = _noise_limits.y - _noise_limits.x
	
	for _x in NOISE_DIMENSIONS.x:
		for _y in NOISE_DIMENSIONS.y:
			var _noise_sample = landscape_noise.get_noise_2d(_x, _y)
			var _noise_color : Color
			if _noise_sample > 0.15: 
				# above certain noise height, we lighten the clouds to make them appear bunched against hilltops
				_noise_color = Color(Color.SLATE_GRAY, 
									(_noise_sample + abs(_noise_limits.x)) / ((_noise_range * 4.0) - (_noise_sample * 5.0))
									)
			else:
				_noise_color = Color(Color.SLATE_GRAY, (_noise_sample + abs(_noise_limits.x)) / (_noise_range * 4.0))
			
			_cloud_image.set_pixel(_x, _y, _noise_color)
	
	
	var _noise_texture = ImageTexture.create_from_image(_cloud_image)
	_cloud_material.albedo_texture = _noise_texture
	node_noise_preview_ui.texture = _noise_texture
	mesh.material = _cloud_material

# SIGNALS ######################################################################
func _on_landscape_noise_generated(landscape_noise: FastNoiseLite) -> void:
	generate_blended_clouds(landscape_noise)
