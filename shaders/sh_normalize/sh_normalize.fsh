varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 range;

void main() {
    vec4 c   = texture2D( gm_BaseTexture, v_vTexcoord );
    vec3 col = (c.rgb - range.x) / (range.y - range.x);
    
    gl_FragColor = vec4(col, c.a);
}
