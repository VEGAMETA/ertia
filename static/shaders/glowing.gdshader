shader_type spatial;


const vec3 a = vec3(0.1, 0.3, 1.0);

void fragment() {
	EMISSION = a * ((1.0 + sin(TIME * 3.0)) / 5.0);
	ALPHA = 0.15;
}
