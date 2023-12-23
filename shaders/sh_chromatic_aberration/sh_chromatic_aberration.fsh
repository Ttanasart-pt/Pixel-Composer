//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

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
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2Dintp( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 texel = 1.0 / dimension;
    vec2 coords = (v_vTexcoord - center / dimension) * 2.0;
    float coordDot = dot(coords, coords);
    
    vec2 precompute = str * coordDot * coords;
    vec2 uvR = v_vTexcoord - texel.xy * precompute;
    vec2 uvB = v_vTexcoord + texel.xy * precompute;
    
    vec4 color;
    color.r = texture2Dintp(gm_BaseTexture, uvR).r;
    color.g = texture2Dintp(gm_BaseTexture, v_vTexcoord).g;
    color.b = texture2Dintp(gm_BaseTexture, uvB).b;
    color.a = texture2Dintp(gm_BaseTexture, v_vTexcoord).a + 
			  texture2Dintp(gm_BaseTexture, uvR).a + 
			  texture2Dintp(gm_BaseTexture, uvB).a;
	
	gl_FragColor = color;
}
