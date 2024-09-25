// 3D Voronio noise by Pixel

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float seed;
uniform float contrast;
uniform float middle;
uniform float rotation;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

vec3 hash(vec3 p) { return fract(sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)), dot(p, vec3(113.0, 1.0, 57.0)))) * 438.54); }

float voronoi3d(in vec3 x, in float sca) {
	vec3 p = floor(x);
	vec3 f = fract(x);

	float id = 0.0;
	vec2 res = vec2(100.0);
  
	for (int k = -1; k <= 1; k++) 
	for (int j = -1; j <= 1; j++) 
	for (int i = -1; i <= 1; i++) {
		
		vec3 b  = vec3(float(i), float(j), float(k));
		vec3 pb = mod(p + b, sca * 2.);
		
		vec3 r  = vec3(b) - f + hash(pb);
		float d = dot(r, r);

		float cond   = max(sign(res.x - d), 0.0);
		float nCond  = 1.0 - cond;
		
		float cond2  = nCond * max(sign(res.y - d), 0.0);
		float nCond2 = 1.0 - cond2;
		
		id  = (dot(pb, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
		res = vec2(d, res.x) * cond + res * nCond;
		
		res.y = cond2 * d + nCond2 * res.y;
	}

	return res.y;
}

void main() {
	#region params
		float sca = scale.x;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = rotation;
	#endregion
	
	vec2 ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	vec2 pos = position / dimension;
	vec2 st  = (ntx - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca * 0.75;
	
    float n = voronoi3d(vec3(st, seed), sca);
	      n = middle + (n - middle) * contrast;
	
    gl_FragColor = vec4(vec3(n), 1.);
}