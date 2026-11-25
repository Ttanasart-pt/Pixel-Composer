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
#region -- curve -- [1795578670.3667924]

    #ifdef _YY_HLSL11_ 
        #define CURVE_MAX  512
    #else 
        #define CURVE_MAX  64
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
        if(_scale < 1.) _x = fract(fract(_x) + 1.);
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

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform int   pattern;
uniform float seed;
uniform float phase;
uniform float randomness;

uniform int   iteration;
uniform float iterScale;
uniform float iterAmpli;
uniform int   blendMode;

uniform vec2      size;
uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform float radiusScale;
uniform float radiusShatter;

uniform float curve_curve[CURVE_MAX];
uniform int   curve_amount;

uniform vec2  levelIn, levelOut; float applyLevel(float v) { return mix(levelOut.x, levelOut.y, (v - levelIn.x) / (levelIn.y - levelIn.x)); }
uniform int   inverted;
uniform float contrast;
uniform float middle;

#define PI 3.14159265359
#define TAU 6.283185307179586

vec2 random2( in vec2 st ) { return fract(sin(vec2(dot(st, vec2(127.1, 311.7)), dot(st, vec2(269.5, 183.3)))) * 43758.5453); }
float random( in vec2 st ) { return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123); }

float cellNoise(vec2 ntx, vec2 pos, float sca, float scaMax, float ang, float _seed) {
	vec2  st     = (ntx - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca / size;
	float m_dist = 2.;
	
	if(pattern < 2) {
		vec2 i_st = floor(st);
	    vec2 f_st = fract(st);
		
	    for (int y = -1; y <= 1; y++)
	    for (int x = -1; x <= 1; x++) {
	        vec2 neighbor = vec2(float(x),float(y));
	        
	        vec2 point = random2(pattern == 0? mod(i_st + neighbor, scaMax) : i_st + neighbor);
			     point = 0.5 + 0.5 * sin(_seed + TAU * fract(point + phase)) * randomness;
			
	        vec2 _diff = neighbor + point - f_st;
	        float dist = length(_diff);
	              dist = curveEval(curve_curve, curve_amount, dist);
	        
	        m_dist = min(m_dist, dist);
	    }
		
	} else if(pattern == 2) {
		for (int j = 0; j <= int(sca / 2.); j++) {
			int _amo = int(sca) + int(float(j) * radiusShatter);
			for (int i = 0; i <= _amo; i++) {
				
				float angl = ang + TAU / float(_amo) * float(i) + float(j) + (random(vec2(0.684, 1.387)) + _seed) * randomness;
				float rad  = pow(float(j) / sca, radiusScale) * sca * .5 + random(vec2(angl)) * 0.1;
				vec2 point = vec2(cos(angl + TAU * phase) * rad, sin(angl + TAU * phase) * rad) + pos;
				
			    vec2 _diff = point - ntx;
			    float dist = length(_diff);
			          dist = curveEval(curve_curve, curve_amount, dist);
			    
			    m_dist = min(m_dist, dist);
			}
		}
	}
	
	return m_dist;
}

void main() {
	#region params
		float sca    = scale.x;
		float scaMax = max(scale.x, scale.y);
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		if(pattern == 0) {
			sca    = floor(sca);
			scaMax = floor(scaMax);
		}
		
		float ang = rotation;
	#endregion
	
	float uva = 1.;
	vec2  vtx = getUVA(v_vTexcoord, uva);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	vec2  pos = position / dimension;
	
    float _seed = mod(seed, 100000.);
    float amp = pow(1. / iterAmpli, float(iteration) - 1.) / (pow(1. / iterAmpli, float(iteration)) - 1.);
    float md  = .0;
    
	for(int i = 0; i < iteration; i++) {
		float _noise = cellNoise(ntx, pos, sca, scaMax, ang, _seed);
		
		     if(blendMode == 0) md += _noise * amp;
		else if(blendMode == 1) md  = max(md, _noise);
		else if(blendMode == 2) md  = max(md, 1. - _noise);
		
		_seed += 1.753;
		amp *= iterAmpli;
		pos *= iterScale;
		pos += TAU;
	}
	
	if(blendMode == 2) md = 1. - md;
	float c = middle + (md - middle) * contrast;
	      c = applyLevel(c);
	if(inverted == 1) c = 1. - c;
	
    gl_FragColor = vec4(c, c, c, 1.0) * v_vColour;
    gl_FragColor.a *= uva;
}
