#pragma use(uv)
#region -- uv -- [1779523757.7465837]
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
    
    vec2 getUVA(in vec2 uv, out float alpha) {
        if(useUvMap == 0) {
            alpha = 1.0;
            return uv;
        }

        vec4 samUV = texture2D( uvMap, uv );
        vec2 vuv = vec2(samUV.x, 1. - samUV.y);
        alpha    = samUV.a;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform int   blend;
uniform float rotation;
uniform vec2  scale;
uniform float offset;

uniform float threshold;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec4 col1;
uniform vec4 col2;

float pfract (in float f) { return fract(fract(f) + 1.); }

void main() {
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		amo = dimension.x / amo;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	#endregion
	
	vec2 asp = vec2(dimension.x / dimension.y, 1.);
	vec2 vtx = getUV(v_vTexcoord);
	vec2 ptx = floor(vtx * dimension) / dimension;
	vec2 pos = (ptx - position / dimension) * asp;
	
	pos.y += offset / amo;
	pos   *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	pos   /= scale;
	
	float _cell  = 1. / (amo * 2.); 
    float _xind  = floor(pos.x / _cell);
    float _yind  = floor(pos.y / _cell);
	
    float _xcell = fract(pos.x * amo * 2.);
    float _ycell = fract(pos.y * amo * 2.);
	
	float _x = _xcell;
	float _y = _ycell;
	
	if(mod(_xind, 2.) == 1.)
		_x = 1. - _xcell;
	
	float _h = _x > _y? _y + (1. - _x) : _y - _x;
	      
	float _ychi = _x > _y ? _yind + 1. : _yind;
	bool  flip  = mod(_ychi, 2.) == 1.;
	
	if(blend == 0) {
		if(flip) _h = 1. - _h;
		// _h = pfract(_h + offset);
		
		gl_FragColor = _h < threshold? col1 : col2;
		
	} else if(blend == 1) {
		if(flip) _h = 1. - _h;
		// _h = pfract(_h + offset);
		
		gl_FragColor = mix(col1, col2, _h);
		
	} else if(blend == 2) {
		_h = _h * .5 + (flip? .5 : 0.);
		// _h = pfract(_h + offset);
		
		gl_FragColor = mix(col1, col2, _h);
		
	} else if(blend == 3) { 
		if(flip) _h = 1. - _h;
		// _h = pfract(_h + offset);
		
		float px = 1. / max(dimension.x, dimension.y);
		_h = smoothstep(threshold - px, threshold + px, _h);
			
		gl_FragColor = mix(col1, col2, _h);
	}
}
