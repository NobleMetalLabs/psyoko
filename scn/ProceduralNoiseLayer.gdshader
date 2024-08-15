shader_type canvas_item;
uniform bool enable_threshold = false;
uniform float threshold : hint_range(0, 1);
uniform bool transparent_black = false;
uniform bool transparent_white = false;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	if (enable_threshold) {
		COLOR.rgb = vec3(float(COLOR.r > float(threshold)));
	}

	COLOR.a -= (COLOR.r) * float(transparent_white);
	COLOR.a -= (1.0 - COLOR.r) * float(transparent_black);
}
