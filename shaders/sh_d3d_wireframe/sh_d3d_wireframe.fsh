varying vec4 v_vColour;
varying vec4 v_vViewPos;

uniform vec4 blend;
uniform vec4 obj_color;

uniform vec2 viewRange;

uniform int  useDepth;
uniform int  depthType;
uniform sampler2D depthMap;

void main() {
    float fDepth = v_vViewPos.z;
    
    if(useDepth == 1) {
        vec4 depth = texture2D( depthMap, v_vViewPos.xy * .5 + .5 );
        
        float bDepth = (depth.r - viewRange.x) / (viewRange.y - viewRange.x);
        // if(v_vViewPos.z >= depth.r) discard;
    }
    
    gl_FragData[0] = v_vColour * blend * obj_color;
    gl_FragData[1] = vec4(0.);
    gl_FragData[2] = vec4(vec3(fDepth), 1.);
}
