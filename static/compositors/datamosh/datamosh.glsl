#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout(rg16f, set = 1, binding = 0) uniform image2D velocity_image;
layout(rgba16f, set = 2, binding = 0) uniform image2D previous_image;

// Our push PushConstant
layout(push_constant, std430) uniform Params {
	int sizex;
	int sizey;
	int time;
    int amount;
} params;

float nrand(vec2 v) {
    return fract(sin(dot(v, vec2(12.9898, 78.233))) * 43758.5453);
}

// The code we want to execute in each invocation
void main() {
	//ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    //ivec2 size = ivec2(params.sizex, params.sizey);
	//if (uv.x >= size.x || uv.y >= size.y) return;
	
	//vec4 clean = imageLoad(color_image, uv);

    //float amount = clamp(float(params.amount) / 100.0, 0.0, 1.0);
	//if (amount >= 1.0) {
//		imageStore(color_image, uv, imageLoad(previous_image, uv));
	//	return;
	//}
	
//	ivec2 block_uv = uv;
//	float rnd = nrand(vec2(block_uv + float(params.time)));
	//rnd = clamp(rnd, 0.01, 0.99);
	//vec2 vel = imageLoad(velocity_image, block_uv).rg;

	//if (rnd < amount) {
      //  imageStore(color_image, uv, imageLoad(previous_image, uv));
        //return;
    //}
	
	//float speed = length(vel);
	
	//vec2 offset = vel * vec2(size) * speed;
	//ivec2 src_uv = uv + ivec2(offset);
	
//    src_uv = clamp(src_uv, ivec2(0), size - ivec2(1));

	//vec4 mosh = imageLoad(previous_image, uv);
	//float decay = exp(-speed * 40.0);
	
	//vec4 relaxed = mix(mosh, clean, speed);
	//imageStore(color_image, uv, relaxed);
	
	
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	vec2 mot = imageLoad(velocity_image, uv).rg;
	vec4 out_col = imageLoad(color_image, uv);
	
	if (mot.r > -1.) {
		out_col.r += mot.r;
	}
	if (mot.g > -1.) {
		out_col.g += mot.g;
	}
	
	imageStore(color_image, uv, out_col);
	
	
	
}