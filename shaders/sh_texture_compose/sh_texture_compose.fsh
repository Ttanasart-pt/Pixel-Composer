varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;
uniform sampler2D texture;

uniform vec2  dimension;

uniform vec4  target;
uniform float threshold;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

float cdiff(vec4 c1, vec4 c2) { return distance(c1.rgb * c1.a, c2.rgb * c2.a); }

void main() {
	vec4 orig = texture2D( original,       v_vTexcoord );
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec4 res  = base;
	vec4 tex  = vec4(0.);
	
	if(cdiff(orig, target) <= threshold) {
		float ang = radians(rotation);
		mat2  rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
		
		vec2  tx  = v_vTexcoord * rot / scale - position / dimension;
		tx = fract(fract(tx) + 1.);
		
		tex = texture2D( texture, tx );
		res = vec4(0.);
	}
	
	gl_FragData[0] = res;
	gl_FragData[1] = tex;
}