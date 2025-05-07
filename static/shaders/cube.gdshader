shader_type spatial;
render_mode cull_front, unshaded;

uniform float max_alpha = 0.6;
uniform float alpha = 0.6;

const vec3 one = vec3(1.0);

void fragment() {
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 rounded_normal = round(world_normal);
	ALBEDO = dot(one, rounded_normal) < 0.0 ? -rounded_normal : cross(cross(rounded_normal, one), rounded_normal);
	ALPHA = alpha;
}
