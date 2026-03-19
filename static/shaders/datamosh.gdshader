shader_type spatial;

render_mode unshaded, cull_disabled;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D PREVIOUS_TEXTURE;

uniform float active;
uniform vec2 omega;

vec3 apply_contrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

vec2 get_motion_vector(float depth, vec2 uv) {
	vec2 mot = omega;
	return depth * mot * 0.05;
}

float get_pulse(float time, float phase_l, float derive_l){
	return (31.0 + cos(PI * clamp((abs(mod(time, phase_l) - phase_l * 0.5) - phase_l * 0.5 + derive_l) / derive_l, 0.0, 1.0))) * 0.03125;
}

void fragment() {
	float d = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec2 mot = get_motion_vector(d, SCREEN_UV);
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	// test motion vectors
	//ALBEDO = mix(col, vec3(mot, 0.0), 0.5);
	//ALBEDO = vec3(1.0, 0.0, 1.0);
	
	// test 2
	//ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV + mot, 1.0).rgb;
	
	// test 3
	vec2 mvuv = vec2(SCREEN_UV.x-mot.r,SCREEN_UV.y-mot.g);
	float power = active * 0.99 * get_pulse(TIME, 4.0, 1.0);
	ALBEDO = col;
	ALBEDO = mix(ALBEDO, texture(PREVIOUS_TEXTURE, mvuv).rgb, power);
	//ALBEDO = pow(ALBEDO, vec3(1.0 + power * 0.03));
	//ALBEDO = apply_contrast(ALBEDO, 1.0 + power * 0.001);
}
