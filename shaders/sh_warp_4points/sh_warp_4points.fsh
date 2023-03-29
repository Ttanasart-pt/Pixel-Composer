//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 p0;
uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;

/////////////// SAMPLING ///////////////

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

/////////////// SAMPLING ///////////////

void main() {
	float px = v_vTexcoord.x;
	float py = v_vTexcoord.y;
	
	vec2 A = (p3 - p0) - (p2 - p1);
    vec2 B = (p0 - p1);
    vec2 C = (p2 - p1);
    vec2 D =  p1;
	
	if(abs(A.x) < 0.001) A.x = 0.001;
	if(abs(B.x) < 0.001) B.x = 0.001;
	if(abs(C.x) < 0.001) C.x = 0.001;
	
	if(abs(A.y) < 0.001) A.y = 0.001;
	if(abs(B.y) < 0.001) B.y = 0.001;
	if(abs(C.y) < 0.001) C.y = 0.001;
	
	float c1 = (B.y * C.x) + (A.y * D.x) - (B.x * C.y) - (A.x * D.y);
    float c2 = (B.y * D.x) - (B.x * D.y);

	float _A = (A.y * C.x) - (A.x * C.y);
	
	float _B = (A.x * py) + c1 - (A.y * px);
	float _C = (B.x * py) + c2 - (B.y * px);

	highp float u =  A == 0.?              0. : (-_B - sqrt(_B * _B - 4.0 * _A * _C)) / (_A * 2.0);
	highp float v = (u * A.x + B.x) == 0.? 0. : (px - (u * C.x) - D.x) / (u * A.x + B.x);
	
	vec2 uv = vec2(1. - u, v);
	
	if(uv.x >= 0. && uv.y >= 0. && uv.x <= 1. && uv.y <= 1.)
		gl_FragColor = texture2Dintp( gm_BaseTexture, uv );
	else 
		gl_FragColor = vec4(0.);
}