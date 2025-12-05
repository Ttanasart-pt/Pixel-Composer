//Cristal noise by doolhong
//https://www.shadertoy.com/view/XX33zs

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.141592
#define TAU 6.283184

uniform vec2  dimension;

uniform vec2  scale;
uniform vec2  position;
uniform int   iteration;
uniform float seed;

uniform vec4  color;
uniform float gamma;
uniform float phase;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

mat2 rotMat(in float r){
    r = radians(r);
    float c = cos(r);
    float s = sin(r);
    return mat2(c, -s, s, c);
}

float abs1d(in float x){ return abs(fract(x) - 0.5); }
vec2  abs2d(in vec2 v) { return abs(fract(v) - 0.5); }
float cos1d(float p)   { return cos(p * TAU) * 0.25 + 0.25;}
float sin1d(float p)   { return sin(p * TAU) * 0.25 + 0.25;}

vec3 Oilnoise(in vec2 pos, in vec3 RGB) {
    vec2 q = vec2(0.0);
    float result = 0.0;
    
    float s    = 2.2;
    float gain = 6.6 / float(iteration);
    vec2 aPos  = abs2d(pos) * 0.5;//add pos

    for(int i = 0; i < iteration; i++) {
        pos *= rotMat(phase);
        
        q =  pos * s + seed;
        q =  pos * s + aPos + seed;
        q = vec2(cos(q));

        result += sin1d(dot(q, vec2(0.3))) * gain;

        s    *= 1.07;
        aPos += cos(smoothstep(0.0,0.15,q));
        aPos *= rotMat(5.0);
        aPos *= 1.232; 
    }
    
    result = pow(result, 4.504);
    
    return clamp( RGB / abs1d(dot(q, vec2(-0.240, 0.))) * .5 / result, vec3(0.), vec3(1.));
}

void main() {
    vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
    vec2 ntx = vtx * vec2(1., dimension.y / dimension.x);
    vec2 pos = ntx * scale + position;
    vec3 col = Oilnoise(pos, color.rgb * gamma);
    gl_FragColor = vec4(col, 1.0);
}
