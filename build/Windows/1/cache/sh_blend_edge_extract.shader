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
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  edge;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform float blend;

void main() {
	float wid    = width.x;
	float widMax = max(width.x, width.y);
	if(widthUseSurf == 1) {
		vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
		wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float bnd = 1. - blend;
	vec4  off;
	float m = 0.;
	vec2  v  = 1. - max(vec2(0.), abs(v_vTexcoord - 0.5) * 2. / wid - bnd) / (1. - bnd);
	vec2  vi = 1. - max(vec2(0.), (1. - abs(v_vTexcoord - 0.5) * 2.) / wid - bnd) / (1. - bnd);
	float mi = 1. - max(vi.x, vi.y);
	
	     if(edge == 0) m = min(max(v.x, v.y), max(v.x, v.y) + mi - 1.);
	else if(edge == 1) m = v.x;
	else if(edge == 2) m = v.y;
	
	m = clamp(m, 0., 1.);
	//m = smoothstep(0., 1., m);
	
	gl_FragColor = vec4(vec3(m), 1.);
}

