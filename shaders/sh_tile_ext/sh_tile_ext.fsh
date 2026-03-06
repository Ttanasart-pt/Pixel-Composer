varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 surfDimension;

uniform vec2  spacing;
uniform float tileRot;

uniform vec2  position;
uniform int   shiftAxis;
uniform float shiftAlt;

void main() {
	vec2 tx  = v_vTexcoord * dimension;
	     tx -= position;
	
	mat2 trot = mat2(cos(tileRot), -sin(tileRot), sin(tileRot), cos(tileRot));
	
	vec2 repeatSize = surfDimension + spacing;
	vec2 tileId = floor(tx / repeatSize);
	
	     if(shiftAxis == 0) { if(mod(tileId.y, 2.) >= 1.) tx.x += surfDimension * shiftAlt; } 
	else if(shiftAxis == 1) { if(mod(tileId.x, 2.) >= 1.) tx.y += surfDimension * shiftAlt; }
	
	vec2 tilePx = tx - floor(tx / repeatSize) * repeatSize;
	vec2 tileTx = tilePx / surfDimension;
	if(tileTx.x < 0. || tileTx.y < 0. || tileTx.x > 1. || tileTx.y > 1.)
		 gl_FragColor = vec4(0.);
	else gl_FragColor = texture2D(gm_BaseTexture, tileTx);
}