shader_type spatial;
render_mode cull_front, unshaded, blend_mix;
uniform float alpha = 0.6;
uniform vec3 gravity_vector = vec3(0.0, 0.0, -1.0);
const vec3 one = vec3(1.0);
const float zero = 0.0;

void fragment() {
	float ndotv = dot(normalize(NORMAL), normalize(VIEW));
	ALPHA = pow(ndotv * 0.9, 5);
	vec3 p = max(gravity_vector, vec3(0.0));
	vec3 n = max(-gravity_vector, vec3(0.0));
	vec3 gv = vec3(
		p.x + n.y + n.z,
		p.y + n.x + n.z,
		p.z + n.x + n.y
	);
	ALBEDO = gv;
}
