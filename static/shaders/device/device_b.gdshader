shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

void fragment() {
	ALBEDO = vec4(0.0, 0.0, 0.8 - abs(cos(TIME * 0.21)), 1.0).rgb;
	EMISSION = vec4(0.0, 0.0, 0.8 - abs(sin(TIME * 0.563 + 43.3)), 0.8 - abs(sin(TIME * 0.1213 + 43.3))).rgb;
}
