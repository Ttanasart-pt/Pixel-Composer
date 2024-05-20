varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D histogram;

uniform vec2  dimension;
uniform int   iAxis, oAxis;
uniform float position;
uniform int   aa;
uniform int   mode;

void main() {
    vec2 tx = 1. / dimension;
    vec2 sm = iAxis == 0? vec2(v_vTexcoord.x, position) : vec2(position, v_vTexcoord.y);
    
    vec4  cc = texture2D( gm_BaseTexture, sm );
    float br = 1. - dot(cc.rgb, vec3(0.2126, 0.7152, 0.0722)) * cc.a;
    float bw = iAxis == 0? v_vTexcoord.y : 1. - v_vTexcoord.x;
    float fa = iAxis == 0? tx.x : tx.y;
    
    float res = aa == 0? step(br, bw) : smoothstep(br - fa, br + fa, bw);
    
    if(mode == 0) {
        gl_FragColor = vec4(vec3(res), 1.);
        
    } else if(mode == 1) {
        gl_FragColor = vec4(0.);
        if(res > 0.) gl_FragColor = vec4(cc.rgb, cc.a * res);
        
    }
}
