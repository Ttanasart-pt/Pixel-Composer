//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 lightPos;
uniform sampler2D solid;

uniform float pointLightRadius;
uniform float lightRadius;
uniform float lightDensity;
uniform int lightType;
uniform int renderSolid;

uniform vec4 lightAmb;
uniform vec4 lightClr;

void main() {
	vec4 bg = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 sl = texture2D( solid, v_vTexcoord );
	
	if(sl.a == 1.) {
		gl_FragColor = renderSolid == 1? sl : lightAmb;
		return;	
	}
	
	float bright = 1.;
	vec2 tx = 1. / dimension;
	
	vec2 ang, lang;
	vec2 lightPosTx = lightPos * tx;
	float dst;
	
	if(lightType == 0) {
		ang = normalize(lightPosTx - v_vTexcoord) * tx;
		lang = vec2(ang.y, -ang.x) * lightRadius;
		dst = length(lightPos - v_vTexcoord * dimension);
	} else if(lightType == 1) {
		ang = normalize(lightPosTx - vec2(.5)) * tx;
		lang = vec2(ang.y, -ang.x) * lightRadius;
		dst = length(dimension);
	}
	
	float softlight = lightDensity - 1.;
	float lightAmo = softlight * 2. + 1.;
	int lightCatch[33];
	
	for(int i = 0; i < int(lightAmo); i++)
		lightCatch[i] = 1;
	
	for(float i = 1.; i < dst; i++) {
		for(int j = 0; j <= int(lightAmo); j++) {
			if(lightCatch[j] == 0) continue;
		
			vec2 _lightPos, _ang;
			
			if(lightType == 0) {
				_lightPos = lightPosTx + lang * (float(j) - softlight);
				_ang = normalize(_lightPos - v_vTexcoord) * tx;
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
			
			vec4 _sl = texture2D( solid, _pos );
			
			if(_sl.a == 1.)
				lightCatch[j] = 0;
		}
	}
	
	int lightCatched = 0;
	for(int i = 0; i < int(lightAmo); i++) {
		if(lightCatch[i] == 1)
			lightCatched++;
	}
	
	float shadow = float(lightCatched) / lightAmo;
	
	if(lightType == 0) {
		float dist = distance(v_vTexcoord * dimension, lightPos);
		float prg  = 1. - clamp(dist / pointLightRadius, 0., 1.);
		shadow *= prg * prg;
	}
	
    gl_FragColor = vec4(bg.rgb * mix(lightAmb, lightClr, shadow).rgb, bg.a);
	
}
