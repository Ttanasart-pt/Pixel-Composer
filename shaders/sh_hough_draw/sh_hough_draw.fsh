varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D hough;
uniform vec2  dimension;
uniform int   type;

uniform int   scanRadius;
uniform float targetRadius;
uniform float threshold;
uniform float intensity;
uniform vec4  lineColor;
uniform float lineDist;
uniform float fadeDistance;
uniform float angleSnap;

#define PI 3.14159265359
#define SQRT2 1.414

void main() {
    vec3 color   = texture2D(gm_BaseTexture, v_vTexcoord).rgb * v_vColour.rgb;
    vec2 normPos = v_vTexcoord * 2. - 1.;
    
    vec2  tx  = 1. / dimension;
    vec2  px  = v_vTexcoord * dimension;
    float thr = threshold;
    float rad = float(scanRadius) / dimension.x;
    float angSnap = radians(angleSnap);
    float snapSiz = 1.;
    
    for(int t = 0; t < int(dimension.x); t++)
    for(int r = 0; r < int(dimension.y); r++) {
        vec2  houghPos = vec2(t, r) * tx;
        float votes    = texture2D(hough, houghPos).r;
        if(votes <= thr) continue;
        
    	if(type == 0) {
            float theta =  houghPos.x * PI;
            float rho   = (houghPos.y * 2.0 - 1.0) * SQRT2;
            if(angSnap > 0.) {
                float snapTheta = floor(theta / angSnap + .5) * angSnap;
                if(abs(theta - snapTheta) > snapSiz) continue;
                
                theta = snapTheta;
            }
            
            float dist  = abs(normPos.x * cos(theta) + normPos.y * sin(theta) - rho);
            float fade  = distance(v_vTexcoord, houghPos);
            
            if(dist < lineDist / 10.) 
            	color = mix(color, lineColor.rgb, lineColor.a * (rad - fade * fadeDistance));
            	
    	} else if(type == 1) {
    		float dist = distance(v_vTexcoord, houghPos);
            
            if(abs(dist - targetRadius) < lineDist / 10.)
                color = mix(color, lineColor.rgb, lineColor.a);
    	}
    }
    
    gl_FragColor = vec4(clamp(color, 0., 1.), 1.0);
}