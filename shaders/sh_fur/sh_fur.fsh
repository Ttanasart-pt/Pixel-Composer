#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;

uniform int       usemask;
uniform sampler2D mask;

uniform float density;
uniform int   furDens;
uniform vec2  furLengthRange;

uniform float     furAngle;
uniform float     furAngleRange;
uniform int       usefurAngleMap;
uniform sampler2D furAngleMap;

uniform float thickness;
uniform float shadow;

uniform vec4      bgcolor;
uniform vec4      color;
uniform int       usecolorSample;
uniform sampler2D colorSample;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

#define PI 3.1415926535897932384626433832795

float random ( vec2 st, float seed ) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233) + seed)) * 43758.5453123); }

float distToLine(vec2 p, vec2 a, vec2 b, out float prog) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    prog = h;
    return length(pa - ba * h);
}

void main() {
	vec2  tx  = 1. / dimension;
    vec2  pos = position / dimension;
    float rot = radians(rotation);
	vec2  vtx = (v_vTexcoord - pos) * mat2(cos(rot), -sin(rot), sin(rot), cos(rot)) * scale;
          vtx = getUV(fract(vtx));

    vec2  denTx   = vec2(density);
	vec2  furRoot = floor(vtx * denTx) / denTx;
    float dist    = 99999.;
	vec3  fur     = bgcolor.rgb;
    float prog;

    for(int i = -furDens; i <= furDens; i++)
    for(int j = -furDens; j <= furDens; j++) {
        vec2  froot  = furRoot + vec2(float(i), float(j)) / denTx;
        froot.x += (random(froot, seed + 456.789) * 2. - 1.) / denTx.x;
        froot.y += random(froot, seed + 123.456) / denTx.y;
        
        if(usemask == 1 && texture2D(mask, froot).r < 0.5) continue;

        float furLength = mix(furLengthRange.x, furLengthRange.y, random(froot, seed + 645.485)) / density;
        float furAngle  = radians(furAngle + furAngleRange * (random(froot, seed + 9874.54) * 2. - 1.));
        if(usefurAngleMap == 1) furAngle += texture2D(furAngleMap, froot).r * PI * 2.;

        vec2  furTip    = froot + vec2(cos(furAngle), -sin(furAngle)) * furLength;
        float furDist   = distToLine(vtx, froot, furTip, prog);
        if(prog < 0. || prog > 1.) continue;

        float thk = thickness / density * (1. - prog);
        float furRen = step(furDist, thk);
        if(furRen == 0.) continue;

        if(furDist < dist) {
            vec3 fColor = color.rgb;
            if(usecolorSample == 1)
                fColor *= texture2D(colorSample, froot).rgb;
            
            dist = furDist;
            fur  = mix(fColor, mix(bgcolor.rgb, fColor, prog), shadow);
        }
    }

	gl_FragColor = vec4(fur, 1.);
}