varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surfaceMax;
uniform sampler2D surfaceMin;

vec4 sample(sampler2D tex, vec2 pos) { return texture2D( tex, clamp(pos, 0., 1.) ); }

void main() {
    vec2 tx = 1. / dimension;
    
    vec4 cMax = vec4(0.);
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(0., 0.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(1., 0.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(0., 1.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(1., 1.) * tx ));
    
    vec4 cMin = vec4(1.);
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(0., 0.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(1., 0.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(0., 1.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(1., 1.) * tx ));
    
    gl_FragData[0] = cMax;
    gl_FragData[1] = cMin;
}
