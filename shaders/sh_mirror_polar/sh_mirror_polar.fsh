#pragma use(sampler_ext)

#region -- sampler_ext -- [1780129853.1967175]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

	const float PI = 3.14159265358979323846;
	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	const int RSIN_RADIUS = 1;
	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
		vec2 tx = 1.0 / sampleDimension;
		vec2 p  = uv * sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
			vec2 sx = vec2(float(x), float(y));
			float a = length(sx) / float(RSIN_RADIUS);
			// if(a > 1.) continue;
			
			vec4 sample = texture2D(texture, uv + sx * tx);
			float w     = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
			
			col += w * sample;
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	const int LANCZOS_RADIUS = 3;
	float lanczosWeight(float d, float n) { return d == 0.0 ? 1.0 : (d * d < n * n ? sinc(d) * sinc(d / n) : 0.0); }
	
	vec4 texture2D_lanczos3( sampler2D texture, vec2 uv ) {
	    vec2 center = uv - (mod(uv * sampleDimension, 1.0) - 0.5) / sampleDimension;
	    vec2 offset = (uv - center) * sampleDimension;
	    vec2 tx = 1. / sampleDimension;
	    
	    vec4  col = vec4(0.);
	    float wei = 0.;
	    
	    // Use 3x3 grid where each sample combines adjacent weights via bilinear
	    for(int x = -1; x <= 1; x++)
	    for(int y = -1; y <= 1; y++) {
	        // Combine weights from 2 adjacent taps in each direction
	        float wx_a = lanczosWeight(float(x * 2 - 1) - offset.x, float(LANCZOS_RADIUS));
	        float wx_b = lanczosWeight(float(x * 2    ) - offset.x, float(LANCZOS_RADIUS));
	        float wy_a = lanczosWeight(float(y * 2 - 1) - offset.y, float(LANCZOS_RADIUS));
	        float wy_b = lanczosWeight(float(y * 2    ) - offset.y, float(LANCZOS_RADIUS));
	        
	        float wx_total = wx_a + wx_b;
	        float wy_total = wy_a + wy_b;
	        float w = wx_total * wy_total;
	        
	        // Offset for bilinear interpolation between the two taps
	        vec2 samplePos = vec2(x * 2, y * 2) - vec2(.5, .5) + vec2(wx_b / wx_total, wy_b / wy_total);
	        
	        col += w * texture2D(texture, center + samplePos * tx);
	        wei += w;
	    }
	    
	    col /= wei;
	    return col;
	}

	#region clean edge
		//the color with the highest priority.
		// other colors will be tested based on distance to this
		// color to determine which colors take priority for overlaps.
		/* uniform */ vec3 highestColor = vec3(1.,1.,1.);
		/* uniform */ float lineWidth = 1.0;

		bool similar(vec4 col1, vec4 col2)                                  { return col1 == col2; }
		bool similar(vec4 col1, vec4 col2, vec4 col3)                       { return col1 == col2 && col2 == col3; }
		bool similar(vec4 col1, vec4 col2, vec4 col3, vec4 col4)            { return col1 == col2 && col2 == col3 && col3 == col4; }
		bool similar(vec4 col1, vec4 col2, vec4 col3, vec4 col4, vec4 col5) { return col1 == col2 && col2 == col3 && col3 == col4 && col4 == col5; }

		bool higher(   vec4 thisCol, vec4 otherCol) { return length(thisCol) > length(otherCol); }
		vec4 higherCol(vec4 thisCol, vec4 otherCol) { return length(thisCol) > length(otherCol) ? thisCol : otherCol; }
		
		float distToLine(vec2 testPt, vec2 pt1, vec2 pt2, vec2 dir) {
			vec2 lineDir = pt2 - pt1;
			vec2 perpDir = vec2(lineDir.y, -lineDir.x);
			vec2 dirToPt1 = pt1 - testPt;
			return (dot(perpDir, dir) > 0.0 ? 1.0 : -1.0) * (dot(normalize(perpDir), dirToPt1));
		}

		//based on down-forward direction
		vec4 sliceDist(vec2 point, vec2 mainDir, vec2 pointDir, vec4 u, vec4 uf, vec4 uff, vec4 b, vec4 c, vec4 f, vec4 ff, vec4 db, vec4 d, vec4 df, vec4 dff, vec4 ddb, vec4 dd, vec4 ddf) {
			float minWidth = 0.44;
			float maxWidth = 1.142;
			
			float _lineWidth = max(minWidth, min(maxWidth, lineWidth));
			point = mainDir * (point - 0.5) + 0.5; //flip point
			
			//edge detection
			float distAgainst = 4.0 * distance(f,d) + distance(uf,c) + distance(c,db) + distance(ff,df) + distance(df,dd);
			float distTowards = 4.0 * distance(c,df) + distance(u,f) + distance(f,dff) + distance(b,d) + distance(d,ddf);
			bool  shouldSlice = (distAgainst < distTowards) || (distAgainst < distTowards + 0.001) && !higher(c, f); //equivalent edges edge case

			if(similar(f, d, b, u) && similar(uf, df, db/*, ub*/) && !similar(c, f)) //checkerboard edge case
				shouldSlice = false;
			
			if(!shouldSlice) return vec4(-1.0);
			
			float dist   = 1.0;
			bool  flip   = false;
			vec2  center = vec2(0.5,0.5);
			
			if(similar(f, d, db) && !similar(f, d, b) && !similar(uf, db)) { //lower shallow 2:1 slant
				if(similar(c, df) && higher(c, f)) { //single pixel wide diagonal, dont flip
					
				} else {
					//priority edge cases
					if(higher(c, f))
						flip = true; 
					
					if(similar(u, f) && !similar(c, df) && !higher(c, u))
						flip = true; 
				}
				
				if(flip) dist = _lineWidth - distToLine(point, center+vec2(1.5, -1.0)*pointDir, center+vec2(-0.5, 0.0)*pointDir, -pointDir); //midpoints of neighbor two-pixel groupings
				else     dist = distToLine(point, center+vec2(1.5, 0.0)*pointDir, center+vec2(-0.5, 1.0)*pointDir, pointDir); //midpoints of neighbor two-pixel groupings
				
				dist -= (_lineWidth/2.0);
				return dist <= 0.0 ? ((distance(c,f) <= distance(c,d)) ? f : d) : vec4(-1.0);

			} else if(similar(uf, f, d) && !similar(u, f, d) && !similar(uf, db)) { //forward steep 2:1 slant
				if(similar(c, df) && higher(c, d)) { //single pixel wide diagonal, dont flip
					
				} else {
					//priority edge cases
					if(higher(c, d))
						flip = true; 
					
					if(similar(b, d) && !similar(c, df) && !higher(c, d))
						flip = true; 
					
				}
				
				if(flip) dist = _lineWidth-distToLine(point, center+vec2(0.0, -0.5)*pointDir, center+vec2(-1.0, 1.5)*pointDir, -pointDir); //midpoints of neighbor two-pixel groupings
				else     dist = distToLine(point, center+vec2(1.0, -0.5)*pointDir, center+vec2(0.0, 1.5)*pointDir, pointDir); //midpoints of neighbor two-pixel groupings
				
				dist -= (_lineWidth/2.0);
				return dist <= 0.0 ? ((distance(c,f) <= distance(c,d)) ? f : d) : vec4(-1.0);

			} else if(similar(f, d)) { //45 diagonal
				if(similar(c, df) && higher(c, f)) { //single pixel diagonal along neighbors, dont flip
					if(!similar(c, dd) && !similar(c, ff)) //line against triple color stripe edge case
						flip = true; 
					
				} else {
					//priority edge cases
					if(higher(c, f)) 
						flip = true; 
					
					if(!similar(c, b) && similar(b, f, d, u))
						flip = true;
					
				}
				//single pixel 2:1 slope, dont flip
				if((( (similar(f, db) && similar(u, f, df)) || (similar(uf, d) && similar(b, d, df)) ) && !similar(c, df)))
					flip = true;
				
				if(flip) dist = _lineWidth-distToLine(point, center+vec2(1.0, -1.0)*pointDir, center+vec2(-1.0, 1.0)*pointDir, -pointDir); //midpoints of own diagonal pixels
				else     dist = distToLine(point, center+vec2(1.0, 0.0)*pointDir, center+vec2(0.0, 1.0)*pointDir, pointDir); //midpoints of corner neighbor pixels
				
				dist -= (_lineWidth/2.0);
				return dist <= 0.0 ? ((distance(c,f) <= distance(c,d)) ? f : d) : vec4(-1.0);
			} 
			
			else if(similar(ff, df, d) && !similar(ff, df, c) && !similar(uff, d)) { //far corner of shallow slant 
				
				if(similar(f, dff) && higher(f, ff)) { //single pixel wide diagonal, dont flip
					
				} else {
					//priority edge cases
					if(higher(f, ff))
						flip = true; 
					
					if(similar(uf, ff) && !similar(f, dff) && !higher(f, uf))
						flip = true; 
				}

				if(flip) dist = _lineWidth-distToLine(point, center+vec2(1.5+1.0, -1.0)*pointDir, center+vec2(-0.5+1.0, 0.0)*pointDir, -pointDir); //midpoints of neighbor two-pixel groupings
				else     dist = distToLine(point, center+vec2(1.5+1.0, 0.0)*pointDir, center+vec2(-0.5+1.0, 1.0)*pointDir, pointDir); //midpoints of neighbor two-pixel groupings
				
				dist -= (_lineWidth/2.0);
				return dist <= 0.0 ? ((distance(f,ff) <= distance(f,df)) ? ff : df) : vec4(-1.0);

			} else if(similar(f, df, dd) && !similar(c, df, dd) && !similar(f, ddb)) { //far corner of steep slant
				if(similar(d, ddf) && higher(d, dd)) { //single pixel wide diagonal, dont flip
					
				} else {
					//priority edge cases
					if(higher(d, dd))
						flip = true; 
					
					if(similar(db, dd) && !similar(d, ddf) && !higher(d, dd))
						flip = true; 
					
				}
				
				if(flip) dist = _lineWidth-distToLine(point, center+vec2(0.0, -0.5+1.0)*pointDir, center+vec2(-1.0, 1.5+1.0)*pointDir, -pointDir); //midpoints of neighbor two-pixel groupings
				else     dist = distToLine(point, center+vec2(1.0, -0.5+1.0)*pointDir, center+vec2(0.0, 1.5+1.0)*pointDir, pointDir); //midpoints of neighbor two-pixel groupings
				
				dist -= (_lineWidth/2.0);
				return dist <= 0.0 ? ((distance(d,df) <= distance(d,dd)) ? df : dd) : vec4(-1.0);
			}
			
			return vec4(-1.0);
		}

		vec4 texture2Dclean( sampler2D texture, vec2 uv ) {
			vec2 size  = sampleDimension + 0.0001;
			vec2 px    = uv * size;
				
			vec2 local = fract(px);
			px = ceil(px);
			
			vec2 pointDir = floor(local + .5) * 2.0 - 1.0;
			
			// neighbor pixels
			// Up, Down, Forward, and Back
			// relative to quadrant of current location within pixel
			
			vec4 uub = texture2D( texture, (px + vec2(-1.0, -2.0) * pointDir) / size);
			vec4 uu  = texture2D( texture, (px + vec2( 0.0, -2.0) * pointDir) / size);
			vec4 uuf = texture2D( texture, (px + vec2( 1.0, -2.0) * pointDir) / size);
			
			vec4 ubb = texture2D( texture, (px + vec2(-2.0, -2.0) * pointDir) / size);
			vec4 ub  = texture2D( texture, (px + vec2(-1.0, -1.0) * pointDir) / size);
			vec4 u   = texture2D( texture, (px + vec2( 0.0, -1.0) * pointDir) / size);
			vec4 uf  = texture2D( texture, (px + vec2( 1.0, -1.0) * pointDir) / size);
			vec4 uff = texture2D( texture, (px + vec2( 2.0, -1.0) * pointDir) / size);
			
			vec4 bb  = texture2D( texture, (px + vec2(-2.0,  0.0) * pointDir) / size);
			vec4 b   = texture2D( texture, (px + vec2(-1.0,  0.0) * pointDir) / size);
			vec4 c   = texture2D( texture, (px + vec2( 0.0,  0.0) * pointDir) / size);
			vec4 f   = texture2D( texture, (px + vec2( 1.0,  0.0) * pointDir) / size);
			vec4 ff  = texture2D( texture, (px + vec2( 2.0,  0.0) * pointDir) / size);
			
			vec4 dbb = texture2D( texture, (px + vec2(-2.0,  1.0) * pointDir) / size);
			vec4 db  = texture2D( texture, (px + vec2(-1.0,  1.0) * pointDir) / size);
			vec4 d   = texture2D( texture, (px + vec2( 0.0,  1.0) * pointDir) / size);
			vec4 df  = texture2D( texture, (px + vec2( 1.0,  1.0) * pointDir) / size);
			vec4 dff = texture2D( texture, (px + vec2( 2.0,  1.0) * pointDir) / size);
			
			vec4 ddb = texture2D( texture, (px + vec2(-1.0,  2.0) * pointDir) / size);
			vec4 dd  = texture2D( texture, (px + vec2( 0.0,  2.0) * pointDir) / size);
			vec4 ddf = texture2D( texture, (px + vec2( 1.0,  2.0) * pointDir) / size);
			
			// c_orner, b_ack, and u_p slices
			// (slices from neighbor pixels will only ever reach these 3 quadrants
			
			vec4 u_col = sliceDist(local, vec2( 1.0, -1.0), pointDir, d, df, dff, b, c, f, ff, ub, u, uf, uff, uub, uu, uuf);
			if(u_col.r >= 0.0) return u_col;

			vec4 b_col = sliceDist(local, vec2(-1.0,  1.0), pointDir, u, ub, ubb, f, c, b, bb, df, d, db, dbb, ddf, dd, ddb);
			if(b_col.r >= 0.0) return b_col;
			
			vec4 c_col = sliceDist(local, vec2( 1.0,  1.0), pointDir, u, uf, uff, b, c, f, ff, db, d, df, dff, ddb, dd, ddf);
			if(c_col.r >= 0.0) return c_col;

			return c;
		}
	#endregion

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
			 if(interpolation <= 2)	return texture2D(          texture, uv );
		else if(interpolation == 3)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 4)	return texture2D_lanczos3( texture, uv );
		else if(interpolation == 6)	return texture2Dclean(     texture, uv );

		return texture2D( texture, uv );
	}

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

	vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

		if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2Dintp(texture, fract(pos));
		// 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 8) return texture2Dintp(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 12) return texture2Dintp(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
		return vec4(0.);
	}
	vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_ext --
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

#define TAU 6.283185307179586
#define PI  3.141592653589793

uniform vec2  dimension;

uniform vec2  position;
uniform float rotation;

uniform vec2  center;
uniform vec2  scale;
uniform float angle;
uniform int   rscale;
uniform float trim;

uniform int       reflecc;
uniform vec2      spokes;
uniform int       spokesUseSurf;
uniform sampler2D spokesSurf;
uniform float     spokes_curve[CURVE_MAX];
uniform int       spokes_curve_use;
uniform int       spokes_amount;

float round(in float a) { return floor(a + .5);  }

void main() {
	float spk = spokes.x;
	if(spokesUseSurf == 1) {
		vec4 _vMap = texture2D( spokesSurf, v_vTexcoord );
		spk = mix(spokes.x, spokes.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float ang = radians(rotation);
	
	vec2  px  = v_vTexcoord * dimension - position - center;
	      px *= mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	if(spokes_curve_use == 1) 
		spk *= curveEval(spokes_curve, spokes_amount, length(px / dimension) / sqrt(2.) * 2.);
	
	float _angle;
	float a = TAU / spk;
	if(reflecc == 1) a *= 2.;
	
	float angleR = radians(angle);
	
	_angle = atan(px.y, px.x) + angleR;
	_angle = TAU - mod(_angle, TAU); 
	_angle = mod(_angle, a);
	
	if(reflecc == 1 && _angle > a / 2.) _angle = a - _angle;
	
	float dist = length(px);
		 if(rscale == 0) dist = dist * scale.y;
	else if(rscale == 1) dist = pow(dist, scale.y);
	
	if(trim > 0. && dist > trim * .5 * dimension.x) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	float _alpha = (angleR + PI) - (_angle + angleR);
	float iangle = (angleR + PI) + _alpha * scale.x;
	
	vec2 ps = (center + vec2(cos(iangle) * dist, -sin(iangle) * dist )) / dimension;
	     ps = fract(ps);
	
	if(mod(floor(ps.x), 2.) > 1.) ps.x = 1. - ps.x;
	if(mod(floor(ps.y), 2.) > 1.) ps.y = 1. - ps.y;
	
	gl_FragColor = sampleTexture( gm_BaseTexture, ps );
}
