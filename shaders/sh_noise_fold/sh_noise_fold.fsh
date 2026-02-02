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

// Based on FabriceNeyret2 - plop 2 shader

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform int   iteration;
uniform float stretch;
uniform float amplitude;

uniform int   mode;

void main() {
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	vec4  col = vec4(0., 0., 0., 1.);
	
    for (int i = 0; i < iteration; i++) {
    	pos += cos( pos.yx * 3. + vec2(0.0, stretch)) / 3.;
        pos += sin( pos.yx      + vec2(stretch, 0.0)) / 2.;
        pos *= amplitude;
    }
    
	if(mode == 0) col += length(mod(pos, 2.) - 1.);
	else          col.xy += abs(mod(pos, 2.) - 1.);
	
    gl_FragColor = col;
}
