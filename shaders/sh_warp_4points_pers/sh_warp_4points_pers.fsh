//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 t1;
uniform vec2 t2;
uniform vec2 t3;
uniform vec2 t4;

/////////////// SAMPLING ///////////////

const float PI = 3.14159265358979323846;
uniform int interpolation;
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

/////////////// SAMPLING ///////////////

mat3 m_inverse(mat3 m) {
    float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
    float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
    float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

    float b01 =  a22 * a11 - a12 * a21;
    float b11 = -a22 * a10 + a12 * a20;
    float b21 =  a21 * a10 - a11 * a20;

    float det = a00 * b01 + a01 * b11 + a02 * b21;

    return mat3(b01, (-a22 * a01 + a02 * a21), ( a12 * a01 - a02 * a11),
                b11, ( a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                b21, (-a21 * a00 + a01 * a20), ( a11 * a00 - a01 * a10)) / det;
}

mat3 computeHomography() {
    float x0 = 0., y0 = 0.;
    float x1 = 1., y1 = 0.;
    float x2 = 0., y2 = 1.;
    float x3 = 1., y3 = 1.;

    float u0 = t1.x, v0 = t1.y;
    float u1 = t2.x, v1 = t2.y;
    float u2 = t3.x, v2 = t3.y;
    float u3 = t4.x, v3 = t4.y;

    mat3 A = mat3(
        x0, y0, 1.0,
        x1, y1, 1.0,
        x2, y2, 1.0
    );

    vec3 b1 = vec3(u0, u1, u2);
    vec3 b2 = vec3(v0, v1, v2);

    vec3 h1 = m_inverse(A) * b1;
    vec3 h2 = m_inverse(A) * b2;

    mat3 H = mat3(
        h1.x, h1.y, h1.z,
        h2.x, h2.y, h2.z,
        0.0,  0.0,  1.0
    );

    return H;
}

void main() {
    mat3 H = computeHomography();

    vec3 warpedCoord = H * vec3(v_vTexcoord, 1.0);
    vec2 finalCoord  = warpedCoord.xy / warpedCoord.z;

    gl_FragColor = texture2D(gm_BaseTexture, finalCoord);
}