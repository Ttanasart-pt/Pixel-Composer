//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform int axis;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

#region /////////////// SAMPLING ///////////////

const float PI = 3.14159265358979323846;
uniform int interpolation;
uniform vec2 sampleDimension;
uniform int sampleMode;

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

vec4 sampleTexture(vec2 pos) { #region
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2Dintp(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2Dintp(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2Dintp(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
} #endregion

void main() {
	float amo = amount.x;
	if(amountUseSurf == 1) {
		vec4 _vMap = texture2Dintp( amountSurf, v_vTexcoord );
		amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 pos = v_vTexcoord;
	vec2 cnt = center / dimension;
	
	if(axis == 0) pos.x += (pos.y - cnt.y) * amo;
	else          pos.y += (pos.x - cnt.x) * amo;
	
    gl_FragColor = sampleTexture( pos );
}