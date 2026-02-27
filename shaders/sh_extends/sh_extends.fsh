varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
			
uniform int   type;
uniform int   extends;
uniform int   bothSide;

uniform vec2  point1;
uniform vec2  point2;

uniform float pathData[1024];
uniform float pathSample;

uniform int   useNormal;
uniform float direction;

uniform int   repeatType;
uniform float repeatLength;

uniform vec2      exLength;
uniform int       exLengthUseSurf;
uniform sampler2D exLengthSurf;

uniform vec4  blendColor;

#define PI 3.1415926535897932384626433832795
float extendLength;

float cross(in vec2 a, in vec2 b) {
	return a.x * b.y - a.y * b.x;
}

vec2 rayHitLine(in vec2 rayOrigin, in float rayAng, in vec2 p0, in vec2 p1, out bool hit) {
	vec2 rayDir = vec2(cos(rayAng), -sin(rayAng));
	vec2 v1 = rayOrigin - p0;
	vec2 v2 = p1 - p0;
	vec2 v3 = vec2(-rayDir.y, rayDir.x);
	
	float ddot = dot(v2, v3);
	if (abs(ddot) < 0.000001) {
		hit = false;
		return vec2(0.0);
	}
	
	float t1 = cross(v2, v1) / ddot;
	float t2 = dot(v1, v3) / ddot;
	
	hit = t1 >= 0. && t2 >= 0. && t2 <= 1.;
	return rayOrigin + t1 * rayDir;
}

vec2 rayHitLineExtends(in vec2 rayOrigin, in float rayAng, in vec2 p0, in vec2 p1, out bool hit) {
	vec2 rayDir = vec2(cos(rayAng), -sin(rayAng));
	vec2 lineDir = p1 - p0;
	vec2 lineNormal = vec2(-lineDir.y, lineDir.x);
	
	float denom = dot(rayDir, lineNormal);
	if (abs(denom) < 1e-6) {
		hit = false;
		return vec2(0.0);
	}
	
	float t = dot(p0 - rayOrigin, lineNormal) / denom;
	if (t < 0.0) {
		hit = false;
		return vec2(0.0);
	}
	
	vec2 hitPoint = rayOrigin + t * rayDir;
	float lineLen = length(lineDir);
	float projLen = dot(hitPoint - p0, lineDir) / lineLen;
	
	if (projLen < -extendLength || projLen > lineLen + extendLength) {
		hit = false;
		return vec2(0.0);
	}
	
	hit = true;
	return hitPoint;
}

float distanceToSegment(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ab = b - a;
	vec2 ap = p - a;
	float t = dot(ap, ab) / dot(ab, ab);
	t = clamp(t, 0.0, 1.0);
	vec2 closest = a + t * ab;
	return distance(p, closest);
}

int imod(int x, int y) {
	int r = x - (x / y) * y;
	return r < 0 ? r + y : r;
}

void main() {
	extendLength = exLength.x;
	
	if(exLengthUseSurf == 1) {
		vec4 _vMap = texture2D( exLengthSurf, v_vTexcoord );
		extendLength = mix(exLength.x, exLength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
	
	float _exLength = extendLength * tx.x;
	float _exDir    = radians(direction);
	
	vec2  _point1   = point1 * tx;
	vec2  _point2   = point2 * tx;
	bool  _hit;
	vec2 rayHit;
	
	if(type == 0) {
		if(useNormal == 1) {
			vec2 lineDir = _point2 - _point1;
			_exDir += atan(lineDir.x, lineDir.y);
		}

		rayHit = extends == 0? rayHitLine(v_vTexcoord, _exDir + PI, _point1, _point2, _hit) : 
		                rayHitLineExtends(v_vTexcoord, _exDir + PI, _point1, _point2, _hit);
		
		if(!_hit && bothSide == 1) {
			_exDir -= PI;
			rayHit = extends == 0? rayHitLine(v_vTexcoord, _exDir + PI, _point1, _point2, _hit) : 
			                rayHitLineExtends(v_vTexcoord, _exDir + PI, _point1, _point2, _hit);
		}

	} else if(type == 1) {
		vec2 ddir = vec2(cos(_exDir + PI / 2.), -sin(_exDir + PI / 2.));
		rayHit = extends == 0? rayHitLine(v_vTexcoord, _exDir + PI, _point1 - ddir, _point1 + ddir, _hit) : 
		                rayHitLineExtends(v_vTexcoord, _exDir + PI, _point1 - ddir, _point1 + ddir, _hit);
		
		if(!_hit && bothSide == 1) {
			_exDir -= PI;
			rayHit = extends == 0? rayHitLine(v_vTexcoord, _exDir + PI, _point1 - ddir, _point1 + ddir, _hit) : 
			                rayHitLineExtends(v_vTexcoord, _exDir + PI, _point1 - ddir, _point1 + ddir, _hit);
		}

	} else if(type == 2) {
		float minDist = 1e10;
		vec2  hitp0   = vec2(0.0);
		vec2  hitp1   = vec2(0.0);
		float hitDir  = 0.0;
		bool  _hitt;
		bool  hitAny = false;
		
		for(int i = 0; i < int(pathSample); i++) {
			vec2 p0 = vec2(pathData[i * 2 + 0], pathData[i * 2 + 1]) * tx;
			vec2 p1 = vec2(pathData[i * 2 + 2], pathData[i * 2 + 3]) * tx;
			
			float _dirr   = useNormal == 1? _exDir + atan(p1.x - p0.x, p1.y - p0.y) : _exDir;
			// vec2  _rayHit = extends == 0? rayHitLine(v_vTexcoord, _dirr + PI, p0, p1, _hitt) : 
			//                        rayHitLineExtends(v_vTexcoord, _dirr + PI, p0, p1, _hitt);
			vec2  _rayHit = rayHitLine(v_vTexcoord, _dirr + PI, p0, p1, _hitt);

			if(!_hitt) continue;
			hitAny = true;
			
			float dist = distance(v_vTexcoord, _rayHit);
			if(dist < minDist) {
				minDist = dist;
				hitp0   = p0;
				hitp1   = p1;
				hitDir  = _dirr;
			}
		}

		if(extends == 1 && !hitAny) { // find closet point
			float minDist = 1e10;
			int pathLen = int(pathSample);

			for(int i = 0; i < pathLen; i++) {
				int i0 = i;
				int i1 = imod(i - 1 + pathLen, pathLen);
				int i2 = imod(i + 1,           pathLen);

				vec2 p0 = vec2(pathData[i0 * 2 + 0], pathData[i0 * 2 + 1]) * tx;
				vec2 p1 = vec2(pathData[i1 * 2 + 0], pathData[i1 * 2 + 1]) * tx;
				vec2 p2 = vec2(pathData[i2 * 2 + 0], pathData[i2 * 2 + 1]) * tx;
				
				float dist = distance(v_vTexcoord, p0);
				if(dist < minDist) {
					minDist = dist;
					hitp0   = p1;
					hitp1   = p2;
					hitDir  = useNormal == 1? _exDir + atan(p2.x - p1.x, p2.y - p1.y) : _exDir;
				}
			}
		}
		
		_exDir = hitDir;
		rayHit = rayHitLineExtends(v_vTexcoord, _exDir + PI, hitp0, hitp1, _hit);
	}
	
	if(!_hit) {
		gl_FragData[0] = texture2D(gm_BaseTexture, v_vTexcoord);
		gl_FragData[1] = vec4(0.);
		return;
	}
	
	float dist = distance(v_vTexcoord, rayHit);
	vec2  dir  = vec2(cos(_exDir), -sin(_exDir));

	if(dist < _exLength) {
		vec2 samPos = rayHit;
		float repl  = repeatLength * tx.x;
		
		     if(repeatType == 1) samPos = rayHit + mod(dist, repl) * dir;
		else if(repeatType == 2) samPos = rayHit + (repl - abs(mod(dist, repl * 2.) - repl)) * dir;
		
		gl_FragData[0] = texture2D(gm_BaseTexture, samPos) * blendColor;
		
		float _disNorm = dist / _exLength;
		gl_FragData[1] = vec4(vec3(_disNorm), 1.);
		return;
	} 
	
	vec2 pos = rayHit + (dist - _exLength) * dir;
	
	gl_FragData[0] = texture2D(gm_BaseTexture, pos);
	gl_FragData[1] = vec4(0.);
}