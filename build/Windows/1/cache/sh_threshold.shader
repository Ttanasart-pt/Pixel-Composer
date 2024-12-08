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

uniform int       bright;
uniform vec2      brightThreshold;
uniform int       brightThresholdUseSurf;
uniform sampler2D brightThresholdSurf;
uniform float     brightSmooth;

uniform int       alpha;
uniform vec2      alphaThreshold;
uniform int       alphaThresholdUseSurf;
uniform sampler2D alphaThresholdSurf;
uniform float     alphaSmooth;

float _step( in float threshold, in float val ) { return val < threshold? 0. : 1.; }

void main() {
	float bri = brightThreshold.x;
	if(brightThresholdUseSurf == 1) {
		vec4 _vMap = texture2D( brightThresholdSurf, v_vTexcoord );
		bri = mix(brightThreshold.x, brightThreshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float alp = alphaThreshold.x;
	if(alphaThresholdUseSurf == 1) {
		vec4 _vMap = texture2D( alphaThresholdSurf, v_vTexcoord );
		alp = mix(alphaThreshold.x, alphaThreshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(bright == 1) {
		float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
		col.rgb = vec3(brightSmooth == 0.? _step(bri, bright) : smoothstep(bri - brightSmooth, bri + brightSmooth, bright));
	}
	
	if(alpha == 1) {
		col.a = alphaSmooth == 0.? _step(alp, col.a) : smoothstep(alp - alphaSmooth, alp + alphaSmooth, col.a);
	}
	
    gl_FragColor = col;
}

