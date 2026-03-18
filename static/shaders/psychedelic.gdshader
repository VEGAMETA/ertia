shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D feedback_tex;

uniform float feedback = 0.94;
uniform float symmetry_power = 0.25;
uniform float edge_gain = 1.5;
uniform float time_scale = 0.2;

vec2 rotate(vec2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return vec2(c*p.x - s*p.y, s*p.x + c*p.y);
}

vec3 sobel(sampler2D tex, vec2 uv, vec2 px) {
    float gx =
        texture(tex, uv + px*vec2(-1,-1)).r +
        texture(tex, uv + px*vec2(-1, 1)).r -
        texture(tex, uv + px*vec2( 1,-1)).r -
        texture(tex, uv + px*vec2( 1, 1)).r;

    float gy =
        texture(tex, uv + px*vec2(-1,-1)).r +
        texture(tex, uv + px*vec2( 1,-1)).r -
        texture(tex, uv + px*vec2(-1, 1)).r -
        texture(tex, uv + px*vec2( 1, 1)).r;

    return vec3(length(vec2(gx, gy)));
}

vec3 multi_symmetry(vec2 uv, float t) {
    vec3 acc = vec3(0.0);
    float wsum = 0.0;

    for (int i = 0; i < 5; i++) {
        float fi = float(i);

        // дрейфующий центр
        vec2 center = vec2(
            0.5 + sin(t*0.3 + fi)*0.15,
            0.5 + cos(t*0.27 + fi)*0.15
        );

        // дрейфующий угол
        float angle = t*0.1 + fi * 1.256;

        vec2 p = uv - center;
        p = rotate(p, angle);
        p.x = abs(p.x); // отражение
        p = rotate(p, -angle);
        p += center;

        float w = 1.0 / (1.0 + fi);
        acc += texture(screen_texture, p).rgb * w;
        wsum += w;
    }

    return acc / wsum;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 px = 1.0 / vec2(textureSize(screen_texture, 0));
    float t = TIME * time_scale;

    vec3 base = texture(screen_texture, uv).rgb;

    // поле симметрий
    vec3 sym = multi_symmetry(uv, t);

    // контуры
    vec3 edges = sobel(screen_texture, uv, px) * edge_gain;

    // обратная связь
    vec3 prev = texture(feedback_tex, uv).rgb;

    vec3 color =
        mix(base, sym, symmetry_power) +
        edges * 0.6;

    color = mix(color, prev, feedback);

    COLOR = vec4(color, 1.0);
}
