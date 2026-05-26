shader_type spatial;

render_mode unshaded, cull_disabled;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D PREVIOUS_TEXTURE;

uniform float power;
uniform vec2 omega;

vec3 apply_contrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

vec2 get_motion_vector(float depth, vec2 uv) {
	vec2 mot = omega;
	return depth * mot * 0.05;
}

void fragment() {
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float d = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec2 mot = get_motion_vector(d, SCREEN_UV);
	vec2 mvuv = vec2(SCREEN_UV.x-mot.r,SCREEN_UV.y-mot.g);
	ALBEDO = mix(col, texture(PREVIOUS_TEXTURE, mvuv).rgb, power);
	// test motion vectors
	//ALBEDO = mix(col, vec3(mot, 0.0), 0.5);
	//ALBEDO = vec3(1.0, 0.0, 1.0);`
	
	// test 2
	//ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV + mot, 1.0).rgb;

	// test 3
	//ALBEDO = pow(ALBEDO, vec3(1.0 + power * 0.03));
	//ALBEDO = apply_contrast(ALBEDO, 1.0 + power * 0.001);
}
