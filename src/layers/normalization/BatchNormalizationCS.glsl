#version 310 es
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
precision highp float;
precision highp isampler2D;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D X;
uniform isampler2D normAxisIndexMap;
uniform sampler2D gamma;
uniform sampler2D beta;
uniform sampler2D mean;
uniform sampler2D std;
uniform float epsilon;
uniform bool scale;
uniform bool center;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
int normAxisIndex = texelFetch(normAxisIndexMap, ivec2(gl_GlobalInvocationID.xy), 0).r;

  float _x = texelFetch(X, ivec2(gl_GlobalInvocationID.xy), 0).r;
  float _mean = texelFetch(mean, ivec2(normAxisIndex, 0), 0).r;
  float _std = texelFetch(std, ivec2(normAxisIndex, 0), 0).r;

  float _gamma = 1.0;
  if (scale) {
    _gamma = texelFetch(gamma, ivec2(normAxisIndex, 0), 0).r;
  }

  float _beta = 0.0;
  if (center) {
    _beta = texelFetch(beta, ivec2(normAxisIndex, 0), 0).r;
  }

  float sum = _beta + _gamma * (_x - _mean) / sqrt(_std + epsilon);

  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), vec4(sum));
}
