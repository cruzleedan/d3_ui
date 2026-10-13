#version 460 core

// Northern lights: three luminous curtains with vertical rays, over a dark sky
// with a few twinkling stars. The brand colours tint the curtains.
//
// uMaxLum caps the brightness of every pixel (relative luminance), so light
// text on top keeps its contrast: the showcase tests the cap against each
// brand's text colour.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uMaxLum;
uniform vec3 uSky;
uniform vec3 uA;
uniform vec3 uB;
uniform vec3 uC;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
    f.y);
}

// One curtain: a wavy bright lower edge with rays fading upwards.
float curtain(vec2 uv, float edge, float seed, float t) {
  float warp = noise(vec2(uv.x * 1.2 + seed * 7.0, t * 0.18 + seed)) * 2.0 - 1.0;
  float ridge = edge + 0.16 * warp + 0.05 * sin(uv.x * 2.6 + t * 0.30 + seed * 3.0);
  float d = ridge - uv.y;                       // above the edge is positive
  float body = d < 0.0 ? exp(d * 22.0) : exp(-d * 6.5);
  float rays = 0.30 + 0.70 * noise(vec2(uv.x * 26.0 + warp * 7.0, t * 0.35 + seed * 11.0));
  float shimmer = 0.85 + 0.15 * sin(t * 0.9 + uv.x * 5.0 + seed * 9.0);
  return pow(body * rays * shimmer, 1.25);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float aspect = uSize.x / uSize.y;
  vec2 uv = vec2(frag.x / uSize.y, frag.y / uSize.y);   // y: 0 top, 1 bottom
  float t = uTime;

  float a = curtain(uv, 0.50, 0.0, t);
  float b = curtain(uv, 0.68, 1.0, t * 1.1);
  float c = curtain(uv, 0.86, 2.0, t * 0.9);

  vec3 col = uSky + uA * a * 1.6 + uB * b * 1.4 + uC * c * 1.2;

  // Stars, fading where the aurora is bright.
  vec2 cell = floor(frag / 3.0);
  float h = hash(cell);
  float star = step(0.9965, h) * (0.55 + 0.45 * sin(t * 1.6 + h * 60.0));
  col += vec3(0.8) * star * (1.0 - clamp((a + b + c) * 1.3, 0.0, 1.0));

  // Brightness cap in (approximately) linear light.
  vec3 lin = pow(col, vec3(2.2));
  float lum = dot(lin, vec3(0.2126, 0.7152, 0.0722));
  if (lum > uMaxLum) lin *= uMaxLum / lum;
  fragColor = vec4(pow(lin, vec3(1.0 / 2.2)), 1.0);
}
