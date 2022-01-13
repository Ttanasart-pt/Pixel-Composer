//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float scale;
uniform float time;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    vec2 st = v_vTexcoord + position;
    vec3 color = vec3(.0);

    // Scale
    st *= scale;

    // Tile the space
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimum distance
	float tres = 1.;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));
			
            // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5 * sin(time + 6.2831 * point);
			
			vec2 px = neighbor + point;
            vec2 _diff = px - f_st;
			
            // Distance to the point
            float dist = length(_diff);
			
			if(dist < tres)
				m_dist = dist;
        }
    }

    // Draw the min distance (distance field)
    color += m_dist;

    gl_FragColor = vec4(color,1.0);
}
