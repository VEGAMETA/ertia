shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

void fragment() {
	ALBEDO = vec4(0.0, 0.2 - abs(cos(TIME * 0.21) ), 0.2 - abs(cos(TIME * 0.21)), 1.0).rgb;
	EMISSION = vec4(0.0, 0.8 - abs(sin(TIME * 0.563 + 23.13)), 0.8 - abs(sin(TIME * 0.563 + 23.13)), 0.8 - abs(sin(TIME * 0.1213))).rgb;
}