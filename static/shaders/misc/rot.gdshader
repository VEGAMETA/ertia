shader_type spatial;

render_mode cull_front, unshaded, blend_mix;
const float alpha = 0.6;
const vec3 one = vec3(1.0);
const float zero = 0.0;

const float rotation_speed = 0.15;
const float bounce_speed = 0.5;
const float bounce_height = 0.5;


void vertex() {
    float time = TIME;
    float y_offset = sin(time*bounce_speed)*bounce_height;
    VERTEX.x += y_offset;
    float angle = time * rotation_speed;
    float s = sin(angle);
    float c = cos(angle);
    
    mat4 rot_matrix = mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, c, s, 0.0),
        vec4(0.0, -s, c, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
    VERTEX = (rot_matrix * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float ndotv = dot(normalize(NORMAL), normalize(VIEW));
	ALPHA = pow(ndotv * 0.9, 5);
	float ra = sin(float(TIME)* rotation_speed);
	float rb = cos(float(TIME)* rotation_speed);
	vec3 gravity_vector = vec3(abs(-ra), abs(ra), 0);
	vec3 p = max(gravity_vector, vec3(0.0));
	vec3 n = max(-gravity_vector, vec3(0.0));
	vec3 gv = vec3(
		p.x + n.y + n.z,
		p.y + n.x + n.z,
		p.z + n.x + n.y
	);
	ALBEDO = gv;
}
