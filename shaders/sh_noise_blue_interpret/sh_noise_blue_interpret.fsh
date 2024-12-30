// Cheap BLuenoise by FabriceNeyret2 
// https://www.shadertoy.com/view/tllcR2

#define hash(p)  fract(sin(dot(p, vec2(11.9898, 78.233))) * 43758.5453) // iq suggestion, for Windows

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

float B(vec2 U) {
    float v =  hash( U + vec2(-1.,  0.) )
             + hash( U + vec2( 1.,  0.) )
             + hash( U + vec2( 0.,  1.) )
             + hash( U + vec2( 0., -1.) ); 
    return hash(U) - v / 4. + .5;
}

void main() {
    vec2 u = v_vTexcoord - mod(seed, 1000.);
    gl_FragColor = vec4(vec3(B(u)), 1.);
}
