//Inigo Quilez 
//Oh where would I be without you.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const int MAX_MARCHING_STEPS = 512;
const float EPSILON = 1e-6;
const float PI = 3.14159265358979323846;

const float SUBTEXTURE_SIZE = 1024.;
const float TEXTURE_N = 8192. / SUBTEXTURE_SIZE;
const float TEXTURE_S = TEXTURE_N * TEXTURE_N;
const float TEXTURE_T = SUBTEXTURE_SIZE / 8192.;

uniform int       useTexture;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;

uniform int   shape;
uniform int   tile;
uniform float thickness;
uniform float time;

uniform vec3  position;
uniform vec3  rotation;
uniform float objectScale;

uniform float fov;
uniform vec2  viewRange;
uniform float depthInt;

uniform vec4 background;
uniform vec4 ambient;

uniform vec3  sunPosition;
uniform float shadow;

mat3 rotMatrix, irotMatrix;

#region ////========== Transform ============
    mat3 rotateX(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(1, 0,  0),
            vec3(0, c, -s),
            vec3(0, s,  c)
        );
    }
    
    mat3 rotateY(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3( c, 0, s),
            vec3( 0, 1, 0),
            vec3(-s, 0, c)
        );
    }
    
    mat3 rotateZ(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(c, -s, 0),
            vec3(s,  c, 0),
            vec3(0,  0, 1)
        );
    }
    
    mat3 inverse(mat3 m) {
        float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
        float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
        float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
        
        float b01 = a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 = a21 * a10 - a11 * a20;
        
        float det = a00 * b01 + a01 * b11 + a02 * b21;
        
        return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
                  b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                  b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
    }
#endregion

#region ////============= Util ==============
	
    float dot2( in vec2 v ) { return dot(v,v); }
	float dot2( in vec3 v ) { return dot(v,v); }
	float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }
	
	vec4 sampleTexture(int index, vec2 coord) {
	    if(tile == 1) coord = fract(coord);
		if(coord.x < 0. || coord.y < 0. || coord.x > 1. || coord.y > 1.) return vec4(0.);
		
		float i = float(index);
		
		float txIndex = floor(i / TEXTURE_S);
		float stcInd  = i - txIndex * TEXTURE_S;
		
		float row     = floor(stcInd / TEXTURE_N);
		float col     = stcInd - row * TEXTURE_N;
		
		vec2 tx = vec2(col, row) * TEXTURE_T;
		vec2 sm = tx + coord * TEXTURE_T;
		
			 if(txIndex == 0.) return texture2D(texture0, sm);
		else if(txIndex == 1.) return texture2D(texture1, sm);
		else if(txIndex == 2.) return texture2D(texture2, sm);
		else if(txIndex == 3.) return texture2D(texture3, sm);
		
		return texture2D(texture0, sm);
	}
#endregion

#region ////============ Terrain =============
	float sdTerrain( vec3 p, float h ) {
		vec2 pos = p.xz;
		vec4 sm  = sampleTexture(0, pos);
		float hg = (sm.r + sm.g + sm.b) / 3. * sm.a * h;
		
		return step(-hg, p.y);
	}
	
	float scene(vec3 pos) { return sdTerrain(pos, thickness); }
#endregion

////========= Ray Marching ==========

vec4 march(vec3 camera, vec3 direction) {
    float st = 1. / float(MAX_MARCHING_STEPS);
    
    for (int i = 0; i <= MAX_MARCHING_STEPS; i++) {
        float depth = mix(viewRange.x, viewRange.y, float(i) * st);
        vec3  pos   = camera + depth * direction;
        
        float hit = scene(pos);
        
        if (hit == 1.) 
			return vec4(pos, depth);
    }
    
    return vec4(0., 0., 0., viewRange.y);
}

void main() {
	gl_FragColor = background;
	
	mat3 rx = rotateX(rotation.x);
    mat3 ry = rotateY(rotation.y);
    mat3 rz = rotateZ(rotation.z);
    rotMatrix  = rx * ry * rz;
    irotMatrix = inverse(rotMatrix);
    
	vec3 eye, dir;
	
    float z = 1. / tan(radians(fov) / 2.);
    dir = normalize(vec3((v_vTexcoord - .5) * 2., -z));
    eye = vec3(0., 0., 5.);
	
	dir  = normalize(irotMatrix * dir) / objectScale;
	eye  = irotMatrix * eye;
	eye /= objectScale;
	eye -= position;
	
    vec4  res  = march(eye, dir);
    float dist = res.a;
    vec3  coll = res.xyz;
    
    float distNorm = (dist - viewRange.x) / (viewRange.y - viewRange.x);
    
    if(dist >= viewRange.y) // Not hitting anything.
        return;
    
    vec3 c = useTexture == 0? ambient.rgb : sampleTexture(1, coll.xz).rgb;
    
    ///////////////////////////////////////////////////////////
    dir.y *= -1.;
    vec4 refl = sampleTexture(2, coll.xz);
    float _rr = (refl.x + refl.y + refl.z) / 3.;
    
    vec4 ref  = march(coll + dir, dir);
    if(ref.a < viewRange.y)
        c = mix(c, sampleTexture(1, ref.xz).rgb, _rr);
    else 
        c = mix(c, background.rgb, _rr);
    
    ///////////////////////////////////////////////////////////
    vec3 sunDir = normalize(coll - sunPosition) / objectScale;
    vec4 shad   = march(coll + vec3(0., -distNorm * 0.1, 0.), sunDir);
    if(shad.a < viewRange.y)
        c *= 1. - shadow;
    
    ///////////////////////////////////////////////////////////
    distNorm = 1. - distNorm;
    distNorm = smoothstep(.0, .3, distNorm);
    c = mix(background.rgb, c, mix(1., distNorm, depthInt));
    
    gl_FragColor = vec4(c, 1.);
}