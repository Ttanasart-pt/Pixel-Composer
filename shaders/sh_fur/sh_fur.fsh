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
uniform float seed;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform int       usemask;
uniform sampler2D mask;

uniform float density;
uniform int   furDens;

uniform vec2      furLengthRange;
uniform int       usefurLengthMap;
uniform sampler2D furLengthMap;

uniform float     furAngle;
uniform float     furAngleRange;
uniform int       usefurAngleMap;
uniform sampler2D furAngleMap;

uniform float thickness;
uniform float thickC_curve[CURVE_MAX];
uniform int   thickC_amount;

uniform float edgeBlend;
uniform float shadow;

uniform vec4      bgcolor;
uniform vec4      color;
uniform int       usecolorSample;
uniform sampler2D colorSample;

#define PI 3.1415926535897932384626433832795

float random ( vec2 st, float seed ) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233) + seed)) * 43758.5453123); }

float distToLine(vec2 p, vec2 a, vec2 b, out float prog) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    prog = h;
    return length(pa - ba * h);
}

void main() {
	vec2  tx  = 1. / dimension;
    vec2  pos = position / dimension;
    float rot = radians(rotation);
	vec2  vtx = (v_vTexcoord - pos) * mat2(cos(rot), -sin(rot), sin(rot), cos(rot)) * scale;
          vtx = getUV(fract(vtx));

    vec2  denTx   = vec2(density);
	vec2  furRoot = floor(vtx * denTx) / denTx;
    float dist    = 99999.;
	vec3  fur     = bgcolor.rgb;
    float prog;
	
	int maxSpan = int(ceil(max(furLengthRange.x, furLengthRange.y)));

    for(int i = -maxSpan; i <= maxSpan; i++)
    for(int j = -maxSpan; j <= maxSpan; j++) {
        vec2  froot  = furRoot + vec2(float(i), float(j)) / denTx;
        vec2  frootLoop = fract(froot);
        froot.x += (random(frootLoop, seed + 456.789) * 2. - 1.) / denTx.x;
        froot.y += random(frootLoop, seed + 123.456) / denTx.y;
        
        if(usemask == 1) {
            vec4 msk = texture2D(mask, froot);
            if(msk.r * msk.a < 0.5) continue;
        }

		float furSize    = usefurLengthMap == 1? texture2D(furLengthMap, froot).r : 1.;
        float furLength  = mix(furLengthRange.x, furLengthRange.y, random(frootLoop, seed + 645.485)) / density;
              furLength *= furSize;
        
        float furAngle   = radians(furAngle + furAngleRange * (random(frootLoop, seed + 9874.54) * 2. - 1.));
        if(usefurAngleMap == 1) furAngle += texture2D(furAngleMap, froot).r * PI * 2.;

        vec2  furTip    = froot + vec2(cos(furAngle), -sin(furAngle)) * furLength;
        float furDist   = distToLine(vtx, froot, furTip, prog);
        if(prog < 0. || prog > 1.) continue;

		float tcc = curveEval(thickC_curve, thickC_amount, 1. - prog);
        float thk = thickness / density * tcc * furSize;
        float furRen = step(furDist, thk);
        if(furRen == 0.) continue;

        if(furDist < dist) {
            vec3 fColor = color.rgb;
            if(usecolorSample == 1)
                fColor *= texture2D(colorSample, froot).rgb;
                
            if( edgeBlend > 0. ) {
                float blend = smoothstep(thk, thk * (1. - edgeBlend), furDist);
                fColor = mix(bgcolor.rgb, fColor, blend);
            }

            dist = furDist;
            fur  = mix(fColor, mix(bgcolor.rgb, fColor, prog), shadow);
        }
    }

	gl_FragColor = vec4(fur, 1.);
}