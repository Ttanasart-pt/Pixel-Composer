varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform sampler2D texture;

uniform vec2  dimension;
uniform vec2  samplePos;

uniform float lightPos;
uniform float lightHei;

uniform float lightInt;
uniform float lightOff;

uniform float roundness;

void main() {
	vec2  vtx  = v_vTexcoord;
	
	vec2  vvtx = abs(vtx - .5) * 2.;
	float dist = 0.;
	
	if(roundness == 1.)
		dist = length(vvtx);
	else {
		float r = 1. - roundness;
		
		dist = 1.;
	    if(vvtx.x < r || vvtx.y < r) dist = 0.;
		else dist = length(vvtx - r) / (1. - r);
	}
	
	float alph = dist < 1.? 1. : 0.;
	vec4  col  = texture2D( texture, samplePos );
	
	vec2 tx = 1. / dimension;
	float x = (vtx.x - .5) / lightOff;
	float y = (vtx.y - .5) / lightOff;
	
	float mag = sqrt(x*x + y*y);
	      mag = clamp(mag, 0., 1.);
	
	float z = sqrt(1.0 - (pow(x, 2.0) + pow(y, 2.0)));
	
	float lAng = radians(lightPos);
	
    vec3 position = vec3(x, y, z);
	vec3 normal   = normalize(position);
	vec3 light    = normalize(vec3(cos(lAng), -sin(lAng), lightHei));
	
	float lightInf = 1. - dot(normal, light);
	col.rgb -= col.rgb * lightInf * lightInt;
	col.a   *= alph;
	
	gl_FragColor = col * v_vColour;
}
