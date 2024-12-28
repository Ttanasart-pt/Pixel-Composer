#define PI  3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  subdivision;
uniform vec2 point1[1024];
uniform vec2 point2[1024];

vec2 pointToLine(in vec2 p, in vec2 l0, in vec2 l1) {
	float l2 = pow(l0.x - l1.x, 2.) + pow(l0.y - l1.y, 2.);
	if (l2 == 0.) return l0;
	  
	float t = ((p.x - l0.x) * (l1.x - l0.x) + (p.y - l0.y) * (l1.y - l0.y)) / l2;
	t = clamp(t, 0., 1.);
	
	return mix(l0, l1, t);
}

float pointOnLine(in vec2 p, in vec2 l0, in vec2 l1) {
	float l2 = pow(l0.x - l1.x, 2.) + pow(l0.y - l1.y, 2.);
	if (l2 == 0.) return 0.;
	  
	float t = ((p.x - l0.x) * (l1.x - l0.x) + (p.y - l0.y) * (l1.y - l0.y)) / l2;
	return t;
}

void main() {
    vec2 px = v_vTexcoord * dimension;
    
    float dF = dimension.x + dimension.y;
    vec2  pF = point1[0];
    vec2 pF0 = point1[0];
    vec2 pF1 = vec2(0.);
    
    float dT = dimension.x + dimension.y;
    vec2  pT = point2[0];
    vec2 pT0 = point2[0];
    vec2 pT1 = vec2(0.);
    
    for(int i = 1; i < subdivision; i++) {
        pF1 = point1[i];
        pT1 = point2[i];
        
        vec2   f = pointToLine(px, pF0, pF1);
        float _f = distance(px, f);
        if(_f <= dF) {
            dF = _f;
            pF =  f;
        }
        
        vec2   t = pointToLine(px, pT0, pT1);
        float _t = distance(px, t);
        if(_t <= dT) {
            dT = _t;
            pT =  t;
        }
        
        pF0 = pF1;
        pT0 = pT1;
    }
    
    float a = dF / (dF + dT);
    // float l = pointOnLine(px, pF, pT);
    //      if(l < 0.) a = 0.;
    // else if(l > 1.) a = 1.;
    
    gl_FragColor = vec4(vec3(a), 1.);
}
