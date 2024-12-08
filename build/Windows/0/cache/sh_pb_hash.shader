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
uniform vec4 color;

uniform float hash;
uniform int   invert;

uniform float dissolve;
uniform vec2  dissolveSca;
uniform int   dissolveItr;

///////////////////// PERLIN START /////////////////////

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float perlin ( vec2 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

///////////////////// PERLIN END /////////////////////

void main() {
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	vec2 px = v_vTexcoord * dimension;
	float index;
	
	if(invert == 1) index = px.x - px.y;
	else			index = px.x + px.y;
	
	if(dissolve > 0. && perlin( v_vTexcoord * dimension / dissolveSca, dissolveItr ) <= dissolve)
		return;
	
	if(mod(index, hash) >= hash / 2.)
		gl_FragColor = color;	
}

