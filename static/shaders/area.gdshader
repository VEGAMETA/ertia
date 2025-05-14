shader_type spatial;
//render_mode cull_front;

//render_mode alpha_to_coverage;


uniform vec3 col = vec3(1.0);
uniform float alpha = 0.12;
//uniform float size = 1.0;

void vertex() {
    //VERTEX /= size/(size*0.99);
}

void fragment() {
	DEPTH = FRAGCOORD.z - .000001;
	ALBEDO = col;
	ALPHA = alpha;
	//EMISSION = col;
}