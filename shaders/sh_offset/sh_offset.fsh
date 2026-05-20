varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 offset;
uniform float angle;

void main() {
    float ang = radians(angle);
    mat2  rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
    vec2  tx  = fract(v_vTexcoord + offset * rot);
    
    gl_FragColor = texture2D( gm_BaseTexture, tx );
}
