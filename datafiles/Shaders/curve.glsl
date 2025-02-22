
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
                int ind   = curve_offset + i * 6;
                float _x0 = curve[ind + 2];
                float _y0 = curve[ind + 3];
                float ax0 = _x0 + curve[ind + 4];
                float ay0 = _y0 + curve[ind + 5];
                
                float _x1 = curve[ind + 6 + 2];
                float _y1 = curve[ind + 6 + 3];
                float bx1 = _x1 + curve[ind + 6 + 0];
                float by1 = _y1 + curve[ind + 6 + 1];
                
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
