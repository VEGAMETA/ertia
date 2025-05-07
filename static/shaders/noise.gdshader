shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scr_tex : hint_screen_texture;

varying vec4 res;

void fragment() {
	COLOR = clamp(texture(scr_tex, SCREEN_UV) + (fract(sin(dot(UV, vec2(23.23, 2323.23-TIME))) * (232323.23 + TIME))) * .23, .0, 0.33);
}