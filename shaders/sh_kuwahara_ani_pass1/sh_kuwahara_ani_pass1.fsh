varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
    vec2 d = tx;
	
    vec3 Sx = (
         1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y)).rgb +
         2. * texture2D(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  0.0)).rgb +
         1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y)).rgb +
        -1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y)).rgb +
        -2. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( d.x,  0.0)).rgb +
        -1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y)).rgb
    ) / 4.;

    vec3 Sy = (
         1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y)).rgb +
         2. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0.0, -d.y)).rgb +
         1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y)).rgb +
        -1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y)).rgb +
        -2. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0.0,  d.y)).rgb +
        -1. * texture2D(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y)).rgb
    ) / 4.;

    
    gl_FragColor = vec4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.);
}