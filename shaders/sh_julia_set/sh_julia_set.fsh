#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

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
    vec2 vtx = getUV(v_vTexcoord);
    vec2 px  = (vtx - position / dimension) * 4. / scale;
         px *= mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
    
    float j = float(julia(px)) / float(iteration);
    
    gl_FragColor = vec4(vec3(j), 1.);
}