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

uniform vec2      middle;
uniform int       middleUseSurf;
uniform sampler2D middleSurf;

uniform vec2      range;
uniform int       rangeUseSurf;
uniform sampler2D rangeSurf;

uniform int keep;

void main() {
	float mid = middle.x;
	if(middleUseSurf == 1) {
		vec4 _vMap = texture2D( middleSurf, v_vTexcoord );
		mid = mix(middle.x, middle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float rng = range.x;
	if(rangeUseSurf == 1) {
		vec4 _vMap = texture2D( rangeSurf, v_vTexcoord );
		rng = mix(range.x, range.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col     = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	if(bright > mid + rng || bright < mid - rng)
		gl_FragColor = vec4(vec3(0.), col.a);
	else if(keep == 0)
		gl_FragColor = vec4(vec3(1.), col.a);
	else 
		gl_FragColor = vec4(vec3(bright), col.a);
}

