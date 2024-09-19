// Mandatory line to define 2D shaders
shader_type canvas_item;

// Allows us to assign a normal map to the shader in the Inspector
uniform sampler2D normal_map : filter_nearest;
uniform float intensity : hint_range(0, 2) = 2.0f;

void fragment(){
	// Converts the texture data into a unit vector, with each channel in the [-1, 1] range
	NORMAL = intensity * texture(normal_map, UV).rgb - 1.0;
}