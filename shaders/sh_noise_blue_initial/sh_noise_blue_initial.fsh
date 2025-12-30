// Hash without Sine
// MIT License...
// Copyright (c)2014 David Hoskins

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float threshold;
uniform vec2  dimension;

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
	float h = hash12(v_vTexcoord * dimension + seed / 1000.);
	h = step(1. - threshold, h);
	
	gl_FragColor = vec4(h,h,h,1.);
}