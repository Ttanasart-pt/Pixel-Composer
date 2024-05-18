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
