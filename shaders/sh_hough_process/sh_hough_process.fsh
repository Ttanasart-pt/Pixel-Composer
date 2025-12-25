varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359
#define SQRT2 1.414

uniform vec2  dimension;
uniform int   type;

uniform int   scanRadius;
uniform float targetRadius;
uniform float threshold;
uniform float intensity;
uniform float angleSnap;

void main() {
    float theta = v_vTexcoord.x * PI;
    float rho   = (v_vTexcoord.y * 2. - 1.) * SQRT2;
    float costh = cos(theta);
    float sinth = sin(theta);
    
    vec2  tx      = 1. / dimension;
    vec2  px      = v_vTexcoord * dimension;
    float votes   = 0.;
    float epsilon = 0.01;
    float angSnap = radians(angleSnap);
    
    int minX = int(max(0.,          px.x - float(scanRadius)));
    int maxX = int(min(dimension.x, px.x + float(scanRadius)));
    
    int minY = int(max(0.,          px.y - float(scanRadius)));
    int maxY = int(min(dimension.y, px.y + float(scanRadius)));
    
    for(int y = minY; y < maxY; y++)
    for(int x = minX; x < maxX; x++) {
        vec2  pos = vec2(x, y) * tx;
        vec2  vec = pos - v_vTexcoord;
        float edgeStrength = texture2D(gm_BaseTexture, pos).r;
        if(edgeStrength <= threshold) continue;
        
        float ang = atan(vec.y, vec.x);
        if(angSnap > 0.) {
            float sAng = floor(ang / angSnap + .5) * angSnap;
            if(abs(sAng - ang) > .2) continue;
            
            // pos = v_vTexcoord + vec2(cos(sAng), sin(sAng)) * length(vec);
        }
        
        if(type == 0) {
            vec2  normPos = pos * 2. - 1.;
            float calcRho = normPos.x * costh + normPos.y * sinth;
            
            if(abs(calcRho - rho) < epsilon)
                votes += edgeStrength;
                
        } else if(type == 1) {
            float dist = distance(pos, v_vTexcoord);
            
            if(abs(dist - targetRadius) < epsilon)
                votes += edgeStrength;
            
        }
    }
    
    gl_FragColor = vec4(vec3(votes / (float(maxX - minX) * float(maxY - minY)) * intensity), 1.);
}
