shader_type canvas_item;

uniform sampler2D texture : filter_nearest, repeat_enable;
uniform float scale = 7.0f;
const vec2 direction = vec2(0.5, 0.2);
const vec2 direction2 = vec2(-0.5, 0);

void fragment() {
	vec2 uv = round(0.5+UV * scale) / scale;
	COLOR.rgb = COLOR.rgb - 0.15*(texture(texture, uv+TIME*direction) + texture(texture, uv+TIME*direction2)-0.5).rgb;
}
