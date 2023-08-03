//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   bright;
uniform float brightThreshold;
uniform float brightSmooth;

uniform int   alpha;
uniform float alphaThreshold;
uniform float alphaSmooth;

float _step( in float threshold, in float val ) { return val <= threshold? 0. : 1.; }

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(bright == 1) {
		float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
		col.rgb = vec3(brightSmooth == 0.? _step(brightThreshold, bright) : smoothstep(brightThreshold - brightSmooth, brightThreshold + brightSmooth, bright));
	}
		
	if(alpha == 1) {
		col.a = alphaSmooth == 0.? _step(alphaThreshold, col.a) : smoothstep(alphaThreshold - alphaSmooth, alphaThreshold + alphaSmooth, col.a);
	}
	
    gl_FragColor = col;
}
