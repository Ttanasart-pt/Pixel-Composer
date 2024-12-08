//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform sampler2D target;
uniform vec2 targetDimension;

uniform float colorThreshold;
uniform float pixelThreshold;
uniform float index;

uniform int mode;
uniform float seed;
uniform float size;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed, vec2(12.9898, 78.233))) * 43758.5453123); }
float round(float val) { return fract(val) > 0.5? ceil(val) : floor(val); }

void main() {
	gl_FragColor = vec4(0.);
	
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(base.a == 0.)
		return;
	
	vec2 px = v_vTexcoord * dimension;
	float target_pixels = targetDimension.x * targetDimension.y * (1. - pixelThreshold);
	float match = 0.;
	vec2 baseTx = 1. / dimension;
	vec2 targTx = 1. / targetDimension;
	
	for( float i = 0.; i < targetDimension.x; i++ ) 
	for( float j = 0.; j < targetDimension.y; j++ ) {
		vec4 targ = texture2D( target, vec2(0.5 + i, 0.5 + j) * targTx );
		if(targ.a == 0.) continue;
		
		vec2 bpx  = px + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		
		if(distance(base, targ) <= 2. * colorThreshold) {
			match++;
			if(match >= target_pixels) {
				float ind = mode == 0? index : round(random(v_vTexcoord) * (size - 1.)) / size;
				gl_FragColor = vec4(1., ind, 0., 1.);
				return;
			}
		}
	}
}

