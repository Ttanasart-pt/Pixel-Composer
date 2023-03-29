//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 f1;
uniform vec2 f2;
uniform vec2 f3;
uniform vec2 f4;
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

mat3 m_inverse(mat3 m) {
    float a11 = m[0][0], a12 = m[0][1], a13 = m[0][2];
    float a21 = m[1][0], a22 = m[1][1], a23 = m[1][2];
    float a31 = m[2][0], a32 = m[2][1], a33 = m[2][2];

    float b11 = a22 * a33 - a23 * a32;
    float b12 = a13 * a32 - a12 * a33;
    float b13 = a12 * a23 - a13 * a22;
    float b21 = a23 * a31 - a21 * a33;
    float b22 = a11 * a33 - a13 * a31;
    float b23 = a13 * a21 - a11 * a23;
    float b31 = a21 * a32 - a22 * a31;
    float b32 = a12 * a31 - a11 * a32;
    float b33 = a11 * a22 - a12 * a21;

    float det = a11 * b11 + a12 * b21 + a13 * b31;

    mat3 inverse;
    inverse[0][0] = b11 / det;
    inverse[0][1] = b12 / det;
    inverse[0][2] = b13 / det;
    inverse[1][0] = b21 / det;
    inverse[1][1] = b22 / det;
    inverse[1][2] = b23 / det;
    inverse[2][0] = b31 / det;
    inverse[2][1] = b32 / det;
    inverse[2][2] = b33 / det;

    return inverse;
}

void main() {
	vec3 p1 = vec3(f1, 1.0);
	vec3 p2 = vec3(f2, 1.0);
	vec3 p3 = vec3(f3, 1.0);
	vec3 p4 = vec3(f4, 1.0);
	vec3 q1 = vec3(t1, 1.0);
	vec3 q2 = vec3(t2, 1.0);
	vec3 q3 = vec3(t3, 1.0);
	vec3 q4 = vec3(t4, 1.0);
  
	mat3 A = mat3(p1, p2, p3);
	vec3 b = p4;
	vec3 x = m_inverse(A) * b;
	vec3 h1 = x;
	vec3 h2 = vec3(q2 - q1);
	vec3 h3 = cross(h1, h2);
	vec3 h4 = vec3(q3 - q1);
	vec3 h5 = cross(h1, h4);
	vec3 h6 = vec3(q4 - q1);
	vec3 h7 = cross(h1, h6);
	mat3 H = mat3(h2 / h3.x, h4 / h5.x, h6 / h7.x);
	H[2][2] = 1.0 / h3.x;
	
	vec3 coord = vec3(v_vTexcoord, 1.0);
	vec3 newCoord = H * coord;
	vec2 texCoord = newCoord.xy / newCoord.z;
	
	gl_FragColor = texture2Dintp(gm_BaseTexture, texCoord);
}