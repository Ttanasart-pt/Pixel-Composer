#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

#pragma use(curve)

#region -- curve -- [1742009781.2228172]

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
        float st = 0.;
        float ed = 1.;
        float _prec = 0.0001;
        
        float _xt = _x;
        int _binRep = 8;
        
        if(_x <= 0.) return _y0;
        if(_x >= 1.) return _y1;
        if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;
        
        for(int i = 0; i < _binRep; i++) {
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.);
            
            if(abs(_ftx - _x) < _prec)
                return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
            
            if(_xt < _x) st = _xt;
            else		 ed = _xt;
            
            _xt = (st + ed) / 2.;
        }
        
        int _newRep = 16;
        
        for(int i = 0; i < _newRep; i++) {
            float slope = (  9. * ax0 - 9. * bx1 + 3.) * _xt * _xt
                        + (-12. * ax0 + 6. * bx1) * _xt
                        +    3. * ax0;
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.)
                    - _x;
            
            _xt -= _ftx / slope;
            
            if(abs(_ftx) < _prec)
                break;
        }
        
        _xt = clamp(_xt, 0., 1.);
        return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
    }

    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        
        int   _segs  = (amo - curve_offset) / 6 - 1;
        float _shift = curve[0];
        float _scale = curve[1];
        float _type  = curve[2];
        
        _x = _x / _scale - _shift;
        _x = clamp(_x, 0., 1.);
        
        if(_type == 0.) {
            for( int i = 0; i < _segs; i++ ) {
                int ind    = curve_offset + i * 6;
                float _x0  = curve[ind + 2];
                float _y0  = curve[ind + 3];
                float _x1  = curve[ind + 6 + 2];
                float _y1  = curve[ind + 6 + 3];

                float _dx0 = curve[ind + 4];
                float _dy0 = curve[ind + 5];
                float _dx1 = curve[ind + 6 + 0];
                float _dy1 = curve[ind + 6 + 1];

                if(abs(_dx0) + abs(_dx1) > 1.) {
                    float _total = abs(_dx0) + abs(_dx1);
                    _dx0 /= _total;
                    _dx1 /= _total;
                }

                float ax0  = _x0 + _dx0;
                float ay0  = _y0 + _dy0;
                float bx1  = _x1 + _dx1;
                float by1  = _y1 + _dy1;
                
                if(_x < _x0) continue;
                if(_x > _x1) continue;

                float t = (_x - _x0) / (_x1 - _x0);
                if(curve[ind + 4] == 0. && curve[ind + 5] == 0. && curve[ind + 6 + 0] == 0. && curve[ind + 6 + 1] == 0.)
                    return mix(_y0, _y1, t);
                
                return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, t);
            }

        } else if(_type == 1.) {
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

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   mode;
uniform float border;
uniform vec4  color;

uniform int   blend;
uniform int   side;
uniform int   render;
uniform int   pixelDist;

uniform float falloff_curve[CURVE_MAX];
uniform int   falloff_amount;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

#define TAU 6.283185307179586
float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }
vec4  sample(vec2    pos) { return texture2D( gm_BaseTexture, pos ); }

void main() {
	
	float siz = size.x;
	if(sizeUseSurf == 1) {
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		siz = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float strn = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		strn = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx   = 1. / dimension;
	vec2 px   = floor(v_vTexcoord * dimension);
	vec4 base = sample(v_vTexcoord);
	
	if(render == 1) {
		gl_FragColor = base;
	} else {
		if(mode == 0) gl_FragColor = vec4(0., 0., 0., 1.);
		if(mode == 1) gl_FragColor = vec4(0., 0., 0., 0.);
	}
	
	if(side == 0) {
		if(mode == 0 && base.rgb == vec3(1.)) return;
		if(mode == 1 && base.a == 1.)         return;
		
	} else if(side == 1) {
		if(mode == 0 && base.rgb == vec3(0.)) return;
		if(mode == 1 && base.a == 0.)         return;
		
	}
	
	float dist = 0.;
	float astp = max(64., siz * 4.);
	
    for(float i = 1.; i <  siz; i++)
	for(float j = 0.; j <= astp; j++) {
		
		float angle = j / astp * TAU;
		vec2  smPos = v_vTexcoord + vec2(cos(angle), sin(angle)) * i * tx;
		vec4  samp  = sample(smPos);
		
		vec2  samPx  = floor(smPos * dimension);
		float pxDist = distance(px, samPx);
		
		if(side == 0) {
			if((mode == 0 && bright(samp) > bright(base)) || (mode == 1 && samp.a > base.a)) {
				dist = pixelDist == 1? i : pxDist;
				i = siz;
				break;
			}
			
		} else if(side == 1) {
			if((mode == 0 && bright(samp) < bright(base)) || (mode == 1 && samp.a < base.a)) {
				dist = pixelDist == 1? i : pxDist;
				i = siz;
				break;
			}
		}
	}
	
	if(dist <= 0.) return;
	
	vec4  cc   = color;
	float str  = 1. - dist / siz;
	      str  = curveEval(falloff_curve, falloff_amount, str);
	      str *= strn;
	
	//blend
	vec4 baseColor   = base;
	vec4 targetColor = base;
	
	baseColor = render == 1? base : vec4(0.);
	
	     if(blend == 0)   targetColor = cc; // normal
	else if(blend == 1) { targetColor = cc; str = clamp(str, 0., 1.); } // replace
	// 2
	else if(blend == 3) targetColor = base + cc; // lighten
	else if(blend == 4) targetColor = 1. - (1. - base) * (1. - cc); // screen
	// 5
	else if(blend == 6) targetColor = base - cc * str; // darken
	else if(blend == 7) targetColor = base * cc; // multiply
	
	if(mode == 0) { // greyscale
		baseColor.a   = base.a;
		targetColor.a = base.a;
		
	} else if(side == 0) { // outer alpha // remove alpha multipliers
		baseColor   = vec4(cc.rgb, 0.);
		targetColor = vec4(cc.rgb, 1.);
		
	}
	
	gl_FragColor = mix(baseColor, targetColor, str);
}
