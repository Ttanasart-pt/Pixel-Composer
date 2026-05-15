varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform int   lightType;
uniform float lightInt;
uniform vec2  lightPos;

uniform vec2  startPoint;
uniform vec2  endPoint;
uniform float sweep;
uniform float thickness;
uniform float radius;

uniform float radialBandAmo;
uniform float radialBandStart;
uniform float radialBandRatio;

uniform vec2  ellipseLightRadii;
uniform float ellipseLightAngle;

#define TAU 6.283185307179586

float saturate(float x) { return clamp(x, 0., 1.); }
float angleDiff(float a, float b) {
    float diff = abs(a - b);
    return min(diff, TAU - diff);
}

float distToLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
    return length(pa - ba * h);
}

void main() {
	vec2 tx	= 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	float lightRes;
	
	vec2 startTx = startPoint * tx;
	vec2 endTx   = endPoint   * tx;
	
	if(lightType == 0) { // LIGHT_SHAPE_2D.point
		float dist  = distance(px, lightPos);
		float lAttn = 1. - saturate(dist / radius);
		lightRes = lAttn * lAttn;
		
	    if(radialBandAmo > 1.) {
	        float dirr = atan(px.y - lightPos.y, px.x - lightPos.x) + TAU / 2. + radians(radialBandStart);
	        float band = fract(dirr / TAU * radialBandAmo);
	
	        lightRes *= step(radialBandRatio, band);
	    }
	    
	} else if(lightType == 1) { // LIGHT_SHAPE_2D.ellipse
		float elAngle = radians(ellipseLightAngle);
        vec2  elRadii = ellipseLightRadii / dimension;

        vec2 elPos  = lightPos / dimension;
        mat2 invRot = mat2(cos(elAngle), sin(elAngle), -sin(elAngle), cos(elAngle));
        vec2 txPos  = (invRot * (v_vTexcoord - elPos)) / elRadii;

        float lAttn = 1. - saturate(length(txPos));
        lightRes = lAttn * lAttn;
		
	} else if(lightType == 4) { // LIGHT_SHAPE_2D.saber
        float radTx = radius * tx.x;
		float dist  = distToLine(v_vTexcoord, startTx, endTx);
        dist -= thickness * .5 * tx.x;
        
        float lAttn = 1. - saturate(dist / radTx);
        lightRes = lAttn * lAttn;
		
	} else if(lightType == 5 || lightType == 6) { // LIGHT_SHAPE_2D.spot || LIGHT_SHAPE_2D.flame
		float sweepRad = radians(sweep);

        float lightDirection = atan(endTx.y - startTx.y, endTx.x - startTx.x) + TAU / 2.;
        float pointDirection = atan(v_vTexcoord.y - startTx.y, v_vTexcoord.x - startTx.x) + TAU / 2.;
        float pointDistance  = distance(v_vTexcoord, startTx);

        float angleInf = saturate(angleDiff(pointDirection, lightDirection) / sweepRad);
        if(lightType == 5) angleInf = angleInf < 1.? 1. : 0.;
        else angleInf = 1. - angleInf * angleInf;

        float distInf  = saturate(pointDistance / length(endTx - startTx));
        distInf  = 1. - distInf * distInf;
		
        float lAttn = saturate(angleInf * distInf);
        lightRes = lAttn * lAttn;
	}
	
	gl_FragColor = vec4(vec3(lightRes), 1.);
}