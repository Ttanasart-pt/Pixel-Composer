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
// Ditherimg algorithm from hornet, 
// Straight rip off from: https://www.shadertoy.com/view/MslGR8

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

vec3 ScreenSpaceDither( vec2 vScreenPos ) {
	vec3 vDither = vec3( dot( vec2( 171.0, 231.0 ), vScreenPos.xy ) );
    vDither.rgb = fract( vDither.rgb / vec3( 103.0, 71.0, 97.0 ) ) - vec3(0.5);
    
    return vDither.rgb / 255.0 * 0.375;
}

void main() {
	vec2 px = v_vTexcoord * dimension;
	
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 r  = ScreenSpaceDither(px);
	
	c.rgb += r;
	
    gl_FragColor = c;
}

