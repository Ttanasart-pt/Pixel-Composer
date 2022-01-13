//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float scale;
uniform float time;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    vec2 st = v_vTexcoord + position;

    st *= scale;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float md = 1.;
    vec2 mg, mr;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(i_st + neighbor);
			point += 0.5 + 0.5 * sin(time + 6.2831 * point);
			
            vec2 _diff = neighbor + point - f_st;
            float dist = length(_diff);

            if(dist < md) {
				md = dist;
				mr = _diff;
				mg = neighbor;
			}
        }
    }
	
	md = 1.;
	for(int y = -2; y <= 2; y++)
	for(int x = -2; x <= 2; x++) {
		vec2 g = mg + vec2(float(x), float(y));
		vec2 point = random2(i_st + g);
		point += 0.5 + 0.5 * sin(time + 6.2831 * point);
		
		vec2 r = g + point - f_st;
		if(dot(mr - r, mr - r) > .0001)
			md = min( md, dot( 0.5 * (mr + r), normalize(r - mr)) );
	}

    gl_FragColor = vec4(vec3(md), 1.0);	
}
