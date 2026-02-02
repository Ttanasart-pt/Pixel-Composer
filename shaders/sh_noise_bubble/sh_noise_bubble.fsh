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

#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float density;
uniform float seed;
uniform vec2  scale;
uniform vec2  alpha;
uniform int   mode;
uniform int   render;

uniform float thickness;

float random  (in vec2 st) { return fract(sin(dot(st.xy + vec2(1., 6.), vec2(2., 7.))) * (1. + seed / 100.)); }

void main() {
	vec2 vtx = getUV(v_vTexcoord);
	vec2 ntx = vtx * vec2(1., dimension.y / dimension.x);
	vec2 tx  = 1. / dimension;
	vec2 ps  = ntx;
	float w  = 0.;
	
	vec2 dim = dimension;
	vec2 pos = ps;
	
	float _t  = min(tx.x, tx.y) / 2.;
	float rp  = dim.x;
	int   amo = int(density * rp);
	
    for (int i = 0; i < amo; i++) {
		float _x = random(vec2(float(i), 1.));
		float _y = random(vec2(1., float(i)));
		
		float _s = mix(scale.x, scale.y, random(vec2(2., float(i))));
    	float _a = mix(alpha.x, alpha.y, random(vec2(float(i), 2.)));
		
		float dst = 1. - distance(pos, vec2(_x, _y));
		float st;
		
		     if(mode == 0) st = smoothstep(1. - max(_t, thickness), 1., 1. - abs(dst - (1. - _s))) * _a;
		else if(mode == 1) st = smoothstep(1. - _s - thickness, 1. - _s + thickness, max(0., dst)) * _a;
		
		     if(render == 0) w  = max(w, st);
		else if(render == 1) w += st;
    }
    
    gl_FragColor = vec4(vec3(w), 1.);
}
