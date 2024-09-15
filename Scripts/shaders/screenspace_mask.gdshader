shader_type canvas_item;

uniform sampler2D mask_texture_h;
uniform sampler2D mask_texture_v;

void fragment() {
	if (COLOR.rgb == vec3(0.0, 0.0, 0.0)) {
		COLOR.a = 0.0f;
	}
	COLOR.a -= texture(mask_texture_h, SCREEN_UV).r;
	COLOR.a -= texture(mask_texture_v, vec2(SCREEN_UV.y, SCREEN_UV.x)).r;
}
