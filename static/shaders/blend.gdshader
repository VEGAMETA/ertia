shader_type canvas_item;
//render_mode blend_mul;

uniform sampler2D new_text;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float alpha: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform int blend_type: hint_enum(
	"Normal", 
	"Multiply",
	"Screen",
	"Darken",
	"Lighten",
	"Difference",
	"Exclusion",
	"Overlay",
	"Hard Light",
	"Soft Light",
	"Color Dodge",
	"Light Dodge",
	"Color Burn",
	"Linear Burn"
) = 0;

vec4 multiply(vec4 base, vec4 blend){
	return base * blend;
}
vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}
vec4 darken(vec4 base, vec4 blend){
	return min(base, blend);
}
vec4 lighten(vec4 base, vec4 blend){
	return max(base, blend);
}
vec4 difference(vec4 base, vec4 blend){
	return abs(base - blend);
}
vec4 exclusion(vec4 base, vec4 blend){
	return base + blend - 2.0 * base * blend;
}
vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
vec4 hard_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
vec4 soft_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}
vec4 color_dodge(vec4 base, vec4 blend){
	return base / (1.0 - blend);
}
vec4 linear_dodge(vec4 base, vec4 blend){
	return base + blend;
}
vec4 color_burn(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) / blend;
}
vec4 linear_burn(vec4 base, vec4 blend){
	return base + blend - 1.0;
}
void fragment() {
	//COLOR = texture(new_text, UV);
	COLOR = mix(texture(SCREEN_TEXTURE, SCREEN_UV), COLOR,  1.0);
	switch (blend_type){
		case 0: break;
		case 1: COLOR = multiply(COLOR, texture(new_text, UV)); break;
		case 2: COLOR = screen(COLOR, texture(new_text, UV)); break;
		case 3: COLOR = darken(COLOR, texture(new_text, UV)); break;
		case 4: COLOR = lighten(COLOR, texture(new_text, UV)); break;
		case 5: COLOR = difference(COLOR, texture(new_text, UV)); break;
		case 6: COLOR = exclusion(COLOR, texture(new_text, UV)); break;
		case 7: COLOR = overlay(COLOR, texture(new_text, UV));  break;
		case 8: COLOR = hard_light(COLOR, texture(new_text, UV));break;
		case 9: COLOR = soft_light(COLOR, texture(new_text, UV)); break;
		case 10: COLOR = color_dodge(COLOR, texture(new_text, UV)); break;
		case 11: COLOR = linear_dodge(COLOR, texture(new_text, UV)); break;
		case 12: COLOR = color_burn(COLOR, texture(new_text, UV)); break;
		case 13: COLOR = linear_burn(COLOR, texture(new_text, UV)); break;
	};
	COLOR.a *= alpha;
}
