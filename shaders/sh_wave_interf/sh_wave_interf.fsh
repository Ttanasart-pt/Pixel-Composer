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

uniform int   pattern;

uniform int   type;
uniform int   comp;
uniform int   blendMode;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform vec2  polarPos1;
uniform vec2  polarPos2;

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
	float val = 0., v0, v1;
    
	if(pattern == 0) {
		pos -= position / dimension;
    	pos *= rot;
		pos *= scale;
		val = valueProcess(pos.x);
		v0  = valueProcess(pos.y);
		
	} else if(pattern == 1) {
		val = valueProcess( distance(pos, polarPos1 / dimension) * scale.x );
		v0  = valueProcess( distance(pos, polarPos2 / dimension) * scale.y );
		
	}
	
	     if(blendMode == 0) val += v0;
	else if(blendMode == 1) val *= v0;
	else if(blendMode == 2) val  = max(val, v0);
	
	gl_FragColor = vec4(val, val, val, 1.);
}