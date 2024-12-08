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
#pragma use(sampler_simple)


    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D backg;
uniform sampler2D scene;
uniform vec2 scnDimension;
uniform vec2 camDimension;

uniform vec2  position;
uniform float zoom;
uniform float bokehStrength;

const float GoldenAngle = 2.39996323;
const float Iterations = 400.0;

const float ContrastAmount = 150.0;
const vec3  ContrastFactor = vec3(9.0);
const float Smooth = 2.0;

vec4 bokeh(sampler2D tex, vec2 uv, float radius) { 
	vec3  num, weight;
	float alpha = 0.;
    float rec   = 1.0; // reciprocal 
    vec2  horizontalAngle = vec2(0.0, radius * 0.01 / sqrt(Iterations));
    vec2  aspect = vec2(scnDimension.y / scnDimension.x, 1.0);
    
	mat2 Rotation = mat2(
	    cos(GoldenAngle), sin(GoldenAngle),
	   -sin(GoldenAngle), cos(GoldenAngle)
	);

	for (float i; i < Iterations; i++) {
        rec += 1.0 / rec;
	    horizontalAngle = horizontalAngle * Rotation;
        
        vec2 offset	  = (rec - 1.0) * horizontalAngle;
        vec2 sampleUV = uv + aspect * offset;
		vec4 sam = sampleTexture( tex, sampleUV );
        vec3 col = sam.rgb * sam.a;
        
        // increase contrast and smooth
		vec3 bokeh = Smooth + pow(col, ContrastFactor) * ContrastAmount;
		
		num		+= col * bokeh;
		alpha	+= sam.a * (bokeh.r + bokeh.g + bokeh.b) / 3.;
		weight	+= bokeh;
	}
	
	float _a = alpha / ((weight.r + weight.g + weight.b) / 3.);
	return vec4(num / weight, pow(_a, 3.));
} 

void main() { 
	vec2 pos = position + (v_vTexcoord - vec2(.5)) * (camDimension / scnDimension) * zoom;
	
	vec4 _col0 = sampleTexture( backg, v_vTexcoord );
	vec4 _col1 = bokeh( scene, pos, bokehStrength );
    
	float al = _col1.a + _col0.a * (1. - _col1.a);
	vec4 res = _col0 * _col0.a * (1. - _col1.a) + _col1 * _col1.a;
	res   /= al;
	res.a  = al;
	
    gl_FragColor = res;
} 

