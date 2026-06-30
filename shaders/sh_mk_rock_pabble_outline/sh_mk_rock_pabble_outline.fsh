varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 color;
uniform int  blend;
uniform int  nugget;

vec4 blendColor(vec4 c) {
	
	if(blend == 0) return vec4(mix(c.rgb, color.rgb,                              color.a), c.a);
	if(blend == 1) return vec4(mix(c.rgb, c.rgb * color.rgb,                      color.a), c.a);
	if(blend == 2) return vec4(mix(c.rgb, 1. - ((1. - c.rgb) * (1. - color.rgb)), color.a), c.a);
	
	return c;
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = base;
	
	if(base.a == 1.) {
		vec4 side;
		
		side = texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.));
		if(side.a == 0.) { gl_FragColor = blendColor(base); return; }
		
		side = texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.));
		if(side.a == 0.) { gl_FragColor = blendColor(base); return; }
		
		// if(nugget == 0) {
		side = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y));
		if(side.a == 0.) { gl_FragColor = blendColor(base); return; }
		// }
		
		side = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y));
		if(side.a == 0.) { gl_FragColor = blendColor(base); return; }
		
	}
}