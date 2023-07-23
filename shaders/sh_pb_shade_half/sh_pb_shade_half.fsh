//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  side;

void main() {
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
		 if(side == 0 && v_vTexcoord.x < 0.5)  gl_FragColor = v_vColour;
	else if(side == 1 && v_vTexcoord.y < 0.5)  gl_FragColor = v_vColour;
	else if(side == 2 && v_vTexcoord.x > 0.5)  gl_FragColor = v_vColour;
	else if(side == 3 && v_vTexcoord.y > 0.5)  gl_FragColor = v_vColour;
}
