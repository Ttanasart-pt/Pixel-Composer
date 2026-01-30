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
uniform float epsilon;

void main() {
    float theta = v_vTexcoord.x * PI;
    float rho   = (v_vTexcoord.y * 2. - 1.) * SQRT2;
    float costh = cos(theta);
    float sinth = sin(theta);
    
    vec2  tx      = 1. / dimension;
    vec2  px      = v_vTexcoord * dimension;
    float votes   = 0.;
    float angSnap = radians(angleSnap);
    float scanCount = 0.;
    
    if(angSnap > 0.) {
        for(float ang = 0.; ang < 2. * PI; ang += angSnap) {
            float dirX = cos(ang);
            float dirY = sin(ang);
            
            for(int r = -scanRadius; r <= scanRadius; r++) {
                scanCount++;
                vec2 pos = v_vTexcoord + vec2(dirX, dirY) * float(r) * tx;
                if(pos.x < 0. || pos.x >= 1. || pos.y < 0. || pos.y >= 1.) continue;
                
                float edgeStrength = texture2D(gm_BaseTexture, pos).r;
                if(edgeStrength <= threshold) continue;
                
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
        }   
        
    } else {
        int minX = int(max(0.,          px.x - float(scanRadius)));
        int maxX = int(min(dimension.x, px.x + float(scanRadius)));
        
        int minY = int(max(0.,          px.y - float(scanRadius)));
        int maxY = int(min(dimension.y, px.y + float(scanRadius)));
        
        for(int y = minY; y < maxY; y++)
        for(int x = minX; x < maxX; x++) {
            scanCount++;
            vec2  pos = vec2(x, y) * tx;
            float edgeStrength = texture2D(gm_BaseTexture, pos).r;
            if(edgeStrength <= threshold) continue;
            
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
    }
    
    gl_FragColor = vec4(vec3(votes / scanCount * intensity), 1.);
}
