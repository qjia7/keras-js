#version 310 es
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
precision highp float;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D x;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  ivec2 size = textureSize(x, 0);

  float maxval = 0.0;
  for (int i = 0; i < int(size[0]); ++i) {
    float val = texelFetch(x, ivec2(i, gl_GlobalInvocationID.y), 0).r;
    if (i == 0 || val > maxval) {
      maxval = val;
    }
  }

  float sum = 0.0;
  for (int i = 0; i < int(size[0]); ++i) {
    float val = texelFetch(x, ivec2(i, gl_GlobalInvocationID.y), 0).r;
    sum += exp(val - maxval);
  }

  float result = exp(texelFetch(x, ivec2(gl_GlobalInvocationID.x, gl_GlobalInvocationID.y), 0).r - maxval) / sum;
  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), vec4(result));
}
