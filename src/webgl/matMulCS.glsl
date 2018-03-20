#version 310 es
  #define TILE_WIDTH 32
  #define TILE_HEIGHT 32
precision highp float;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D A;
uniform sampler2D B;
uniform sampler2D C;
uniform bool addC;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  ivec2 A_size = textureSize(A, 0);
  int commonDim = A_size[0];

  float sum = 0.;
  for (int i = 0; i < commonDim; ++i) {
    float a = texelFetch(A, ivec2(i, gl_GlobalInvocationID.y), 0).r;
    float b = texelFetch(B, ivec2(gl_GlobalInvocationID.x, i), 0).r;
    sum += a * b;
  }

  if (addC) {
    sum += texelFetch(C, ivec2(gl_GlobalInvocationID.x, 0), 0).r;
  }

  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), vec4(sum));
}
