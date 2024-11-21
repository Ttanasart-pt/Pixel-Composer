varying vec2 v_vTexcoord;
varying vec2 v_vScreencoord;
varying vec4 color;

uniform vec2      velo;
uniform sampler2D texture_velocity;

void main() {
    vec4 velocity = texture2D(texture_velocity, v_vScreencoord);
    vec3 sample   = texture2D(gm_BaseTexture, v_vTexcoord).xyw;
    velocity.xy  += (velo.xy * sample.xy) * 8.0 * sample.z;
    
    gl_FragColor = velocity;
}
