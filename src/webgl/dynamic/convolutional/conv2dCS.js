/**
 * Create GLSL program for convolutional.Conv2D layer
 *
 * @param {number[]} outputShape
 * @param {number[]} inputShape
 * @param {number[]} indexMapShape
 * @param {boolean} useBias
 * @param {boolean} [hasFragments]
 */
export default function conv2d(outputShape, inputShape, indexMapShape, useBias, hasFragments) {
  const addBias = useBias ? `sum += texelFetch(bias, ivec2(samplePos.x, 0), 0).r;` : ''

  const adjustIndicesForFragments = hasFragments
    ? `int fragmentIndex = int(floor(float(rowIndex) / float(${inputShape[0]})));
      rowIndex = int(mod(float(rowIndex), float(${inputShape[0]})));
      colIndex += fragmentIndex * ${inputShape[1]};`
    : ''

  const source = `#version 310 es
  #define TILE_WIDTH 32
  #define TILE_HEIGHT 32
precision highp float;
precision highp isampler2D;

const ivec2 tileSize = ivec2(TILE_WIDTH, TILE_HEIGHT);
layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D x;
uniform isampler2D indexMap;
uniform sampler2D kernel;
uniform sampler2D bias;
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  ivec2 tile_xy = ivec2(gl_WorkGroupID);
  ivec2 thread_xy = ivec2(gl_LocalInvocationID);
  ivec2 samplePos = tile_xy * tileSize + thread_xy;
  float sum = 0.;
  for (int i = 0; i < ${indexMapShape[1]}; ++i) {
    int index = texelFetch(indexMap, ivec2(i, samplePos.y), 0).r;
      if (index != -1) {
      int rowIndex = int(floor(float(index) / float(${inputShape[1]})));
      int colIndex = int(mod(float(index), float(${inputShape[1]})));
      ${adjustIndicesForFragments}
      sum += texelFetch(x, ivec2(colIndex, rowIndex), 0).r * texelFetch(kernel, ivec2(samplePos.x, i), 0).r;
    }
  }

  ${addBias}
  imageStore(outColor, ivec2(samplePos.xy), vec4(sum));
}
`

  return source
}
