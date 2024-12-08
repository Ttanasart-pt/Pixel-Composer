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
#define TAU 6.28318530718
#define MAX_RANGE 3.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 subdivision;

uniform vec2      progress;
uniform int       progressUseSurf;
uniform sampler2D progressSurf;

uniform vec4      movement;
uniform int       movementUseSurf;
uniform sampler2D movementSurf;

uniform vec2      rotation;
uniform int       rotationUseSurf;
uniform sampler2D rotationSurf;

uniform float gravity;
uniform float scale;
uniform float alpha;

uniform int   axis;
uniform float brickShift;
uniform float skew;

vec2 random2( vec2 p ) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }

vec2 cellID(in vec2 coord) {
    vec2 idx = floor(coord * subdivision);
    vec2 prg = (coord - idx / subdivision) * subdivision;
    vec2 rng = (random2(vec2((axis == 0? idx.y : idx.x) + 100.)) - .5) * 2.;
    
    if(axis == 0) {
        coord.x += mod(idx.y, 2.) * brickShift / subdivision.x;
        coord.x += (prg.y - .5) * 2. / subdivision.x * skew * 0.5 * rng.x;
    } else {
        coord.y += mod(idx.x, 2.) * brickShift / subdivision.x;
        coord.y += (prg.x - .5) * 2. / subdivision.y * skew * 0.5 * rng.y;
    }
    
    vec2 cel = floor(coord * subdivision) / subdivision + .5 / subdivision;
    return cel;
}

vec4 uvInFrag(in vec2 coord, in vec2 fragID) {
    vec2 fragUV = coord - fragID;
    
    float pro = progress.x;
	if(progressUseSurf == 1) {
		vec4 _vMap = texture2D( progressSurf, fragID );
		pro = mix(progress.x, progress.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2 mvm = movement.xy;
	if(movementUseSurf == 1) {
		vec4 _vMap = texture2D( movementSurf, fragID );
		mvm = mix(movement.xz, movement.yw, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float rta = rotation.x;
	if(rotationUseSurf == 1) {
		vec4 _vMap = texture2D( rotationSurf, fragID );
		rta = mix(rotation.x, rotation.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float sca = mix(1., scale, pro);
    float ang = pro * radians(rta);
    mat2  rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    
    vec2  mov = mvm / dimension;
    float grv = gravity;
    vec2  pos = mov * pro;
    pos.y += grv * pro * pro;
          
    vec2 uv    = fragID + (fragUV - pos) / sca * rot;
    vec2 newID = cellID(uv);
    
    return vec4(
        uv,
        pro, 
        float(newID == fragID)
    );
}

vec4 blend(in vec4 bg, in vec4 fg) {
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return bg;
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
    gl_FragColor  = vec4(0.);
    // gl_FragColor  = vec4(cellID(v_vTexcoord), 0., 1.); return;
    
    vec2 fragSize = 1. / subdivision;
    
    for(float i = -MAX_RANGE; i <= MAX_RANGE;      i++)
    for(float j = -MAX_RANGE; j <= MAX_RANGE * 2.; j++) {
        
        vec2 tx = v_vTexcoord + fragSize * vec2(j, i);
        vec2 cl = cellID(tx);
        
        vec4 uv = uvInFrag(v_vTexcoord, cl);
        if(uv.w == 0.) continue;
        if(uv.x < 0. || uv.x > 1. || uv.y < 0. || uv.y > 1.) continue;
        
        float pro = uv.z;
        float alp = mix(1., alpha, pro);
        
        vec4 c = texture2D( gm_BaseTexture, uv.xy );
             c.a *= alp;
        
        gl_FragColor = blend(gl_FragColor, c);
    }
}

