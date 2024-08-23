#define s3 1.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texture;
uniform vec2  dimension;
uniform float seed;
uniform float scale;
uniform float size;
uniform float blur;
uniform float noise;
uniform float intensity;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123); }
float md(float val, float div) { return val - floor(val / div) * div; }
vec2  md(vec2  val, vec2  div) { return vec2(md(val.x, div.x), md(val.y, div.y)); }

float round(float val) { return fract(val) >= 0.5? ceil(val) : floor(val); }
vec2  round(vec2  val) { return vec2(round(val.x), round(val.y)); }

float HexDist(vec2 p) {
	p = abs(p);
    float c = dot(p, normalize(vec2(1, 1.73)));
    c = max(c, p.x);
    return c;
}

vec2 HexCoords(vec2 uv) {
	vec2 r = vec2(1, s3);
    vec2 h = r * .5;
    
    vec2 a = md(uv,     r) - h;
    vec2 b = md(uv - h, r) - h;
    
    vec2 gv = dot(a, a) <= dot(b, b) ? a : b;
    return uv - gv;
}

float index(vec2 id) {
    vec2 r  = vec2(1, s3);
    vec2 dd = floor(ceil(id / r));
    return dd.x;
}

float fnoise(vec2 pos, float siz, float dist) {
	float lig = smoothstep(siz, siz + blur, dist);
	float rin = smoothstep(blur, 1. + blur, dist);
    float rnd = random(pos, seed);
    rnd = .5 + (rnd - .5) * 4.;
    lig = mix(lig, lig * rnd, noise * (1. - rin));
    
    return lig;
}

void main() {
    vec2 scs  = scale * vec2(2.);
    vec2 pos  = v_vTexcoord - .5;
         pos *= scs;
         
    vec2 hex  = HexCoords(pos);
    vec2  id  = hex;
    
    vec2 ppx   = abs(pos - id);
    float dist = 1. - (ppx.x + ppx.y);
    float siz  = 1. - size / 2.;
    float lig  = fnoise(pos, siz, dist);
    float ind  = index(id);
    
    id = abs(dimension + id);
    if(md(id.y, s3) > s3 / 2.) ind += 2.;
    
    int indx = int(mod(ind, 3.));
    vec3 clr = vec3(0.);
         if(indx == 0) clr.r = intensity;
    else if(indx == 1) clr.g = intensity;
    else if(indx == 2) clr.b = intensity;
    clr *= lig;
    
    vec2 uv = (hex / scs + .5) / vec2(dimension.x / dimension.y, 1.);
    vec3 baseC = texture2D( texture, uv ).rgb;
    baseC.rgb *= clr;
    
    gl_FragColor = vec4(baseC, 1.);
    // gl_FragColor = vec4((id - dimension) / 8., 0., 1.);
    // gl_FragColor = vec4(abs(v_vTexcoord - uv) * 16., 0., 1.);
}
