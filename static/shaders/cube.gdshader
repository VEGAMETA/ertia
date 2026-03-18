shader_type spatial;
render_mode cull_front, unshaded;

uniform float alpha = 0.6;

const vec3 one = vec3(1.0);
const float zero = 0.0;

void fragment() {
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, zero)).xyz;
	vec3 rounded_normal = round(world_normal);
	ALBEDO = dot(one, rounded_normal) < zero ? -rounded_normal : cross(cross(rounded_normal, one), rounded_normal);
	ALPHA = alpha;
}
