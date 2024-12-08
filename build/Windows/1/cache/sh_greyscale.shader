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

uniform vec2      brightness;
uniform int       brightnessUseSurf;
uniform sampler2D brightnessSurf;

uniform vec2      contrast;
uniform int       contrastUseSurf;
uniform sampler2D contrastSurf;

void main() {
	float bri = brightness.x;
	if(brightnessUseSurf == 1) {
		vec4 _vMap = texture2D( brightnessSurf, v_vTexcoord );
		bri = mix(brightness.x, brightness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float con = contrast.x;
	if(contrastUseSurf == 1) {
		vec4 _vMap = texture2D( contrastSurf, v_vTexcoord );
		con = mix(contrast.x, contrast.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col_b = col + vec4(bri, bri, bri, 0.0);
	vec4 col_bc = vec4(col_b.rgb * con, col_b.a);
	
	col_bc.rgb = vec3(dot(col_bc.rgb, vec3(0.2126, 0.7152, 0.0722)));
	
	gl_FragColor = col_bc;
}

