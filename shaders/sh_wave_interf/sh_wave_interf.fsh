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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.28318530718

uniform vec2  dimension;

uniform int   type;
uniform int   comp;
uniform int   blendMode;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform float intensity;

float valueProcess(float t) {
	float v = t;
	
	     if(type == 0) v = sin(t * TAU); 
	else if(type == 1) v = abs(fract(t) * 2. - 1.) * 2. - 1.; 
	
	v *= intensity;
	
	     if(comp == 1) v = abs(v);
	else if(comp == 2) v = .5 + (v * .5);
	
	return v;
}

void main() {
	float ang = radians(rotation);
    mat2  rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
        
	vec2  pos = getUV(v_vTexcoord);
    pos -= position / dimension;
    pos *= rot;
    pos *= scale;
        
	float val = valueProcess(pos.x);
	
	float v   = valueProcess(pos.y);
	     if(blendMode == 0) val += v;
	else if(blendMode == 1) val *= v;
	
	gl_FragColor = vec4(val, val, val, 1.);
}