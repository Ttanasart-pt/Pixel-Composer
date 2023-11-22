//
// Simple passthrough fragment shader
//
varying vec2  v_vTexcoord;
varying vec4  v_vColour;
uniform int   invert;
uniform float blend;

#region /////////////// SAMPLING ///////////////

const float PI = 3.14159265358979323846;
uniform int interpolation;
uniform vec2 sampleDimension;

const int RSIN_RADIUS = 1;

float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
    vec2 tx = 1.0 / sampleDimension;
    vec2 p  = uv * sampleDimension - vec2(0.5);
    
	vec4 sum = vec4(0.0);
    float weights = 0.;
    
    for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
	for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
        float a = length(vec2(float(x), float(y))) / float(RSIN_RADIUS);
		if(a > 1.) continue;
        float w = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
        vec2 offset = vec2(float(x), float(y)) * tx;
        vec4 sample = texture2D(texture, (p + offset + vec2(0.5)) / sampleDimension);
        sum += w * sample;
        weights += w;
    }
	
    return sum / weights;
}

vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
	uv = uv * sampleDimension + 0.5;
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
	uv = (uv - 0.5) / sampleDimension;
	return texture2D( texture, uv );
}

vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
	if(interpolation == 2)		return texture2D_bicubic( texture, uv );
	else if(interpolation == 3)	return texture2D_rsin( texture, uv );
	return texture2D( texture, uv );
}

#endregion /////////////// SAMPLING ///////////////

void main() {
	vec2 center = vec2(0.5, 0.5);
	vec2 coord;
	
	if(invert == 0) {
		float radius = distance(v_vTexcoord, center) / (sqrt(2.) * .5);
		vec2  cenPos = v_vTexcoord - center;
		float angle	 = (atan(cenPos.y, cenPos.x) / PI + 1.) / 2.;
		
		coord = vec2(radius, angle);
	} else if(invert == 1) {
		float dist = v_vTexcoord.x * 0.5;
		float ang  = v_vTexcoord.y * PI * 2.;
		
		coord = center + vec2(cos(ang), sin(ang)) * dist;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, mix(v_vTexcoord, coord, blend) );
}
