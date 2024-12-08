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

uniform float exposure;
uniform float strength;
uniform float amplitude;
uniform float smoothness;
uniform int   light;

void main() {
	vec2 uv  = v_vTexcoord;
	
	vec2  _uv  = v_vTexcoord - 0.5;
	float dist = dot(_uv, _uv);
	float ang  = atan(_uv.y, _uv.x);
	vec2  _sp  = 0.5 + vec2(cos(ang), sin(ang)) * dist;
	
	float smt = smoothness / 2.;
	uv = mix(uv, _sp, smt);
	
	uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * exposure;
    
    vig = pow(vig, 0.25 + smt);
	vig = clamp(vig, 0., 1.);
	
	vec4 samp = texture2D( gm_BaseTexture, v_vTexcoord );
	float str = (1. - ((1. - vig) * strength));
	
	if(light == 1) str = str < 0.001? 10000. : 1. / str;
    gl_FragColor = vec4(samp.rgb * str, samp.a);
}

