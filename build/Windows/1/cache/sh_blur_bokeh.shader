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

uniform vec2 dimension;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

const float GoldenAngle = 2.39996323;
const float Iterations  = 400.0;

const float ContrastAmount = 150.0;
const vec3  ContrastFactor = vec3(9.0);
const float Smooth = 2.0;

vec4 bokeh(sampler2D tex, vec2 uv, float radius) {
	vec3 num, weight;
	float alpha = 0.;
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
        
        vec2 offset	  = (rec - 1.0) * horizontalAngle;
        vec2 sampleUV = uv + aspect * offset;
		vec4 sam = texture2D(tex, sampleUV);
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
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	gl_FragColor = bokeh(gm_BaseTexture, v_vTexcoord, str);
}

