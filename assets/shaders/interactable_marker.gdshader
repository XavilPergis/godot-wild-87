shader_type spatial;
render_mode blend_add;
render_mode cull_disabled;

uniform vec4 color : source_color;
uniform float height;
uniform float emission_strength;
uniform float scroll_offset;
uniform float frequency;
uniform bool disabled;

varying vec3 pos_local;

void vertex() {
	pos_local = VERTEX.xyz;
}

void fragment() {
	float n = max(0.0, sin(frequency * pos_local.y + scroll_offset));
	n = n*n;
	if (disabled) {
		n = 0.0;
	}
	EMISSION = n * emission_strength * color.rgb;
	ALBEDO = color.rgb;
	ALPHA = color.a * pow(1.0 - (pos_local.y + height / 2.0) / height, 2.0);
}
