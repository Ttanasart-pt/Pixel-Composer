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

uniform float down;
uniform vec2  dimension;

void main() {
	vec2 vtx  = getUV(v_vTexcoord);
	vec4 col  = vec4(0.);
	vec2 tx   = 1. / dimension;
	float wei = 0.;
	
	for( float i = 0.; i < down; i++ ) 
	for( float j = 0.; j < down; j++ ) {
		vec4 samp = texture2D( gm_BaseTexture, vtx * down + vec2(i, j) * tx );
		col += samp;
		wei += samp.a;
	}
	
	float alph = wei / (down * down);
	col  /= wei;
	col.a = alph;
	
    gl_FragColor = col;
}
