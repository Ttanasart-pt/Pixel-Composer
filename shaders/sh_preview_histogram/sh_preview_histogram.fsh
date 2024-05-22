#define DIM 32.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 color;
uniform sampler2D surface;

void main() {
    vec3 brv = vec3(0.2126, 0.7152, 0.0722);
    
    float tx  = 1. / DIM;
    float rng = 0.1;
    float brF = v_vTexcoord.x - rng;
    float brT = v_vTexcoord.x + rng;
    
    float w = 0.;
    float r = 0.;
    float g = 0.;
    float b = 0.;
    
    for(float x = 0.; x < DIM; x++)
    for(float y = 0.; y < DIM; y++) {
        vec4 c   = texture2D( surface, vec2(x + 0.5, y + 0.5) * tx );
        float br = dot(c.rgb, brv);
        
        if(br  > brF && br  <= brT) w++;
        if(c.r > brF && c.r <= brT) r++;
        if(c.g > brF && c.g <= brT) g++;
        if(c.b > brF && c.b <= brT) b++;
    }
    
    float ws = 1. - w / (DIM * DIM);
    float rs = 1. - r / (DIM * DIM);
    float gs = 1. - g / (DIM * DIM);
    float bs = 1. - b / (DIM * DIM);
    
    gl_FragData[0] = vec4(step(ws, v_vTexcoord.y));
    gl_FragData[1] = vec4(step(rs, v_vTexcoord.y));
    gl_FragData[2] = vec4(step(gs, v_vTexcoord.y));
    gl_FragData[3] = vec4(step(bs, v_vTexcoord.y));
}
