import _ from 'lodash'

/**
 * Create GLSL program for merge.Add layer
 *
 * @param {number} numInputs
 * @param {number[]} shape
 */
export default function add(numInputs, shape) {
  const source = `#version 310 es
  #define TILE_WIDTH 32
  #define TILE_HEIGHT 32
precision highp float;

layout(local_size_x=TILE_WIDTH, local_size_y=TILE_HEIGHT) in;
uniform sampler2D inputs[${numInputs}];
layout(r32f, binding = 4) writeonly uniform highp image2D  outColor;

void main() {
  vec4 result = vec4(${_.range(numInputs)
    .map(i => `texelFetch(inputs[${i}], ivec2(gl_GlobalInvocationID.xy), 0).r`)
    .join(' + ')});
  imageStore(outColor, ivec2(gl_GlobalInvocationID.xy), result);
}
`

  return source
}
