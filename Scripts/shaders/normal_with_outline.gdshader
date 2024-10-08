// Mandatory line to define 2D shaders
shader_type canvas_item;

// Allows us to assign a normal map to the shader in the Inspector
uniform sampler2D normal_map : filter_nearest;
uniform float intensity : hint_range(0, 2) = 2.0f;
uniform bool outline_visible = false;
uniform float whiten : hint_range(1, 5) = 1.0f;

const vec2 OFFSETS[4] = {
	vec2(-1, 0), vec2(0, -1), vec2(0, 1), vec2(1, 0)
};

void fragment() {
	// set outline if visible
	if (outline_visible) {
		float outline = 0.0;
		for (int i = 0; i < OFFSETS.length(); i++) {
			outline += texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * OFFSETS[i]).a;
		}
		outline = min(outline, 1.0);
		vec4 color = texture(TEXTURE, UV);
		color *= vec4(whiten, whiten, whiten, 1);
		COLOR = mix(color, vec4(1,1,1,1), outline - color.a);
	}
	// set normal
	NORMAL = intensity * texture(normal_map, UV).rgb - 1.0;
}