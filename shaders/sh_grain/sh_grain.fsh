varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     seed;

uniform vec2      brightness;
uniform int       brightnessUseSurf;
uniform sampler2D brightnessSurf;

uniform vec2      red;
uniform int       redUseSurf;
uniform sampler2D redSurf;

uniform vec2      green;
uniform int       greenUseSurf;
uniform sampler2D greenSurf;

uniform vec2      blue;
uniform int       blueUseSurf;
uniform sampler2D blueSurf;

uniform vec2      hue;
uniform int       hueUseSurf;
uniform sampler2D hueSurf;

uniform vec2      sat;
uniform int       satUseSurf;
uniform sampler2D satSurf;

uniform vec2      val;
uniform int       valUseSurf;
uniform sampler2D valSurf;

float random  (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }
vec2  random2 (in vec2 st) { float a = random(st); return vec2(cos(a), sin(a)); }

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

void main() {
    vec4  c   = texture2D( gm_BaseTexture, v_vTexcoord );
    
    float bri = brightness.x;
	if(brightnessUseSurf == 1) {
		vec4 _vMap = texture2D( brightnessSurf, v_vTexcoord );
		bri = mix(brightness.x, brightness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float r = red.x;
	if(redUseSurf == 1) {
		vec4 _vMap = texture2D( redSurf, v_vTexcoord );
		r = mix(red.x, red.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float g = green.x;
	if(greenUseSurf == 1) {
		vec4 _vMap = texture2D( greenSurf, v_vTexcoord );
		g = mix(green.x, green.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float b = blue.x;
	if(blueUseSurf == 1) {
		vec4 _vMap = texture2D( blueSurf, v_vTexcoord );
		b = mix(blue.x, blue.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float h = hue.x;
	if(hueUseSurf == 1) {
		vec4 _vMap = texture2D( hueSurf, v_vTexcoord );
		h = mix(hue.x, hue.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float s = sat.x;
	if(satUseSurf == 1) {
		vec4 _vMap = texture2D( satSurf, v_vTexcoord );
		s = mix(sat.x, sat.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float v = val.x;
	if(valUseSurf == 1) {
		vec4 _vMap = texture2D( valSurf, v_vTexcoord );
		v = mix(val.x, val.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	c.rgb *= 1. + bri * bri * (random(v_vTexcoord + vec2(0.156 + seed / 1000., 0.6169)) * 2. - 1.);
	c.r   +=      r   * r   * (random(v_vTexcoord + vec2(0.985 + seed / 1000., 0.3642)) * 2. - 1.);
	c.g   +=      g   * g   * (random(v_vTexcoord + vec2(0.653 + seed / 1000., 0.4954)) * 2. - 1.);
	c.b   +=      b   * b   * (random(v_vTexcoord + vec2(0.382 + seed / 1000., 0.2967)) * 2. - 1.);
	
	vec3 hsv = rgb2hsv(c.rgb);
	
	hsv.r +=      h   * h   * (random(v_vTexcoord + vec2(0.685 + seed / 1000., 0.5672)) * 2. - 1.);
	hsv.g +=      s   * s   * (random(v_vTexcoord + vec2(0.134 + seed / 1000., 0.8632)) * 2. - 1.);
	hsv.b +=      v   * v   * (random(v_vTexcoord + vec2(0.268 + seed / 1000., 0.1264)) * 2. - 1.);
	
	c.rgb = hsv2rgb(hsv);
	
    gl_FragColor = c;
}
