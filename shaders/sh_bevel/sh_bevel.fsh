#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;
uniform vec2  scale;
uniform vec2  shift;
uniform int   slope;

uniform vec2      height;
uniform int       heightUseSurf;
uniform sampler2D heightSurf;

float bright(in vec4 col) { return (col.r + col.g + col.b) / 3. * col.a; }

void main() {
	float hei    = height.x;
	float heiMax = max(height.x, height.y);
	
	if(heightUseSurf == 1) {
		vec4 _vMap = texture2D( heightSurf, v_vTexcoord );
		hei = mix(height.x, height.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 pixelStep = 1. / dimension;
    
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 col1;
	gl_FragColor = col;
	bool done = false;
	
	vec2 shiftPx         = -shift / dimension;
	float b0             = bright(col);
	float shift_angle    = atan(shiftPx.y, shiftPx.x);
	float shift_distance = length(shiftPx);
	float slope_distance = hei * b0;
	float max_distance   = hei;
	
	if(b0 == 0.) return;
	
	float b1 = b0;
	float added_distance, _b1;
	vec2 shf, pxs;
	
	for(float i = 1.; i < heiMax; i++) {
		if(i >= hei) break;
		
		float base = 1.;
		float top  = 0.;
		for(float j = 0.; j <= 64.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			added_distance = 1. + cos(abs(shift_angle - ang)) * shift_distance;
				
			shf = vec2( cos(ang),  sin(ang)) * (i * added_distance) / scale;
			pxs = v_vTexcoord + shf * pixelStep;
				
			col1 = sampleTexture( gm_BaseTexture, pxs );
			_b1  = bright(col1);
				
			if(_b1 < b1) {
				slope_distance = min(slope_distance, i);
				max_distance = min(max_distance, (b0 - _b1) * hei);
				b1 = min(b1, _b1);
				
				i = hei;
				break;
			}
		}
	}
		
	if(max_distance == 0.)
		gl_FragColor = vec4(vec3(b0), col.a);
	else {
		float mx = slope_distance / max_distance;
		if(slope == 1)		mx = pow(mx, 3.) + 3. * mx * mx * (1. - mx);
		else if(slope == 2)	mx = sqrt(1. - pow(mx - 1., 2.));
		
		mx = clamp(mx, 0., 1.);
		float prg = mix(b1, b0, mx);
		gl_FragColor = vec4(vec3(prg), col.a);
	}
}
