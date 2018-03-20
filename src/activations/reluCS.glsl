#version 310 es
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
precision highp float;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D x;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  vec4 v = texelFetch(x, ivec2(gl_GlobalInvocationID.xy), 0);
  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), max(v, 0.0));
}
