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

#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform int   useHeightMap;
uniform float normalHeight;

uniform vec4  ambiance;
uniform int	  lightType;
uniform vec4  lightPosition;
uniform vec4  lightPosition2;

uniform float lightIntensity;
uniform vec4  lightColor;
uniform vec4  lightColor2;

uniform float spotRadius;

uniform int   atten;
uniform float attenCurve_curve[CURVE_MAX];
uniform int   attenCurve_curve_use;
uniform int   attenCurve_amount;

uniform float band;
uniform float radialBandAmo;
uniform float radialBandStart;
uniform float radialBandRatio;

vec3 closestPointOnLine(vec3 P, vec3 A, vec3 B, out float t) {
    vec3 AP = P - A;
    vec3 AB = B - A;
    t = dot(AP, AB) / dot(AB, AB);
    t = clamp(t, 0.0, 1.0);
    return A + t * AB;
}

void main() {
	float aspect = dimension.x / dimension.y;
	vec3  normal = texture2D( normalMap, v_vTexcoord ).rgb * -2.0 + 1.0;
	normal = normalize(normal);
	
	vec3  hsamp = texture2D( heightMap, v_vTexcoord ).rgb;
	float h = useHeightMap == 1? (hsamp.r + hsamp.g + hsamp.b) / 3. * normalHeight : 0.;
	
	vec3  lightPos = vec3(lightPosition.x / dimension.x, lightPosition.y / dimension.y, lightPosition.z);
	
	float range = lightPosition.a / max(dimension.x, dimension.y);
	vec3  curr  = vec3(v_vTexcoord.x, v_vTexcoord.y, h);
	vec3  lightDir;
	vec3  diffuse;
	vec4  lightClr = lightColor;
	float brightness;
	
	if(lightType == 0) {
		vec3 lig   = lightPos - curr;
		lightDir   = normalize(lig); 
		brightness = 1. - length(lig) / range;
		
	    if(radialBandAmo > 1.) {
	        float dirr = atan(curr.y - lightPos.y, curr.x - lightPos.x) + TAU / 2. + radians(radialBandStart);
	        float rbnd = fract(dirr / TAU * radialBandAmo);
	        brightness *= step(radialBandRatio, rbnd);
	    }
	    
	} else if(lightType == 1) {
		lightDir    = normalize(lightPos - vec3(0.5, 0.5, 0.)); 
		lightDir.x *= -1.;
		
	} else if(lightType == 2) {
		float t = 0.;
		vec3 lightPos2 = vec3(lightPosition2.x / dimension.x, lightPosition2.y / dimension.y, lightPosition2.z);
		vec3 lightPosC = closestPointOnLine(curr, lightPos, lightPos2, t);
		
		vec3 lig   = lightPosC - curr;
		lightDir   = normalize(lig); 
		brightness = 1. - length(lig) / range;
		lightClr   = mix(lightColor, lightColor2, t);
		
	} else if(lightType == 3) {
		vec3 lightPos2 = vec3(lightPosition2.x / dimension.x, lightPosition2.y / dimension.y, lightPosition2.z);
		vec3 spotDir   = normalize(lightPos - lightPos2);
		vec3 lig       = lightPos - curr;
		
		lightDir   = normalize(lig); 
		brightness = 1. - acos(dot(spotDir, lightDir)) / range;
	}
	
		 if(atten == 0) brightness = pow(brightness, 2.);
	else if(atten == 1) brightness = 1. - pow(1. - brightness, 2.);
	else if(atten == 2) brightness = brightness;
	else if(atten == 3) brightness = curveEval(attenCurve_curve, attenCurve_amount, brightness);
	
	brightness *= lightIntensity;
	if(band > 0.) brightness = ceil(brightness * band) / band;
	
	float d = max(dot(normal, lightDir), 0.0);
	diffuse = d * lightClr.rgb * lightClr.a * brightness;
	gl_FragColor = vec4(diffuse, 1.);
}
