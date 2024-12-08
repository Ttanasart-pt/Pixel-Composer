//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;
uniform float colrSeed;
uniform vec2  position;
uniform int   mode;

uniform vec2      noiseX;
uniform int       noiseXUseSurf;
uniform sampler2D noiseXSurf;

uniform vec2      noiseY;
uniform int       noiseYUseSurf;
uniform sampler2D noiseYSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

float random1D (in vec2 st, float _seed) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(_seed + 453.456, 100.) * 12.588) * 43758.5453123); }

float random (in vec2 st, float _seed) { return mix(random1D(st, floor(_seed)), random1D(st, floor(_seed) + 1.), fract(_seed)); }

void main() {
	
		float nsx = noiseX.x;
		if(noiseXUseSurf == 1) {
			vec4 _vMap = texture2D( noiseXSurf, v_vTexcoord );
			nsx = mix(noiseX.x, noiseX.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float nsy = noiseY.y;
		if(noiseYUseSurf == 1) {
			vec4 _vMap = texture2D( noiseYSurf, v_vTexcoord );
			nsy = mix(noiseY.x, noiseY.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	
	
	vec2 ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	vec2 pos = (ntx - position) * mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	float yy = floor(pos.y * nsy);
	float xx = (pos.x + random(vec2(1., yy), seed)) * nsx;
	
	float x0   = floor(xx);
	float x1   = floor(xx) + 1.;
	float prog = xx - x0;
	
	if(mode == 0) {
		float noise0 = random(vec2(x0, yy), colrSeed);  // point before
		float noise1 = random(vec2(x1, yy), colrSeed);  // point after
		
	    gl_FragColor = vec4(vec3(mix(noise0, noise1, prog)), 1.);
	    
	} else if(mode == 1) {
		gl_FragColor = vec4(vec3(prog), 1.);
	}
}

