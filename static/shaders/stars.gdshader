shader_type spatial;
render_mode unshaded, cull_disabled;

group_uniforms MainStars;
// Main star adjustments
uniform sampler2D gradientA;
uniform float horizontalMovement: hint_range(-2.0, 2.0, 0.1) = 0.1;
uniform float verticalMovement: hint_range(-2.0, 2.0, 0.1) = 0.1;
uniform float frequencyStar: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float sizeStar: hint_range(10.0, 200.0, 10.0) = 100.0;
uniform float brightnessStar: hint_range(1.0, 5.0, 1.0) = 3.0;
uniform float shineFrequencyStar: hint_range(1.0, 20.0, 1.0) = 8.0;
uniform float transparencyStar: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform int starIterations: hint_range(1, 10, 1) = 3;

group_uniforms BackgroundStars;
// Background star adjustments
uniform sampler2D gradientB;
uniform float frequencyBgStar: hint_range(0.950, 1.0, 0.001) = 0.996;
uniform float shineFrequencyBgStar: hint_range(0.0, 5.0, 1.0) = 1.0;
uniform float transparencyBgStar: hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms Background;
// Background color and transparency
uniform vec4 colorBackground: source_color = vec4(0.05, 0.04, 0.20, 1.0);
uniform float transparencyBackground: hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms Noise;
// Seeding for different noise generation
uniform float seed: hint_range(0.0, 100.0, 1.0) = 0.0;

float rand(vec3 co) {
    return fract(sin(dot(co.xyz, vec3(seed+12.9898, 78.233, 45.543))) * 43758.5453);
}

float remap(float prob, float starValue) {
    return (starValue - prob)/(1.0-prob);
} 

void fragment() {
    // Use UV from skybox projection (normalized direction)
    vec3 uv3d = normalize(VIEW);
    
    // Convert 3D direction to 2D coordinates for star generation
    vec2 uv;
    float maxAxis = max(abs(uv3d.x), max(abs(uv3d.y), abs(uv3d.z)));
    
    if (maxAxis == abs(uv3d.x)) {
        uv = uv3d.x > 0.0 ? uv3d.zy : uv3d.zy * vec2(-1.0, 1.0);
    } else if (maxAxis == abs(uv3d.y)) {
        uv = uv3d.y > 0.0 ? vec2(uv3d.x, -uv3d.z) : vec2(uv3d.x, uv3d.z);
    } else {
        uv = uv3d.z > 0.0 ? uv3d.xy : uv3d.xy * vec2(-1.0, 1.0);
    }
    
    uv = normalize(uv) * (1.0 / maxAxis);
    uv = uv * 0.5 + 0.5;

    float prob = 1.0 - frequencyStar;
    float travelx = TIME * horizontalMovement;
    float travely = TIME * verticalMovement;
    float color = 0.0;
    
    ALBEDO = colorBackground.rgb;
    ALPHA = (1.0 - transparencyBackground);

    // Main stars
    for(int i = 1; i < 1 + starIterations; i++) {
        float size = sizeStar/float(i);
        vec2 pos = vec2(floor((1.0 / size * uv.x * 1000.0) + travelx), 
                        floor((1.0 / size * uv.y * 1000.0) + travely));
        float starValue = rand(vec3(pos, float(i)));
        
        if (starValue > prob) {
            vec2 center = size * pos + vec2(size, size) * 0.5;
            float t = 0.9 + 0.2 * sin(TIME * shineFrequencyStar + (starValue - prob) / (1.0 - prob) * 45.0);
            
            vec2 modifiedCoords = vec2(uv.x * 1000.0 + travelx * size, 
                                     uv.y * 1000.0 + travely * size);
            
            color = 1.0 - distance(modifiedCoords, center) / (0.5 * size);
            color = t * t * brightnessStar / float(i) / 
                   (clamp(distance(modifiedCoords.y, center.y), 0.5, size/2.0-1.0)) / 
                   (clamp(distance(modifiedCoords.x, center.x), 0.5, size/2.0-1.0));
            
            vec4 colormapA = texture(gradientA, vec2(remap(prob, starValue)));
            vec4 COLOR1 = colormapA * color * (1.0 - transparencyStar);
            ALBEDO += COLOR1.rgb;
            ALPHA += COLOR1.a;
        }
    }

    // Background stars
    if (rand(vec3(uv * 20.0, seed)) > frequencyBgStar) {
        float r = rand(vec3(uv, seed + 1.0));
        color = r * (0.85 * sin(TIME * shineFrequencyBgStar * (r * 5.0) + 720.0 * r) + 0.95);
        vec4 colormapB = texture(gradientB, vec2(r));
        vec4 COLOR1 = colormapB * color * (1.0 - transparencyStar);
        ALBEDO += COLOR1.rgb;
        ALPHA += COLOR1.a;
    }
}