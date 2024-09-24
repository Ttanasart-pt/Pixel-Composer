//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  type;
uniform vec2 dimension;
uniform vec2 center;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

#region /////////////// SAMPLING ///////////////

const float PI = 3.14159265358979323846;
uniform int  interpolation;
uniform vec2 sampleDimension;

const int RSIN_RADIUS = 1;

float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

vec4 texture2D_bilinear( sampler2D texture, vec2 uv ) {
	uv = uv * sampleDimension - .5;
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	
	vec4 mixed = mix(
		mix(
			texture2D( texture, (iuv + vec2(0., 0.)) / sampleDimension ),
			texture2D( texture, (iuv + vec2(1., 0.)) / sampleDimension ),
			fuv.x
		), 
		mix(
			texture2D( texture, (iuv + vec2(0., 1.)) / sampleDimension ),
			texture2D( texture, (iuv + vec2(1., 1.)) / sampleDimension ),
			fuv.x
		), 
		fuv.y
	);
	
	mixed.rgb /= mixed.a;
	
	return mixed;
}

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
        vec4 sample = texture2D_bilinear(texture, (p + offset + vec2(0.5)) / sampleDimension);
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
	return texture2D_bilinear( texture, uv );
}

vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
	     if(interpolation == 1)	return texture2D_bilinear( texture, uv );
	else if(interpolation == 2)	return texture2D_bicubic(  texture, uv );
	else if(interpolation == 3)	return texture2D_rsin(     texture, uv );
	return texture2D( texture, uv );
}

#endregion /////////////// SAMPLING ///////////////

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2Dintp( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	gl_FragColor = vec4(0.);
	vec2 tx = 1.0 / dimension;
    vec2 coords = (v_vTexcoord - center * tx) * 2.0;
    
    vec2 pcp = vec2(0.), uvR, uvB;

	pcp = dot(coords, coords) * coords;
	// else if(type == 1) pcp = vec2(pow(coords.x, 3.), pow(coords.y, 3.));
	
	pcp *= str * tx;
	
    uvR = v_vTexcoord - pcp;
    uvB = v_vTexcoord + pcp;
    
    vec4 cr = texture2Dintp(gm_BaseTexture, uvR);
    vec4 cb = texture2Dintp(gm_BaseTexture, uvB);
    vec4 cv = texture2Dintp(gm_BaseTexture, v_vTexcoord);
    
    gl_FragColor = vec4(cr.r, cv.g, cb.b, cv.a + cr.a + cb.a);
}
