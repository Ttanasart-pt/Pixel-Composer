varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 lwi;
uniform vec2 lri;
uniform vec2 lgi;
uniform vec2 lbi;
uniform vec2 lai;

uniform vec2 lwo;
uniform vec2 lro;
uniform vec2 lgo;
uniform vec2 lbo;
uniform vec2 lao;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = (col.r - lri.x) / (lri.y - lri.x) * (lro.y - lro.x) + lro.x;
	col.g = (col.g - lgi.x) / (lgi.y - lgi.x) * (lgo.y - lgo.x) + lgo.x;
	col.b = (col.b - lbi.x) / (lbi.y - lbi.x) * (lbo.y - lbo.x) + lbo.x;
	col.a = (col.a - lai.x) / (lai.y - lai.x) * (lao.y - lao.x) + lao.x;
	
	col.rgb = (col.rgb - lwi.x) / (lwi.y - lwi.x) * (lwo.y - lwo.x) + lwo.x;
	
    gl_FragColor = col;
}
