#[compute]
#version 450

// Invocations in the (x, y, z) dimensions
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set=0, binding=0) uniform image2D color_image; 
layout(rgba16f, set=1, binding=0) uniform image2D velocity_image;

// The code we want to execute in each invocation

void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	
    ivec2 fgrid=ivec2(vec2(uv)/30.0)*30;

    vec4 color = imageLoad(color_image, uv);
    vec4 gridcolor = imageLoad(color_image,fgrid); 

    // velocity can be negative
    vec4 velocity = imageLoad(velocity_image, uv); 
    float velocity_mask = step(length(velocity),1.0); 
    //velocity_mask = 1.0 - velocity_mask; 
    //vec3 mixresult = mix(color.rgb, gridcolor.rgb,velocity_mask);
    //vec3 mixresult = mix(gridcolor.rgb, color.rgb, velocity_mask);
    //vec4 res = vec4(mixresult,1.0);  
    // vec4 res = vec4(vec3(velocity_mask),1.0); 
    
    imageStore(color_image, uv, velocity);
}