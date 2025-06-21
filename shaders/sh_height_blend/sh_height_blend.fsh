varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D bg;
uniform sampler2D fg;

uniform int   mode;
uniform int   type;
uniform float factor;

float smin_exp( float a, float b, float k ) {
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float smin_root( float a, float b, float k ) {
    k *= 2.0;
    float x = b-a;
    return 0.5*( a+b-sqrt(x*x+k*k) );
}

float smin_sig( float a, float b, float k ) {
    k *= log(2.0);
    float x = b-a;
    return a + x/(1.0-exp2(x/k));
}

float smin_quad( float a, float b, float k ) {
    k *= 4.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*k*(1.0/4.0);
}

float smin_cubic( float a, float b, float k ) {
    k *= 6.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*h*k*(1.0/6.0);
}

float smin_circ( float a, float b, float k ) {
    k *= 1.0/(1.0-sqrt(0.5));
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - k*0.5*(1.0+h-sqrt(1.0-h*(h-2.0)));
}

void main() {
	vec4 bgg = texture2D( bg, v_vTexcoord );
	vec4 fgg = texture2D( fg, v_vTexcoord );
	
	float h0 = (bgg.r + bgg.g + bgg.b) / 3. * bgg.a;
	float h1 = (fgg.r + fgg.g + fgg.b) / 3. * fgg.a;
	float aa = max(bgg.a, fgg.a);
	
	float nh = mode == 0? min(h0, h1) : max(h0, h1);
	
	float i0 = mode == 0? 1. - h0 : h0;
	float i1 = mode == 0? 1. - h1 : h1;
	float hg;
	
	     if(type == 0) hg = smin_exp(   i0, i1,      factor );
	else if(type == 1) hg = smin_root(  i0, i1, nh * factor );
	else if(type == 2) hg = smin_sig(   i0, i1, nh * factor );
	else if(type == 3) hg = smin_quad(  i0, i1,      factor );
	else if(type == 4) hg = smin_cubic( i0, i1,      factor );
	else if(type == 5) hg = smin_circ(  i0, i1,      factor );
	
	float rr = mode == 0? 1. - hg : hg;
	
	gl_FragColor = vec4(vec3(rr), aa);
}