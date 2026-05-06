shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// ===================== Global transform (approx) =====================
uniform vec2 skew = vec2(0.0, 0.0);         // shears the quad (approx UI skew)
uniform float rotation = 0.0;               // radians
uniform vec2 pivot_uv = vec2(0.5, 0.5);     // pivot in UV space (0..1)
uniform float transform_gain = 200.0;       // tweak strength of UV-based transform

uniform bool instance_shake_on = false;
uniform float instance_shake_seed = 1.0;    // set different values per Label
uniform float shake_speed = 10.0;           // speed
uniform vec2 shake_pos_px = vec2(2.0, 2.0); // amplitude in pixels (local)
uniform float shake_rot_deg = 0.0;          // amplitude in degrees
uniform float shake_scale = 0.0;            // amplitude (0.03 = 3%)

// ===================== Helpers =====================

vec2 rot2(vec2 p, float a){
	float s = sin(a), c = cos(a);
	return vec2(c*p.x - s*p.y, s*p.x + c*p.y);
}

float soften01(float x, float softness){
	float s = clamp(softness, 0.0, 1.0);
	return smoothstep(0.0, mix(0.02, 0.25, s), x);
}

void vertex() {
	// --- UV-based skew/rotation (approx for UI) ---
	vec2 d = UV - pivot_uv;

	VERTEX.x += d.y * skew.x * transform_gain;
	VERTEX.y += d.x * skew.y * transform_gain;

	vec2 q = d * transform_gain;
	vec2 rq = rot2(q, rotation);
	VERTEX += (rq - q);

	// --- Instance shake (whole node) ---
	if (instance_shake_on) {
		float t = TIME * shake_speed;

		float n1 = sin(t + instance_shake_seed * 10.13);
		float n2 = sin(t * 1.37 + instance_shake_seed * 27.91);
		float n3 = sin(t * 0.83 + instance_shake_seed * 3.77);

		// Position shake
		VERTEX += vec2(n1 * shake_pos_px.x, n2 * shake_pos_px.y);

		// Extra rotation shake (approx around pivot)
		float r = radians(shake_rot_deg) * n3;
		vec2 qq = d * transform_gain;
		vec2 rrq = rot2(qq, r);
		VERTEX += (rrq - qq);

		// Uniform scale shake (approx around pivot)
		float s = 1.0 + (shake_scale * n2);
		vec2 sq = qq * s;
		VERTEX += (sq - qq);
	}
}
