shader_type spatial;

uniform bool is_active = false;

void fragment() {
	EMISSION = is_active ? vec3(0., 1., 0.) : vec3(1., 0., 0.);
}
