varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359
#define THETA_STEPS 180
#define SQRT2 1.414

uniform vec2  dimension;
uniform int   type;

uniform float targetRadius;
uniform float threshold;
uniform float intensity;

void main() {
    float theta = v_vTexcoord.x * PI;
    float rho   = (v_vTexcoord.y * 2. - 1.) * SQRT2;
    float costh = cos(theta);
    float sinth = sin(theta);
    
    vec2  tx      = 1. / dimension;
    float votes   = 0.;
    float epsilon = 0.01;
    
    for(int y = 0; y < int(dimension.y); y++)
    for(int x = 0; x < int(dimension.x); x++) {
        vec2  pos = vec2(x, y) * tx;
        float edgeStrength = texture2D(gm_BaseTexture, pos).r;
        if(edgeStrength <= threshold) continue;
        
        if(type == 0) {
            vec2  normPos = pos * 2. - 1.;
            float calcRho = normPos.x * costh + normPos.y * sinth; // linear hough transform
            
            if(abs(calcRho - rho) < epsilon)
                votes += edgeStrength;
                
        } else if(type == 1) {
            float dist = distance(pos, v_vTexcoord);
            
            if(abs(dist - targetRadius) < 0.02)
                votes += edgeStrength;
            
        }
    }
    
    gl_FragColor = vec4(vec3(votes / (dimension.x * dimension.y) * intensity), 1.);
}
