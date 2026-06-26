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
#pragma use(curve)

#region -- curve -- [1780117484.3465736]

    #ifdef _YY_HLSL11_ 
        #define CURVE_MAX  512
    #else 
        #define CURVE_MAX  256
    #endif

    uniform int   curve_offset;

    float eval_curve_segment_t(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float prog) {
        float p = prog;
        float i = 1. - p;
        
        return _y0 *      i*i*i + 
               ay0 * 3. * i*i*p + 
               by1 * 3. * i*p*p + 
               _y1 *      p*p*p;
    }

    float eval_curve_segment_x(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float _x) {
        int _binRep = 8;
        float _prec = 0.0001;

        if(_x <= 0.) return _y0;
        if(_x >= 1.) return _y1;
        if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;

        float t = _x;
                
        for(int i = 0; i < _binRep; i++) {
            float _t = 1. - t;
            float ft =   3. * _t * _t * t * ax0 
                       + 3. * _t *  t * t * bx1
                       +       t *  t * t;
            
            if(abs(ft - _x) < _prec)
                return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, t);
            
            float dfdt =  3. * _t * _t *  ax0
				        + 6. * _t *  t * (bx1 - ax0)
				        + 3. *  t *  t * (1. - bx1);
            
            t = t - (ft - _x) / dfdt;
        }
        
        return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, t);
    }

    float _curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        
        int   _segs  = (amo - curve_offset) / 6 - 1;
        float _shift = curve[0];
        float _scale = curve[1];
        float _type  = curve[2];
        
        _x = _x / _scale - _shift;
        _x = clamp(_x, 0., 1.);
        
        if(_x <= curve[curve_offset + 2]) return curve[curve_offset + 3];
        if(_x >= curve[curve_offset + _segs * 6 + 2]) return curve[curve_offset + _segs * 6 + 3];

        if(_type == 0.) { // interpolated
            for( int i = 0; i < _segs; i++ ) {
                int ind    = curve_offset + i * 6;
                float _x0  = curve[ind + 2];
                float _y0  = curve[ind + 3];
                float _x1  = curve[ind + 6 + 2];
                float _y1  = curve[ind + 6 + 3];

                if(_x < _x0) continue;
                if(_x > _x1) continue;

                float _dx0 = curve[ind + 4];
                float _dy0 = curve[ind + 5];
                float _dx1 = curve[ind + 6 + 0];
                float _dy1 = curve[ind + 6 + 1];
                
				if(abs(_dx0) + abs(_dx1) > abs(_x0 - _x1) * 2.) {
					float _rdx = (abs(_x0 - _x1) * 2.) / (abs(_dx0) + abs(_dx1));
					_dx0 *= _rdx;
					_dx1 *= _rdx;
				}
				
                float _rx  = _x1 - _x0;
                float t = (_x - _x0) / _rx;

                if(_dx0 == 0. && _dy0 == 0. && _dx1 == 0. && _dy1 == 0.)
                    return mix(_y0, _y1, t);
                
                float ax0  = 0. + _dx0 / _rx;
                float ay0  = _y0 + _dy0;

                float bx1  = 1. + _dx1 / _rx;
                float by1  = _y1 + _dy1;
                
                return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, t);
            }

        } else if(_type == 1.) { // step
            float y0 = curve[curve_offset + 3];

            for( int i = 0; i < _segs; i++ ) {
                int ind   = curve_offset + i * 6;
                float _x0 = curve[ind + 2];

                if(_x < _x0) return y0;
                y0 = curve[ind + 3];
            }

            return y0;
        }

        return curve[amo - 3];
    }
    
    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        float _min   = curve[3];
        float _max   = curve[4];
        if(_min == 0. && _max == 0.) {
            _min = 0.;
            _max = 1.;
        }

        float _y = _curveEval(curve, amo, _x);
        return mix(_min, _max, _y);
    }

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec2  dimension;
uniform int   useSurf;

uniform int   useMask;
uniform int   maskAlpha;
uniform sampler2D maskSurface;

uniform int   useOffset;
uniform sampler2D offset;
uniform vec2  offsetRange;

uniform int   invAxis;
uniform float progress;
uniform int   side;

uniform float shines[64];
uniform int   shineAmount; 
uniform float shinesWidth; 

uniform float scale; 
uniform float slope; 
uniform int   straight; 

uniform vec4  shineColor[PALETTE_LIMIT];
uniform int   shineColorAmo;

uniform int   slopeUseCurve; 
uniform float slope_curve[CURVE_MAX];
uniform int   slope_amount;

uniform int   blendMode; 
uniform float intensity; 
uniform int   keepAlpha; 

void main() {
	vec4 cc = useSurf == 1? texture2D(gm_BaseTexture, v_vTexcoord) : vec4(0.);
	vec4 bc = cc;
	gl_FragColor = cc;
	
	if(useSurf == 1 && cc.a == 0.) return;
	
	float ints = intensity;
	float prog = progress;
	
	if(useMask == 1) {
		vec4 mm = texture2D(maskSurface, v_vTexcoord);
		ints *= maskAlpha == 1? mm.a : (mm.r + mm.g + mm.b) / 3. * mm.a;
	}
	
	if(useOffset == 1) {
		vec4 of = texture2D(offset, v_vTexcoord);
		prog += mix(offsetRange.x, offsetRange.y, (of.r + of.g + of.b) / 3. * of.a);
	}
	
	float alp = 1.;
	vec2  px  = getUVA(v_vTexcoord, alp) * dimension;
	ints *= alp;
	
	      px = invAxis == 0? px.xy : px.yx;
	float ww = invAxis == 0? dimension.x : dimension.y;
	float hh = invAxis == 0? dimension.y : dimension.x;
	
	float scaledWidth = shinesWidth * scale;
	float tw = ww + scaledWidth;
	float ns = mix(-ww - tw, ww + tw, prog);
	
	if(straight == 1) {
		if(side == 1) ns = mix(ww + scaledWidth, -scaledWidth, prog);
		else          ns = mix(-scaledWidth, ww + scaledWidth, prog);
		
	} else {
		float sl = slope;
		if(slopeUseCurve == 1)
			sl *= curveEval(slope_curve, slope_amount, px.y / hh);
		
		float dy = px.y / sl;
		if(side == 1) ns = ns + dy;
		else          ns = ns + ww - dy;
	}
	
	float os = ns;
	float filIndex = 0.;
	float filTotal = float(shineColorAmo);
	bool  fill     = true;
	
	for(int i = 0; i < shineAmount; i++) {
		float _shine = shines[i];
		ns += _shine * scale;
		
		if(fill) filIndex++;
		if(fill && px.x > os && px.x <= ns) {
			vec4 colr = shineColor[int(filTotal - mod(filIndex, filTotal) - 1.)];
			
			     if(blendMode == 0) cc = mix(cc,      colr, ints);
			else if(blendMode == 1) cc = mix(cc, cc + colr, ints);
			else if(blendMode == 2) cc = mix(cc, cc * colr, ints);
			break;
		}
		
		fill = !fill;
		os   = ns;
	}
	
	if(keepAlpha == 1) cc.a = bc.a;
	gl_FragColor = cc;
}