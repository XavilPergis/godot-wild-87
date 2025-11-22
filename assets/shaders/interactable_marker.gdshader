shader_type spatial;
render_mode blend_add;
render_mode cull_disabled;

uniform vec4 color : source_color;
uniform float height;
uniform float scroll_offset;
uniform bool disabled = false;
uniform float emission_strength = 5.0;
uniform float frequency = 30.0;
uniform float band_power = 1.0;
uniform float alpha_power = 2.0;

varying vec3 pos_local;

void vertex() {
	pos_local = VERTEX.xyz;
}

void fragment() {
	float n = 0.0;
	if (!disabled) {
		n = max(0.0, sin(frequency * pos_local.y + scroll_offset));
		n = pow(n, band_power);
	}
	EMISSION = n * emission_strength * color.rgb;
	ALBEDO = color.rgb;

	float t = clamp((pos_local.y + 0.5 * height) / height, 0.0, 1.0);
	ALPHA = color.a * pow(1.0 - t, alpha_power);
}
