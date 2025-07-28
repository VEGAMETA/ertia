shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scr_tex : hint_screen_texture;

varying vec4 res;

vec2 random(vec2 uv) {
return vec2(fract(sin(dot(uv.xy,
	vec2(12.9898,78.233))) * 43758.5453123));
}

//vec4 my_rand(vec2 uv){
	//return vec4();
//}

void fragment() {
	COLOR = clamp(texture(scr_tex, SCREEN_UV) + (fract(sin(dot(UV, vec2(23.23, 2323.23-TIME)))) * (232323.23 + TIME)) * 0.23, .0, 0.33);
}