shader_type canvas_item;

uniform sampler2D texture;
uniform vec2 direction = vec2(0.0, 1);
uniform vec4 transparency = vec4(1.0, 1.0, 1.0, 0.3);
uniform float skewAmt = 0.0;

void fragment() {
	vec2 skewed = vec2(skewAmt * UV.y + skewAmt * -0.5, 0.0);
	COLOR = texture(TEXTURE, UV+TIME*direction + skewed)*transparency;
}