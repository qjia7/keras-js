#version 310 es
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
precision highp float;
precision highp isampler2D;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D x;
uniform isampler2D poolIndexMap;
uniform int channels;
uniform int poolSize;
uniform bool isMaxPooling;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  float val = 0.;
  int count = 0;
  for (int i = 0; i < poolSize; ++i) {
    int poolIndex = texelFetch(poolIndexMap, ivec2(i, gl_GlobalInvocationID.y), 0).r;
    if (poolIndex != -1) {
      float val2 = texelFetch(x, ivec2(gl_GlobalInvocationID.x, poolIndex), 0).r;
      if (isMaxPooling) {
        if (count == 0 || val2 > val) {
          val = val2;
        }
      } else {
        val += val2;
      }
      count += 1;
    }
  }

  if (!isMaxPooling) {
    val /= float(count);
  }

  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), vec4(val));
}
