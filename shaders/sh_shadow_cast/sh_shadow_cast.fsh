//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 lightPos;

uniform int useSolid;
uniform sampler2D solid;

uniform float pointLightRadius;
uniform float lightRadius;
uniform float lightDensity;
uniform int lightType;
uniform int renderSolid;

uniform int bgUse;
uniform float bgThres;
uniform float lightBand;
uniform float lightAttn;

uniform float ao;
uniform float aoStr;
uniform int mask;

uniform vec4 lightAmb;
uniform vec4 lightClr;
uniform float lightInt;

#define TAU 6.283185307179586

void main() {
	vec4 bg = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 sl = texture2D( solid, v_vTexcoord );
	
	if(useSolid == 1 && sl.a == 1.) {
		if(mask == 0)
			gl_FragColor = renderSolid == 1? sl : bg * lightAmb;
		else if(mask == 1)
			gl_FragColor = vec4(vec3(0.), bg.a);
		return;	
	}
	
	float bright = 1.;
	vec2 tx		 = 1. / dimension;
	vec2 aspect  = vec2(dimension) / dimension.x;
	
	vec2 pxPos   = v_vTexcoord * dimension;
	vec2 ang, lang;
	vec2 lightPosTx = lightPos * tx;
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
	
	float softlight = lightDensity - 1.;
	float lightAmo = softlight * 2. + 1.;
	int iLightAmo = int(lightAmo);
	int lightCatch[33];
	
	for(int i = 0; i < iLightAmo; i++)
		lightCatch[i] = 1;
	
	for(float i = 1.; i < dst; i++) {
		for(int j = 0; j <= iLightAmo; j++) {
			if(lightCatch[j] == 0) continue;
		
			vec2 _lightPos, _ang;
			
			if(lightType == 0) {
				_lightPos = lightPos + lang * (float(j) - softlight);
				_ang = normalize(_lightPos - pxPos) * tx;
			} else if(lightType == 1) {
				_lightPos = vec2(.5) + ang * dimension + lang * (float(j) - softlight);
				_ang = normalize(_lightPos - vec2(.5)) * tx;
			}
			
			vec2 _pos = v_vTexcoord + _ang * i;
			vec2 _posPx = _pos * dimension;
			
			if(lightType == 0 && floor(abs(lightPos.x - _posPx.x)) + floor(abs(lightPos.y - _posPx.y)) < 1.)
				continue;
			
			if(_pos.x < 0. || _pos.y < 0. || _pos.x > 1. || _pos.y > 1.)
				continue;
			
			if(useSolid == 1) {
				vec4 _sl = texture2D( solid, _pos );
				if(_sl.a == 1.)
					lightCatch[j] = 0;
			}
			
			if(bgUse == 1) {
				vec4 hg = texture2D( gm_BaseTexture, _pos );
				if(distance(bg, hg) >= bgThres)
					lightCatch[j] = 0;
			}
		}
	}
	
	if(ao > 0.) {
		float ambient = 0.;
		
		for(float i = 0.; i < ao; i++) {
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
			
				if(useSolid == 1) {
					vec4 _sl = texture2D( solid, _pos );
					if(_sl.a == 1.) 
						ambient++;
				}
			
				if(bgUse == 1) {
					vec4 hg = texture2D( gm_BaseTexture, _pos );
					if(distance(bg, hg) >= bgThres)
						ambient++;
				}
			}
		}
		
		lightAmo += ambient * aoStr * aoStr;
	}
	
	int lightCatched = 0;
	for(int i = 0; i < iLightAmo; i++) {
		if(lightCatch[i] == 1)
			lightCatched++;
	}
	
	float shadow = float(lightCatched) / lightAmo;
	
	if(lightType == 0) {
		float dist = distance(v_vTexcoord * dimension, lightPos);
		float prg  = 1. - clamp(dist / pointLightRadius, 0., 1.);
		
		shadow *= prg * prg;
	}
	
	if(lightAttn == 0.)
		shadow = shadow * shadow;
	else if(lightAttn == 1.)
		shadow = 1. - (shadow - 1.) * (shadow - 1.);
	else if(lightAttn == 2.)
		shadow = shadow;
	
	if(lightBand > 0.)
		shadow = ceil(shadow * lightBand) / lightBand;
		
	if(mask == 0)
		gl_FragColor = vec4(bg.rgb * mix(lightClr * lightAmb, lightClr, shadow * lightInt).rgb, bg.a);
	else if(mask == 1)
		gl_FragColor = vec4(vec3(shadow * lightInt), bg.a);
}
