#pragma use(curve)

#region -- curve -- [1771220003.6022823]

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
        
        if(_type == 0.) {
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
    
    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        float _min   = curve[3];
        float _max   = curve[4];

        float _y = _curveEval(curve, amo, _x);
        return mix(_min, _max, _y);
    }

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     seed;

uniform int       bmBright;
uniform int       bmRGB;
uniform int       bmHSV;

uniform vec2      brightness;
uniform int       brightnessUseSurf;
uniform sampler2D brightnessSurf;
uniform float     brightness_curve[CURVE_MAX];
uniform int       brightness_curve_use;
uniform int       brightness_amount;

uniform vec2      red;
uniform int       redUseSurf;
uniform sampler2D redSurf;
uniform float     red_curve[CURVE_MAX];
uniform int       red_curve_use;
uniform int       red_amount;

uniform vec2      green;
uniform int       greenUseSurf;
uniform sampler2D greenSurf;
uniform float     green_curve[CURVE_MAX];
uniform int       green_curve_use;
uniform int       green_amount;

uniform vec2      blue;
uniform int       blueUseSurf;
uniform sampler2D blueSurf;
uniform float     blue_curve[CURVE_MAX];
uniform int       blue_curve_use;
uniform int       blue_amount;

uniform vec2      hue;
uniform int       hueUseSurf;
uniform sampler2D hueSurf;
uniform float     hue_curve[CURVE_MAX];
uniform int       hue_curve_use;
uniform int       hue_amount;

uniform vec2      sat;
uniform int       satUseSurf;
uniform sampler2D satSurf;
uniform float     sat_curve[CURVE_MAX];
uniform int       sat_curve_use;
uniform int       sat_amount;

uniform vec2      val;
uniform int       valUseSurf;
uniform sampler2D valSurf;
uniform float     val_curve[CURVE_MAX];
uniform int       val_curve_use;
uniform int       val_amount;

vec3  channel_mix(vec3  a, vec3  b, vec3  w) { return vec3(mix(a.r, b.r, w.r), mix(a.g, b.g, w.g), mix(a.b, b.b, w.b)); }
vec3  screen(     vec3  a, vec3  b, float w) { return mix(a, vec3(1.0) - (vec3(1.0) - a) * (vec3(1.0) - b), w); }
vec3  soft_light( vec3  a, vec3  b, float w) { return mix(a, pow(a, pow(vec3(2.0), 2.0 * (vec3(0.5) - b))), w); }

float screen(     float a, float b, float w) { return mix(a, 1. - (1. - a) * (1. - b), w); }

vec3 overlay(vec3 a, vec3 b, float w) {
    return mix(a, channel_mix(
        2.0 * a * b,
        vec3(1.0) - 2.0 * (vec3(1.0) - a) * (vec3(1.0) - b),
        step(vec3(0.5), a)
    ), w);
}

// float random  (in vec2 st) { return fract(sin(dot(st.xy + vec2(seed / 1000., 0.), vec2(12.9898, 78.233))) * 43758.5453123); }
float gaussian(   float z, float u, float o) { return (1.0 / (o * sqrt(2.0 * 3.1415))) * exp(-(((z - u) * (z - u)) / (2.0 * (o * o)))); }
float grandom (in vec2 st) { 
	float n = fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453 + seed);
	float r = gaussian(n, 0., .5 * .5);
	
	return r;
}

#region =========================================== COLORS SPACES ===========================================
	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	 }
	
	vec3 hsv2rgb(vec3 c) {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
	
	float hue2rgb( in float m1, in float m2, in float hue) {
		if (hue < 0.0)
			hue += 1.0;
		else if (hue > 1.0)
			hue -= 1.0;
	
		if ((6.0 * hue) < 1.0)
			return m1 + (m2 - m1) * hue * 6.0;
		else if ((2.0 * hue) < 1.0)
			return m2;
		else if ((3.0 * hue) < 2.0)
			return m1 + (m2 - m1) * ((2.0 / 3.0) - hue) * 6.0;
		else
			return m1;
	}
	
	vec3 hsl2rgb( in vec3 hsl ) {
		float r, g, b;
		if(hsl.y == 0.) {
			r = hsl.z;
			g = hsl.z;
			b = hsl.z;
		} else {
			float m1, m2;
			if(hsl.z <= 0.5)
				m2 = hsl.z * (1. + hsl.y);
			else 
				m2 = hsl.z + hsl.y - hsl.z * hsl.y;
			m1 = 2. * hsl.z - m2;
			
			r = hue2rgb(m1, m2, hsl.x + 1. / 3.);
			g = hue2rgb(m1, m2, hsl.x);
			b = hue2rgb(m1, m2, hsl.x - 1. / 3.);
		}
		
		return vec3( r, g, b );
	}
	
	vec3 rgb2hsl( in vec3 c ) {
		float h = 0.0;
		float s = 0.0;
		float l = 0.0;
		float r = c.r;
		float g = c.g;
		float b = c.b;
		float cMin = min( r, min( g, b ) );
		float cMax = max( r, max( g, b ) );
	
		l = ( cMax + cMin ) / 2.0;
		if ( cMax > cMin ) {
			float cDelta = cMax - cMin;
			
			s = l < .5 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
			
			if ( r == cMax )
				h = ( g - b ) / cDelta;
			else if ( g == cMax )
				h = 2.0 + ( b - r ) / cDelta;
			else
				h = 4.0 + ( r - g ) / cDelta;
			
			if ( h < 0.0)
				h += 6.0;
			h = h / 6.0;
		}
		return vec3( h, s, l );
	}
#endregion =========================================== COLORS SPACES ===========================================

float absPow(float a) { return a = sign(a) * pow(abs(a), 3.); }

void main() {
    vec4  c   = texture2D( gm_BaseTexture, v_vTexcoord );
    float cb  = (c[0] + c[1] + c[2]) / 3.;
    
    #region param
		float bri = brightness.x; if(brightnessUseSurf == 1) {
			vec4 _vMap = texture2D( brightnessSurf, v_vTexcoord );
			bri = mix(brightness.x, brightness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} bri = absPow(bri);
		
		float r = red.x; if(redUseSurf == 1) {
			vec4 _vMap = texture2D( redSurf, v_vTexcoord );
			r = mix(red.x, red.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} r = absPow(r);
		
		float g = green.x; if(greenUseSurf == 1) {
			vec4 _vMap = texture2D( greenSurf, v_vTexcoord );
			g = mix(green.x, green.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} g = absPow(g);
		
		float b = blue.x; if(blueUseSurf == 1) {
			vec4 _vMap = texture2D( blueSurf, v_vTexcoord );
			b = mix(blue.x, blue.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} b = absPow(b);
		
		float h = hue.x; if(hueUseSurf == 1) {
			vec4 _vMap = texture2D( hueSurf, v_vTexcoord );
			h = mix(hue.x, hue.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} h = absPow(h);
		
		float s = sat.x; if(satUseSurf == 1) {
			vec4 _vMap = texture2D( satSurf, v_vTexcoord );
			s = mix(sat.x, sat.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} s = absPow(s);
		
		float v = val.x; if(valUseSurf == 1) {
			vec4 _vMap = texture2D( valSurf, v_vTexcoord );
			v = mix(val.x, val.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		} v = absPow(v);
	#endregion
	
	float nBri  = grandom(v_vTexcoord + vec2(0.156, 0.6169));
	if(brightness_curve_use == 1) nBri *= curveEval(brightness_curve, brightness_amount, cb);
	vec3  grain = vec3(nBri);
		 if(bmBright == 0) c.rgb +=      nBri * bri;
	else if(bmBright == 1) c.rgb *= 1. + nBri * bri;
	else if(bmBright == 2) c.rgb  = screen( c.rgb, grain, bri);
	else if(bmBright == 3) c.rgb  = overlay(c.rgb, grain, bri);
	
	float nr = grandom(v_vTexcoord + vec2(0.985, 0.3642));
	if(red_curve_use == 1) nr *= curveEval(red_curve, red_amount, cb);
		 if(bmRGB == 0) c.r +=      nr * r;
	else if(bmRGB == 1) c.r *= 1. + nr * r;
	else if(bmRGB == 2) c.r  = screen( c.r, nr, r);
	
	float ng = grandom(v_vTexcoord + vec2(0.653, 0.4954));
	if(green_curve_use == 1) ng *= curveEval(green_curve, green_amount, cb);
		 if(bmRGB == 0) c.g +=      ng * g;
	else if(bmRGB == 1) c.g *= 1. + ng * g;
	else if(bmRGB == 2) c.g  = screen( c.g, ng, g);
	
	float nb = grandom(v_vTexcoord + vec2(0.382, 0.2967));
	if(blue_curve_use == 1) nb *= curveEval(blue_curve, blue_amount, cb);
		 if(bmRGB == 0) c.b +=      nb * b;
	else if(bmRGB == 1) c.b *= 1. + nb * b;
	else if(bmRGB == 2) c.b  = screen( c.b, nb, b);
	
	vec3 hsv = rgb2hsv(c.rgb);
	
	float nh = grandom(v_vTexcoord + vec2(0.685, 0.5672));
	if(hue_curve_use == 1) nh *= curveEval(hue_curve, hue_amount, cb);
		 if(bmHSV == 0) hsv.r +=      nh * r;
	else if(bmHSV == 1) hsv.r *= 1. + nh * r;
	else if(bmHSV == 2) hsv.r  = screen( hsv.r, nh, r);
	
	float ns = grandom(v_vTexcoord + vec2(0.134, 0.8632));
	if(sat_curve_use == 1) ns *= curveEval(sat_curve, sat_amount, cb);
		 if(bmHSV == 0) hsv.g +=      ns * g;
	else if(bmHSV == 1) hsv.g *= 1. + ns * g;
	else if(bmHSV == 2) hsv.g  = screen( hsv.g, ns, g);
	
	float nv = grandom(v_vTexcoord + vec2(0.268, 0.1264));
	if(val_curve_use == 1) nv *= curveEval(val_curve, val_amount, cb);
		 if(bmHSV == 0) hsv.b +=      nv * b;
	else if(bmHSV == 1) hsv.b *= 1. + nv * b;
	else if(bmHSV == 2) hsv.b  = screen( hsv.b, nv, b);
	
	c.rgb = hsv2rgb(hsv);
	
    gl_FragColor = c;
}
