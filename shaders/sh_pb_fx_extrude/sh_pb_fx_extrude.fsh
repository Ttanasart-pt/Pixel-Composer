varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   useBox;
uniform int   boxMode;
uniform vec4  boxFrom;
uniform vec4  boxTo;

uniform float angle;
uniform float extDistance;

uniform int   cloneColor;
uniform vec4  extColor;

uniform int   highlight;
uniform float highlightDir;
uniform vec4  highlightColor;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	if(cc.a != 0.) {
		if(highlight == 1) {
			vec2 hig = vec2(cos(highlightDir), -sin(highlightDir));
			vec4 hsm = texture2D(gm_BaseTexture, v_vTexcoord + hig * tx);
			if(hsm.a == 0.) gl_FragColor = highlightColor;
		}
		
		return;
	}
	
	if(useBox == 0) {
		vec2 shf = vec2(cos(angle), -sin(angle));
		
		for(float i = 1.; i <= extDistance; i++) {
			vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord - shf * i * tx);
			if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
		}
		
	} else if(useBox == 1) {
		if(boxMode == 0) {
			float bl = boxFrom.x - boxTo.x;
			float br = boxTo.z - boxFrom.z;
			float bt = boxFrom.y - boxTo.y;
			float bb = boxTo.w - boxFrom.w;
			
			for(float i = 1.; i <= bl; i++) {
				vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(i, 0.) * tx);
				if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
			}
			
			for(float i = 1.; i <= br; i++) {
				vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord - vec2(i, 0.) * tx);
				if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
			}
			
			for(float i = 1.; i <= bt; i++) {
				vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., i) * tx);
				if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
			}
			
			for(float i = 1.; i <= bb; i++) {
				vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., i) * tx);
				if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
			}
			
		} else if(boxMode == 1) {
			float dx = ((boxTo.x + boxTo.z) - (boxFrom.x + boxFrom.z)) / 2.;
			float dy = ((boxTo.y + boxTo.w) - (boxFrom.y + boxFrom.w)) / 2.;
			
			vec2  dd  = vec2(dx, dy);
			vec2  shf = normalize(dd);
			float dst = length(dd);
			
			for(float i = 1.; i <= ceil(dst); i++) {
				vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord - shf * min(i, dst) * tx);
				if(sp.a != 0.) { cc = cloneColor == 1? extColor * sp : extColor; break; }
			}
		}
	}
	
	gl_FragColor = cc;
}