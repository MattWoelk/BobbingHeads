shader_type canvas_item;

uniform float saturation: hint_range(0.0, 1.0) = 1.0;

vec2 circle() {
	return vec2(cos(TIME * 2.0), sin(TIME * 3.7));
}

// From https://godotshaders.com/shader/desaturation-shader/
void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114))), tex_color.rgb, saturation);
	COLOR.a = tex_color.a;
}