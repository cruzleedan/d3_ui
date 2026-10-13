#version 460 core

// A soft, slow aurora: three blurred colour blobs drifting over the surface
// colour. It only tints: the blend is capped at uStrength, so text on top keeps
// its contrast (the showcase tests the worst case for every brand).

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uStrength;
uniform vec3 uBase;
uniform vec3 uA;
uniform vec3 uB;
uniform vec3 uC;

out vec4 fragColor;

float blob(vec2 p, vec2 c, float radius) {
  vec2 d = p - c;
  return exp(-dot(d, d) / (radius * radius));
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float aspect = uSize.x / uSize.y;
  vec2 p = vec2(frag.x / uSize.y, frag.y / uSize.y);

  float t = uTime * 0.12;
  vec2 ca = vec2(aspect * (0.20 + 0.10 * sin(t * 1.1)), 0.35 + 0.18 * sin(t * 0.9 + 1.0));
  vec2 cb = vec2(aspect * (0.62 + 0.14 * sin(t * 0.8 + 2.0)), 0.60 + 0.20 * sin(t * 1.3));
  vec2 cc = vec2(aspect * (0.90 + 0.08 * sin(t * 1.4 + 4.0)), 0.30 + 0.16 * sin(t * 0.7 + 3.0));

  float wa = blob(p, ca, 0.55);
  float wb = blob(p, cb, 0.65);
  float wc = blob(p, cc, 0.50);
  float total = wa + wb + wc;

  vec3 tint = (wa * uA + wb * uB + wc * uC) / max(total, 0.0001);
  float alpha = clamp(total, 0.0, 1.0) * uStrength;

  fragColor = vec4(mix(uBase, tint, alpha), 1.0);
}
