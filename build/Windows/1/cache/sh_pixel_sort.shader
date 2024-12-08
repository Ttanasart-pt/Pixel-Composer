//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
// By ciphrd
//

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float iteration;
uniform float threshold;
uniform int direction;

float getBrightness(vec3 col) {
	return dot(col, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
	vec2 pixPos = floor(v_vTexcoord * dimension);
	float fParity = mod(iteration, 2.) * 2. - 1.;
	
	float vp;
	vec2 dir;
	bool shft = false;
	
	if(direction == 0 || direction == 2) {
		vp  = mod(floor(pixPos.x), 2.0) * 2. - 1.;
		dir = vec2(1., 0.);
	} else if(direction == 1 || direction == 3) {
		vp  = mod(floor(pixPos.y), 2.0) * 2. - 1.;
		dir = vec2(0., -1.);
	}
    
	dir *= fParity * vp;
	dir /= dimension;
	
	if(direction == 0) shft = dir.x < 0.;
	if(direction == 1) shft = dir.y < 0.;
	if(direction == 2) shft = dir.x > 0.;
	if(direction == 3) shft = dir.y > 0.;
	
	vec2 dest = v_vTexcoord + dir;
	vec4 curr = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 comp = texture2D(gm_BaseTexture, dest);
	
	float gCurr = getBrightness(curr.rgb);
	float gComp = getBrightness(comp.rgb);
	
	if (dest != clamp(dest, 0., 1.)) {
		gl_FragColor = curr;
		return;
	}
	
	if (shft) {
		if (gCurr > threshold && gComp > gCurr)
			gl_FragColor = comp;
		else
			gl_FragColor = curr;
	} 
	else {
		if (gComp > threshold && gCurr >= gComp)
			gl_FragColor = comp;
		else
			gl_FragColor = curr;
	}
}

