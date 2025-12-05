const int MAX_ITERATIONS = 128;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   iteration;
uniform vec2  juliaC;
uniform float diverge;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

vec2 sqrC(in vec2 c) { return vec2(c.x * c.x - c.y * c.y, 2. * c.y * c.x); }

int julia(in vec2 z) {
    vec2 _c = juliaC / dimension;
    
    for(int n = 0; n < iteration; n++) {
        if(dot(z,z) > diverge) return n;
        z = sqrC(z) + _c;
    }
    
    return iteration;
}

void main() {
    vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
    vec2 px  = (vtx - position / dimension) * 4. / scale;
         px *= mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
    
    float j = float(julia(px)) / float(iteration);
    
    gl_FragColor = vec4(vec3(j), 1.);
}