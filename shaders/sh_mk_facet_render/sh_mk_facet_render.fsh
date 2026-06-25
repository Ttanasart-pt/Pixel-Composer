varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform int       useMask;

uniform vec4  ambientColor;

uniform vec4  lightColor;
uniform float lightAngle;
uniform float contrast;
uniform float intensity;

uniform float depthBlend;
uniform float trim;
uniform float reflective;
uniform float maxDepth;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec4 palette[PALETTE_LIMIT];
uniform int  paletteAmount;

void main() {
	vec4  gem   = texture2D(gm_BaseTexture, v_vTexcoord);
	float depth = gem.r;
	float angle = radians(gem.g);
	float order = gem.b;
	
	gl_FragData[0] = vec4(0.);
	gl_FragData[1] = vec4(depth, depth, depth, gem.a);
	gl_FragData[2] = vec4(order, order, order, gem.a);
	
	if(useMask == 1) {
		vec4  msk  = texture2D(mask, v_vTexcoord);
		float mamo = (msk.r + msk.g + msk.b) / 3. * msk.a;
		if(mamo == 0.) return;
	}
	
	int  colrOrder = int(mod(order * maxDepth, float(paletteAmount)));
	vec4 baseColor = palette[colrOrder];
	
	if(depth == 1.) {
		gl_FragData[0] = baseColor * (ambientColor + lightColor * intensity);
		gl_FragData[2] = vec4(1., 1., 1., gem.a);
		return;
	}
	
	if(depth < trim) return;

	float inf = cos(angle - radians(lightAngle));
	float intens = max(0., inf * .5 * contrast + .5) * intensity;
	float reflec = pow(inf * .5 + .5, 3.) * reflective;
	
	vec4 color = baseColor;
	color  *= ambientColor + lightColor * intens * mix(1., depth, depthBlend);
	color  += lightColor * reflec;
	color.a = gem.a;
	
	gl_FragData[0] = color;
}