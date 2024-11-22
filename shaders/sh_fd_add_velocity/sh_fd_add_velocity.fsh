varying vec2 v_vTexcoord;

uniform vec2 velo;

void main() {
    vec4 velocity = texture2D(gm_BaseTexture, v_vTexcoord);
    velocity.xy  *= velo.xy;
    
    gl_FragColor = velocity;
}
