#pragma use(shape_simple)

#region -- shape_simple -- [1782435089.9137008]
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      dimension;

uniform int       useMask;
uniform sampler2D mask;

uniform vec2      position;
uniform vec2      scale;
uniform float     rotation;

uniform int       useBgSurf;
uniform sampler2D bgSurf;
uniform vec4      bgColor;
uniform vec4      color;

float sd(vec2 p);

void main() {
	vec2  pos = position / dimension;
	float ang = radians(rotation);
	vec2  sca = scale / dimension;
	vec2  tx  = (v_vTexcoord - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) / sca;
	
	float dis = sd(tx);
	
	vec4  bgC = bgColor;
	if(useBgSurf == 1) {
		bgC = texture2D(bgSurf, v_vTexcoord);
	}
	
	if(useMask == 1) {
		vec4  msk  = texture2D(bgSurf, v_vTexcoord);
		float fmsk = (msk.r + msk.g + msk.b) / 3. * msk.a;
		
		if(fmsk == 0.) {
			gl_FragColor = bgC;
			return;
		}
	}
	
	float col = dis <= 0.? 1. : 0.;
	gl_FragColor = mix(bgC, color, col);
}
#endregion -- shape_simple --

uniform float corner;

float sd(vec2 p) {
	vec2  ratio = dimension / dimension.y;
	float c = corner;
	vec2  b = ratio - c;
	
    vec2  d  = abs(p) - b;
    float ds = length(max(d, 0.));
    
    return ds + min(max(d.x, d.y), 0.) - c;
}