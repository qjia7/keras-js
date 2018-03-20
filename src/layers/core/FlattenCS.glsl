#version 310 es
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
precision highp float;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D x;
uniform int outputSize;
uniform int inputCols;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  int i = int(floor(float(gl_GlobalInvocationID.x) / float(inputCols)));
  int j = int(mod(float(gl_GlobalInvocationID.x), float(inputCols)));
  vec4 result = vec4(texelFetch(x, ivec2(j, i), 0).r);
  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), result);
}
