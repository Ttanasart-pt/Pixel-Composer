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
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  sides[9];

uniform vec4 highlightColor;
uniform vec4 shadowColor;

uniform float seed;
uniform float roughness;
uniform float roughScale;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed / 100., vec2(12.9898, 78.233))) * 43758.5453123); }

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(0.);
	if(position.y < 0.) return vec4(0.);
	if(position.x > 1.) return vec4(0.);
	if(position.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, position );
}

vec4 index ( vec4 def, int ind ) {
	if(sides[ind] == 1)  
		return highlightColor; 
	else if(sides[ind] == -1) 
		return shadowColor; 
	return def; 
}

void main() {
	vec2 tx = 1. / dimension;
	
    gl_FragColor = sample(v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	bool a0 = sample( v_vTexcoord + vec2( -tx.x, -tx.y) ).a == 0.;
	bool a1 = sample( v_vTexcoord + vec2(    0., -tx.y) ).a == 0.;
	bool a2 = sample( v_vTexcoord + vec2(  tx.x, -tx.y) ).a == 0.;
				   
	bool a3 = sample( v_vTexcoord + vec2( -tx.x,    0.) ).a == 0.;
	bool a5 = sample( v_vTexcoord + vec2(  tx.x,    0.) ).a == 0.;
				   
	bool a6 = sample( v_vTexcoord + vec2( -tx.x,  tx.y) ).a == 0.;
	bool a7 = sample( v_vTexcoord + vec2(    0.,  tx.y) ).a == 0.;
	bool a8 = sample( v_vTexcoord + vec2(  tx.x,  tx.y) ).a == 0.;
	
	//outer corner
	if(a0 && a1 && a3)
		gl_FragColor = index( gl_FragColor, 0 );
	else if(a1 && a2 && a5)
		gl_FragColor = index( gl_FragColor, 2 );
	else if(a3 && a6 && a7)
		gl_FragColor = index( gl_FragColor, 6 );
	else if(a5 && a7 && a8)
		gl_FragColor = index( gl_FragColor, 8 );
	
	//outer side
	else if(a0 && a1 && a2 && !a3 && !a5 && !a6 && !a7 && !a8)
		gl_FragColor = index( gl_FragColor, 1 );
	else if(a0 && !a1 && !a2 && a3 && !a5 && a6 && !a7 && !a8)
		gl_FragColor = index( gl_FragColor, 3 );
	else if(!a0 && !a1 && a2 && !a3 && a5 && !a6 && !a7 && a8)
		gl_FragColor = index( gl_FragColor, 5 );
	else if(!a0 && !a1 && !a2 && !a3 && !a5 && a6 && a7 && a8)
		gl_FragColor = index( gl_FragColor, 7 );
	
	//inner side
	else if(a1)
		gl_FragColor = index( gl_FragColor, 1 );
	else if(a3)
		gl_FragColor = index( gl_FragColor, 3 );
	else if(a5)
		gl_FragColor = index( gl_FragColor, 5 );
	else if(a7)
		gl_FragColor = index( gl_FragColor, 7 );
		
	//inner corner
	else if(a0)
		gl_FragColor = index( gl_FragColor, 0 );
	else if(a2)
		gl_FragColor = index( gl_FragColor, 2 );
	else if(a6)
		gl_FragColor = index( gl_FragColor, 6 );
	else if(a8)
		gl_FragColor = index( gl_FragColor, 8 );
	
	else {
		bool a11 = sample( v_vTexcoord + vec2(    0., -tx.y) * 2. ).a == 0.;
		bool a33 = sample( v_vTexcoord + vec2(-tx.x,     0.) * 2. ).a == 0.;
		bool a55 = sample( v_vTexcoord + vec2( tx.x,     0.) * 2. ).a == 0.;
		bool a77 = sample( v_vTexcoord + vec2(   0.,   tx.y) * 2. ).a == 0.;
		
		//corner smooth
		if(sides[4] == 1) {
			if(sides[1] == sides[3] && a11 && a33)
				gl_FragColor = index( gl_FragColor, 0 );
			if(sides[1] == sides[5] && a11 && a55)
				gl_FragColor = index( gl_FragColor, 2 );
			if(sides[7] == sides[3] && a77 && a33)
				gl_FragColor = index( gl_FragColor, 6 );
			if(sides[7] == sides[5] && a77 && a55)
				gl_FragColor = index( gl_FragColor, 8 );
		}
		
		if(roughness > 0.) {
			float r = random(v_vTexcoord * roughScale);
		
			if(!a1 && a11 && r < roughness) 
				gl_FragColor = index( gl_FragColor, 1 );
			else if(!a3 && a33 && r < roughness)
				gl_FragColor = index( gl_FragColor, 3 );
			else if(!a5 && a55 && r < roughness)
				gl_FragColor = index( gl_FragColor, 5 );
			else if(!a7 && a77 && r < roughness)
				gl_FragColor = index( gl_FragColor, 7 );
		}
	}
}

