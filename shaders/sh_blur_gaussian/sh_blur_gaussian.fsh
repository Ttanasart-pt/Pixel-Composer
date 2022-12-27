//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useMask;
uniform sampler2D mask;

uniform vec2 dimension;
uniform int horizontal;

uniform float weight[32];
uniform int size;
uniform int clamp_border;

//float weightTotal = 0.;

vec4 sample(in vec2 pos, in int index) {
	vec4 col = texture2D( gm_BaseTexture, pos );
	//weightTotal += col.a * weight[index];
	
	return vec4(col.rgb * col.a, col.a) * weight[index];
}

void main() {
    vec2 tex_offset = 1.0 / dimension;
    vec4 result = sample( v_vTexcoord, 0 );
	vec4 samp;
	
    if(horizontal == 1) {
        for(int i = 1; i < size; i++) {
			vec2 pos = vec2(tex_offset.x * float(i), 0.0);
			
			vec2 s_pos = v_vTexcoord + pos;
			if(s_pos.x <= 1.) {
				samp = sample( s_pos, i );
				result += samp;
			} else if(clamp_border == 1) {
				samp = sample( vec2(1., v_vTexcoord.y), i );
				result += samp;
			}
			
			s_pos = v_vTexcoord - pos;
			if(s_pos.x >= 0.) {
				samp = sample( s_pos, i );
	            result += samp;
			} else if(clamp_border == 1) {
				samp = sample( vec2(0., v_vTexcoord.y), i );
				result += samp;	
			}
        }
    } else {
        for(int i = 1; i < size; i++) {
			vec2 pos = vec2(0.0, tex_offset.y * float(i));
			
			vec2 s_pos = v_vTexcoord + pos;
			if(s_pos.y <= 1.) {
				samp = sample( s_pos, i );
	            result += samp;
			} else if(clamp_border == 1) {
				samp = sample( vec2(v_vTexcoord.x, 1.), i );
				result += samp;	
			}
			
			s_pos = v_vTexcoord - pos;
			if(s_pos.y >= 0.) {
				samp = sample( s_pos, i );
	            result += samp;
			} else if(clamp_border == 1) {
				samp = sample( vec2(v_vTexcoord.x, 0.), i );
				result += samp;	
			}
        }
    }
	
	vec4 res = result;
	
    gl_FragColor = res;
}

