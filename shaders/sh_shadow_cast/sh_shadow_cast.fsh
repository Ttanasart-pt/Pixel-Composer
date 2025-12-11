#pragma use(curve)

#region -- curve -- [1765334869.6409068]

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

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D solid;

uniform int   lightType;
uniform float lightInt;
uniform float pointLightRadius;
uniform vec2  lightPos;

uniform int   lightSoft;
uniform float lightDensity;
uniform float lightRadius;

uniform float lightBand;
uniform int   lightAttn;
uniform vec4  lightClr;

uniform int   atten;
uniform float attenCurve_curve[CURVE_MAX];
uniform int   attenCurve_curve_use;
uniform int   attenCurve_amount;

uniform int   ao;
uniform float aoRadius;
uniform float aoStrength;

#define TAU 6.283185307179586

void main() {
	vec4 bg = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 sl = texture2D( solid, v_vTexcoord );
	
	if(sl.r == 1.) { gl_FragColor = vec4(vec3(0.), bg.a); return; }
	
	float bright = 1.;
	vec2 tx		 = 1. / dimension;
	vec2 aspect  = vec2(dimension) / dimension.x;
	
	vec2  pxPos      = v_vTexcoord * dimension;
	vec2  lightPosTx = lightPos * tx;
	vec2  ang, lang;
	float dst;
	
	if(lightType == 0) {
		ang  = normalize(lightPos - pxPos) * tx;
		lang = vec2(ang.y, -ang.x) * lightRadius * dimension;
		dst  = length(lightPos - pxPos);
		
	} else if(lightType == 1) {
		ang = normalize(lightPosTx - vec2(.5)) * tx;
		lang = vec2(ang.y, -ang.x) * lightRadius;
		dst = length(dimension);
	}
	
	float softlight    = 0.;
	float lightAmo     = 1.;
	float lightCatched = 1.;

	if(lightSoft == 1) {
		softlight    = lightDensity - 1.;
		lightAmo     = softlight * 2. + 1.;
		lightCatched = lightAmo;
	}
	
	vec2 _lightPos, _ang;
	for(int j = 0; j < int(lightAmo); j++) {
		if(lightType == 0) {
			_lightPos = lightPos + lang * (float(j) - softlight);
			_ang = normalize(_lightPos - pxPos) * tx;
			
		} else if(lightType == 1) {
			_lightPos = vec2(.5) + ang * dimension + lang * (float(j) - softlight);
			_ang = normalize(_lightPos - vec2(.5)) * tx;
		}
		
		for(float i = 1.; i < dst; i++) {
			vec2 _pos   = v_vTexcoord + _ang * i;
			vec2 _posPx = _pos * dimension;
			
			if(lightType == 0 && floor(abs(lightPos.x - _posPx.x)) + floor(abs(lightPos.y - _posPx.y)) < 1.)
				continue;
			
			if(_pos.x < 0. || _pos.y < 0. || _pos.x > 1. || _pos.y > 1.)
				continue;
			
			if(texture2D( solid, _pos ).r == 1.) {
				lightCatched--;
				break;
			}
		}
	}
	
	if(ao == 1) {
		float ambient = 0.;
		
		for(float i = 0.; i < aoRadius; i++) {
			float base = 1.;
			float top  = 0.;
			
			for(float j = 0.; j <= 64.; j++) {
				float ang = top / base * TAU;
				top += 2.;
				if(top >= base) {
					top = 1.;
					base *= 2.;
				}
		
				vec2 _pos = v_vTexcoord + vec2(cos(ang), sin(ang)) * i * tx;
				if(_pos.x < 0. || _pos.y < 0. || _pos.x > 1. || _pos.y > 1.)
					continue;
			
				float md = smoothstep(0., 1., 1. - i / aoRadius);
				ambient += texture2D( solid, _pos ).r * md;
			}
		}
		
		lightAmo += ambient * aoStrength * aoStrength;
	}
	
	float shadow = lightCatched / lightAmo;
	
	if(lightType == 0) {
		float dist = distance(v_vTexcoord * dimension, lightPos);
		float prg  = 1. - clamp(dist / pointLightRadius, 0., 1.);
		shadow *= prg * prg;
	}
	
	     if(lightAttn == 0) shadow = shadow * shadow;
	else if(lightAttn == 1) shadow = 1. - (shadow - 1.) * (shadow - 1.);
	else if(lightAttn == 2) shadow = shadow;
	else if(lightAttn == 3) shadow = curveEval(attenCurve_curve, attenCurve_amount, shadow);
	
	if(lightBand > 0.) shadow = ceil(shadow * lightBand) / lightBand;
	
	gl_FragColor = vec4(vec3(shadow * lightInt) * lightClr.rgb, bg.a);
}
