varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float progress;
uniform float rotation;
uniform vec2  detail;

uniform vec2  u_resolution;
uniform vec2  position;
uniform vec2  scale;

void main() {
	float ang = radians(rotation);
    vec2 uv   = (v_vTexcoord - position / u_resolution) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
    
    for(float i = detail.x; i <= detail.y; i++) {
        uv.x += .5 / i * sin(i * 3. * uv.y + progress);
        uv.y += .3 / i * cos(i * 3. * uv.x + progress);
    }
    
    float a = .5 + .5 * sin(uv.x);
    gl_FragColor = vec4(vec3(a), 1.);
}
