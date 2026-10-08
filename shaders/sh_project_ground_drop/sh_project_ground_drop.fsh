varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D content;
uniform int   axis;
uniform vec2  dimension;

void main() {
	vec2 tx = 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	
	vec4 cGround = vec4(1., 0., 0., 1.);
	vec4 cObject = vec4(0., 1., 0., 1.);
	
	float offset = 0.;
	float dist   = dimension.y;
	
	vec2  psta   = vec2(px.x, 0.);
	vec2  step   = vec2(0, 1.);
	
	bool  isObj  = false;
	bool  isGap  = false;
	float airGap = 0.;
	
	for(float i = 0.; i < dist; i++) {
		vec2 pos = psta + step * i;
		vec2 ppx = pos * tx;
		
		vec4 samp = texture2D(content, ppx);
		
		if(samp.a == 0.) airGap++;
		
		if(samp == cObject) {
			isObj  = true;
			airGap = 0.;
		}
		
		if(samp == cGround)
			break;
	}
	
	if(!isObj) airGap = -1.;
	
	gl_FragColor = vec4(airGap, 0., 0., 1.);
}