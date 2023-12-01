//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float intensity;
uniform vec4  color;

void main() {
	vec4  col = texture2D( gm_BaseTexture, v_vTexcoord );
	float lum = (col.x + col.y + col.z) / 3. * col.a;
    gl_FragColor = vec4(color.rgb, lum * intensity);
}
