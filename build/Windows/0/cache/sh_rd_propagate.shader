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

uniform vec2  dimension;

uniform vec2      k;
uniform int       kUseSurf;
uniform sampler2D kSurf;

uniform vec2      f;
uniform int       fUseSurf;
uniform sampler2D fSurf;

uniform vec2      dt;
uniform int       dtUseSurf;
uniform sampler2D dtSurf;

uniform float     dd;

uniform vec2      da;
uniform int       daUseSurf;
uniform sampler2D daSurf;

uniform vec2      db;
uniform int       dbUseSurf;
uniform sampler2D dbSurf;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * (43758.545 + seed)); }

vec2 samp(float sx, float sy) { return texture2D( gm_BaseTexture, v_vTexcoord + vec2(sx, sy) / dimension ).xy; }

void main() {
	
		float _k = k.x;
		if(kUseSurf == 1) {
			vec4 _vMap = texture2D( kSurf, v_vTexcoord );
			_k = mix(k.x, k.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float _f = f.x;
		if(fUseSurf == 1) {
			vec4 _vMap = texture2D( fSurf, v_vTexcoord );
			_f = mix(f.x, f.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float _dt = dt.x;
		if(dtUseSurf == 1) {
			vec4 _vMap = texture2D( dtSurf, v_vTexcoord );
			_dt = mix(dt.x, dt.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float _da = da.x;
		if(daUseSurf == 1) {
			vec4 _vMap = texture2D( daSurf, v_vTexcoord );
			_da = mix(da.x, da.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float _db = db.x;
		if(dbUseSurf == 1) {
			vec4 _vMap = texture2D( dbSurf, v_vTexcoord );
			_db = mix(db.x, db.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
	
	vec2 _0 = samp(-1., -1.), _1 = samp(0., -1.), _2 = samp(1., -1.);
	vec2 _3 = samp(-1.,  0.), _4 = samp(0.,  0.), _5 = samp(1.,  0.);
	vec2 _6 = samp(-1.,  1.), _7 = samp(0.,  1.), _8 = samp(1.,  1.);
	
	vec2 lap = _0 * 0.05 + _1 * 0.2 + _2 * 0.05 + 
	           _3 * 0.2  + _4 * -1. + _5 * 0.2  + 
			   _6 * 0.05 + _7 * 0.2 + _8 * 0.05;
	
	vec2 reaction   = vec2(-1., 1.) * _4.x * _4.y * _4.y;
	vec2 disipation = vec2(_f * (1. - _4.x), -(_k + _f) * _4.y);
	vec2 diffusion  = lap * vec2(_da, _db) * dd;
	
	vec2 _new = _4 + (reaction + disipation + diffusion) * _dt;
	
    gl_FragColor = vec4(_new, 0., 1.);
}

