//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D backg;
uniform sampler2D scene;
uniform vec2 scnDimension;
uniform vec2 camDimension;

uniform vec2 position;
uniform float zoom;
uniform int sampleMode;
uniform int bg;
uniform float bokehStrength;

const float GoldenAngle = 2.39996323;
const float Iterations = 400.0;

const float ContrastAmount = 150.0;
const vec3 ContrastFactor = vec3(9.0);
const float Smooth = 2.0;

vec4 sampleTexture(sampler2D samp, vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(samp, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(samp, fract(pos));
		
	else if(sampleMode == 2) 
		return texture2D(samp, vec2(fract(pos.x), pos.y));
		
	else if(sampleMode == 3) 
		return texture2D(samp, vec2(pos.x, fract(pos.y)));
	
	return vec4(0.);
}

vec4 bokeh(sampler2D tex, vec2 uv, float radius) { //ref. sh_blur_bokeh
	vec3 num, weight;
	float alpha = 0.;
    float rec = 1.0; // reciprocal 
    vec2 horizontalAngle = vec2(0.0, radius * 0.01 / sqrt(Iterations));
    vec2 aspect = vec2(scnDimension.y / scnDimension.x, 1.0);
    
	mat2 Rotation = mat2(
	    cos(GoldenAngle), sin(GoldenAngle),
	   -sin(GoldenAngle), cos(GoldenAngle)
	);

	for (float i; i < Iterations; i++) {
        rec += 1.0 / rec;
	    horizontalAngle = horizontalAngle * Rotation;
        
        vec2 offset	  = (rec - 1.0) * horizontalAngle;
        vec2 sampleUV = uv + aspect * offset;
		vec4 sam = sampleTexture(tex, sampleUV);
        vec3 col = sam.rgb * sam.a;
        
        // increase contrast and smooth
		vec3 bokeh = Smooth + pow(col, ContrastFactor) * ContrastAmount;
		
		num		+= col * bokeh;
		alpha	+= sam.a * (bokeh.r + bokeh.g + bokeh.b) / 3.;
		weight	+= bokeh;
	}
	
	return vec4(num / weight, alpha / ((weight.r + weight.g + weight.b) / 3.));
}

void main() {
	vec2 pos = position + (v_vTexcoord - vec2(.5)) * (camDimension / scnDimension) * zoom;
	//if(bg == 1) pos = position + (v_vTexcoord - vec2(.5)) * (camDimension / scnDimension);
    vec4 _col0 = sampleTexture( backg, v_vTexcoord );
	vec4 _col1 = bokeh( scene, pos, bokehStrength );
    
	float al = _col1.a + _col0.a * (1. - _col1.a);
	vec4 res = _col0 * _col0.a * (1. - _col1.a) + _col1 * _col1.a;
	res  /= al;
	res.a = al;
	
    gl_FragColor = res;
}
