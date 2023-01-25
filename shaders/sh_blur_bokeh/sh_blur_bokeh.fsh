//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2 dimension;

const float GoldenAngle = 2.39996323;
const float Iterations = 400.0;

const float ContrastAmount = 150.0;
const vec3 ContrastFactor = vec3(9.0);
const float Smooth = 2.0;

vec3 bokeh(sampler2D tex, vec2 uv, float radius) {
	vec3 num, weight;
    float rec = 1.0; // reciprocal 
    vec2 horizontalAngle = vec2(0.0, radius * 0.01 / sqrt(Iterations));
    vec2 aspect = vec2(dimension.y / dimension.x, 1.0);
    
	mat2 Rotation = mat2(
	    cos(GoldenAngle), sin(GoldenAngle),
	   -sin(GoldenAngle), cos(GoldenAngle)
	);

	for (float i; i < Iterations; i++) {
        rec += 1.0 / rec;
	    horizontalAngle = horizontalAngle * Rotation;
        
        vec2 offset = (rec - 1.0) * horizontalAngle;
        vec2 sampleUV = uv + aspect * offset;
        vec3 col = texture2D(tex, sampleUV).rgb;
        
        // increase contrast and smooth
		vec3 bokeh = Smooth + pow(col, ContrastFactor) * ContrastAmount;
        
		num += col * bokeh;
		weight += bokeh;
	}
	return num / weight;
}

void main() {
	gl_FragColor = vec4(bokeh(gm_BaseTexture, v_vTexcoord, strength), 1.0);
}
