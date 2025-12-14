#pragma use(uv)

#region -- uv -- [1765685937.0825768]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vtx = mix(uv, texture2D( uvMap, uv ).xy, uvMapMix);
        vtx.y = 1.0 - vtx.y;
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center[4];
uniform vec4 color[4];
uniform vec4 strength;

uniform int blend;
uniform int cspace;

#define TAU 6.283185307179586

#region //////////////////////////////////// COLOR SPACES ////////////////////////////////////
	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgb2oklab(vec3 c) {
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	}
	
	vec3 oklab2rgb(vec3 c) {
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	}

	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	vec3 hsv2rgb(vec3 c) {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
	
#endregion //////////////////////////////////// COLOR SPACES ////////////////////////////////////

void main() {
	vec4  distances = vec4(0.);
	float maxDist   = 0.;
	vec2  vtx       = getUV(v_vTexcoord);
	int i;
	
	for( i = 0; i < 4; i++ ) {
		float d      = distance(vtx, center[i] / dimension);
		distances[i] = d;
		maxDist      = max(maxDist, d);
	}
	
	maxDist *= 2.;
	
	for( i = 0; i < 4; i++ )
		distances[i] = pow((maxDist - distances[i]) / maxDist, strength[i]);
	
	vec4 weights;
	
	     if(blend == 0) weights = distances / (distances[0] + distances[1] + distances[2] + distances[3]);
	else if(blend == 1) weights = normalize(distances);
	
	vec4 clr;
	
	if(cspace == 0) {
		clr = color[0] * weights[0] + 
		      color[1] * weights[1] + 
		      color[2] * weights[2] + 
		      color[3] * weights[3];
	
	} else if(cspace == 1) {
		clr.rgb = oklab2rgb(rgb2oklab(color[0].rgb) * weights[0] + 
		                    rgb2oklab(color[1].rgb) * weights[1] + 
		                    rgb2oklab(color[2].rgb) * weights[2] + 
		                    rgb2oklab(color[3].rgb) * weights[3] );
		
		clr.a = color[0].a * weights[0] + 
		        color[1].a * weights[1] + 
		        color[2].a * weights[2] + 
		        color[3].a * weights[3];
	}
	
	gl_FragColor = clr;
}
