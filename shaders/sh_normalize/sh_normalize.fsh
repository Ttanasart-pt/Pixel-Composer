varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  cMin, cMax;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    
    vec3 cRan = cMax - cMin;
    vec3 col  = (c.rgb - cMin) / cRan;
    
    gl_FragColor = vec4(col, c.a);
}
