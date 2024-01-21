varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 lw;
uniform vec2 lr;
uniform vec2 lg;
uniform vec2 lb;
uniform vec2 la;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = (col.r - lr.x) / (lr.y - lr.x);
	col.g = (col.g - lg.x) / (lg.y - lg.x);
	col.b = (col.b - lb.x) / (lb.y - lb.x);
	col.a = (col.a - la.x) / (la.y - la.x);
	
	col.rgb = (col.rgb - lw.x) / (lw.y - lw.x);
	
    gl_FragColor = col;
}
