shader_type canvas_item;

uniform sampler2D t0 : hint_screen_texture;
uniform float bloom_spread = 1;
uniform float bloom_intensity = 2;

void fragment() {
    vec2 pixel = 1.0 / vec2(textureSize(t0, 0));
    vec2 spread = pixel * bloom_spread;

    vec4 sum = vec4(0.0);

    for (int i = -4; i <= 4; i++) {
        float offset = float(i);
        sum += texture(t0, SCREEN_UV + vec2(offset * spread.x, 0.0));
    }

    for (int i = -4; i <= 4; i++) {
        float offset = float(i);
        sum += texture(t0, SCREEN_UV + vec2(0.0, offset * spread.y));
    }

    sum /= 18.0;

    vec4 base = texture(t0, SCREEN_UV);
    COLOR = base + sum * bloom_intensity;
}