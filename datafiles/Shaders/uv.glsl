    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vtx = mix(uv, texture2D( uvMap, uv ).xy, uvMapMix);
        vtx.y = 1.0 - vtx.y;
        return vtx;
    }